# =============================================================================
# IUCN Red List Critically Endangered Species Visualization
# Creates a polar chart showing regional distribution of critically endangered species
# =============================================================================

# PACKAGE INSTALLATION AND LOADING ==========================================
# Define required packages for data manipulation, visualization, and IUCN data access
needed_pkg <- c("dplyr", "ggplot2", "ggtext", "showtext", "redlist")

# Loop through each package and install if not available, then load it
for (pkg in needed_pkg) {
  if (!requireNamespace(pkg)) {  # Check if package is installed
    installed.packages(pkg)
  }
  library(pkg, character.only = TRUE)  # Load the package
}

# Clean up temporary variables
rm(pkg, needed_pkg)

# DATA ACQUISITION ===========================================================
# Query IUCN Red List API for all Critically Endangered (CR) species
# Note: The API call is commented out to avoid repeated requests
all_CR <- redlist::rl_red_list_categories(code = "CR", page = NA)
# write.csv(all_CR, row.names = F, file = "all_CR.csv")
# Load pre-downloaded data from CSV file
# all_CR <- read.csv("all_CR.csv")

# DATA PROCESSING ============================================================
# Count species by assessment scope (Global vs Regional assessments)
scope_count <- all_CR %>%
  # Remove duplicate species (same species may have multiple assessments)
  dplyr::distinct(taxon_scientific_name, .keep_all = TRUE) %>%
  # Count species by scope description
  dplyr::count(scopes_description_en) %>%
  # Standardize scope names for better readability
  dplyr::mutate(
    scopes_description_en = dplyr::case_when(
      scopes_description_en == "S. Africa FW" ~ "Southern Africa",
      TRUE ~ scopes_description_en  # Keep other names as-is
    )
  )

# Extract total count for global assessments
global_total <- scope_count %>%
  dplyr::filter(scopes_description_en == "Global") %>%
  dplyr::pull(n)

# Filter and process regional assessments only
regional_cr <- scope_count %>%
  dplyr::filter(scopes_description_en != "Global")

# Calculate total regional species count
regional_total <- sum(regional_cr$n)

# Calculate proportions and prepare data for visualization
regional_prop <- regional_cr %>%
  # Calculate percentage of each region relative to total regional species
  dplyr::mutate(prop = round(n * 100 / sum(n), 1)) %>%
  # Sort by proportion (smallest to largest)
  dplyr::arrange(prop) %>%
  # Rename column for clarity
  dplyr::rename(scope = scopes_description_en) %>%
  # Wrap long text labels for better display
  dplyr::mutate(scope = stringr::str_wrap(scope, width = 80))

# Convert scope to factor to maintain ordering in plot
regional_prop$scope <- factor(
  regional_prop$scope,
  levels = regional_prop$scope
)

# VISUALIZATION DATA PREPARATION =============================================
# Create data frame for text labels positioned above bars
text_table <- dplyr::tibble(
  x = regional_prop$scope,
  # Position labels above the bars with 15% margin
  y = max(regional_prop$prop) + 0.15 * max(regional_prop$prop),
  prop = regional_prop$prop
)

# Create data frame for line segments connecting center to bars
linerange_tible <- dplyr::tibble(
  x = regional_prop$scope,
  ymin = 0,  # Start from center
  # End below the text labels
  ymax = text_table$y - 0.3 * max(regional_prop$prop)
)

# Store maximum proportion for scaling
maxprop <- max(regional_prop$prop)

# VISUAL STYLING =============================================================
# Define color palette for gradient fill (warm earth tones)
color_plt <- c("#BFB0A3", "#8C7972", "#403434", "#F29D7E", "#731F17")
std_color <- "#8F9BA6"  # Standard color for lines and points

# Load custom fonts for better typography
font_add("mb", "plots/montserrat/Montserrat-Bold.ttf")
font_add("meb", "plots/montserrat/Montserrat-ExtraBold.ttf")
font_add("mm", "plots/montserrat/Montserrat-Medium.ttf")
showtext_auto()  # Enable custom fonts in plots

# Function to create styled HTML text for labels
css_wrapper <- function(x, ...) {
  paste0(
    # Region name in brown, medium weight
    "<span style = 'color:#6B4945; font-family:mm'>",
    x,
    "</span>",
    # Percentage in gray, bold weight
    paste0("<span style = 'color:#8F9BA6; font-family:mb'>", ..., "")
  )
}

# PLOT CREATION ==============================================================
regional_prop %>%
  ggplot2::ggplot(data = ., mapping = aes(x = scope)) +

  # Add radial lines from center to each bar
  geom_linerange(
    data = linerange_tible,
    mapping = aes(x = x, ymin = ymin, ymax = ymax),
    color = std_color
  ) +

  # Add outer circle points (gray)
  geom_point(
    data = linerange_tible,
    mapping = aes(x = x, y = ymax),
    size = 4,
    color = std_color
  ) +

  # Add inner circle points (white) for contrast
  geom_point(
    data = linerange_tible,
    mapping = aes(x = x, y = ymax),
    size = 2,
    color = "white"
  ) +

  # Create the main bars with gradient fill based on proportion
  geom_col(mapping = aes(y = prop, fill = prop), show.legend = FALSE) +

  # Add text labels showing region names and percentages
  geom_richtext(
    data = text_table,
    mapping = aes(
      x = x,
      y = y,
      label = css_wrapper(x, paste0("<br>", prop, "%"))
    ),
    fill = NA,           # Transparent background
    label.color = NA,    # No border
    size = 10,
    lineheight = 0.3     # Tight line spacing
  ) +

  # Convert to polar coordinates (creates circular chart)
  coord_polar() +

  # Set y-axis limits (negative values create hollow center)
  ylim(-maxprop, maxprop + 0.2 * maxprop) +

  # Remove default theme elements
  theme_void() +

  # Apply gradient color scale
  scale_fill_gradientn(colours = color_plt) +

  # Add total count in center of chart
  geom_richtext(
    aes(
      x = 3,                    # Center position
      y = -maxprop,             # Bottom of chart
      label = paste0(
        "Total<br>",
        "<span style = 'color:#731F17'>",
        regional_total,
        "</span>"
      )
    ),
    fill = NA,
    label.color = NA,
    label.padding = grid::unit(rep(0, 4), "pt"),
    size = 30,
    color = std_color,
    family = "mb",
    hjust = 0.5,
    vjust = 0.5,
    inherit.aes = FALSE,
    lineheight = .2
  ) +

  # Add plot title with HTML formatting
  labs(
    title = "Regional Distribution of <span style = 'color:#731F17'>Critically Endangered</span> <br> Species Assessed in the Latest IUCN Red List"
  ) +

  # Customize plot appearance
  theme(
    plot.margin = margin(t = 0.5, r = .5, b = .1, l = .5, unit = "lines"),
    plot.title = element_markdown(
      family = "mb",
      size = 45,
      color = "#737373",
      lineheight = .4,
      hjust = .5        # Center the title
    )
  )

# SAVE THE PLOT ==============================================================
ggsave(
  "plots/regional_CR.jpeg",
  width = 15,
  height = 15,
  units = "cm"
)
