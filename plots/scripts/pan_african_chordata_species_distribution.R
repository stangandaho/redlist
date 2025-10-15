# ==============================================================================
# IUCN Red List Status of Pan-African Chordata Species
# ==============================================================================
# Purpose: Analyze and visualize the distribution of IUCN Red List categories
#          for Chordata species with Pan-African scope
# Author: Stanislas Mahussi Gandaho
# Date: 2025
# Data Source: IUCN Red List API via redlist package
# ==============================================================================

# 1. PACKAGE MANAGEMENT
# Define required packages for data manipulation, visualization, and IUCN data access
needed_pkg <- c("dplyr",     # Data manipulation
                "ggplot2",   # Data visualization
                "ggtext",    # Rich text rendering in plots
                "showtext",  # Custom font support
                "redlist")   # IUCN Red List API access

# Loop through each package and install if not available, then load it
for (pkg in needed_pkg) {
  if (!requireNamespace(pkg)) {  # Check if package is installed
    installed.packages(pkg)      # Note: Should be install.packages(pkg)
  }
  library(pkg, character.only = TRUE)  # Load the package
}

# Clean up temporary variables
rm(pkg, needed_pkg)

# 2. DATA ACQUISITION
# Retrieve all Chordata phylum data from IUCN Red List
# Note: This may take several minutes depending on API response time
# You can learn more here: https://stangandaho.github.io/redlist/index.html
chordata <- redlist::rl_phylum(phylum_name = "CHORDATA", page = NA)

# 3. IUCN RED LIST CATEGORIES DEFINITION
# Define IUCN Red List categories with their official codes
iucn_rc <- c("Data Deficient" = "DD",           # Inadequate information
             "Least Concern" = "LC",             # Lowest risk
             "Near Threatened" = "NT",           # Close to qualifying for threatened
             "Vulnerable" = "VU",                # High risk of extinction
             "Endangered" = "EN",                # Very high risk of extinction
             "Critically Endangered" = "CR",     # Extremely high risk of extinction
             "Extinct in the Wild" = "EW",       # Only survives in captivity
             "Extinct" = "EX",                   # No individuals remaining
             "Not Evaluated" = "NE")             # Not yet assessed

# Define official IUCN color scheme for each category
iucn_rc_color <- c("Data Deficient" = "#D1D1C6",           # Light gray
                   "Least Concern" = "#61C658",             # Green
                   "Near Threatened" = "#CDE227",           # Yellow-green
                   "Vulnerable" = "#F9E915",                # Yellow
                   "Endangered" = "#FC7E3E",                # Orange
                   "Critically Endangered" = "#D91F05",     # Red
                   "Extinct in the Wild" = "#552244",       # Dark purple
                   "Extinct" = "#000000",                   # Black
                   "Not Evaluated" = "#FEFFFE")             # White

# Create reference dataframe combining categories, codes, and colors
icun_rc_df <- dplyr::tibble(red_list_category = names(iucn_rc),
                            red_list_category_code = iucn_rc,
                            color = iucn_rc_color)

# 4. DATA FILTERING AND SUMMARIZATION
# Process Chordata data to create summary statistics
chordata_summary <- chordata %>%
  # Filter for Pan-African species and valid IUCN categories
  filter(
    scopes_description_en == "Pan-Africa",           # Geographic scope
    red_list_category_code %in% iucn_rc              # Valid categories only
  ) %>%
  # Keep only the most recent assessment per species to avoid duplicates
  group_by(taxon_scientific_name) %>%
  slice_max(year_published, n = 1, with_ties = FALSE) %>%
  # Calculate counts per IUCN category
  group_by(red_list_category_code) %>%
  summarise(n = n(), .groups = "drop") %>%
  # Calculate percentage distribution
  mutate(prop = round(n * 100 / sum(n), 1)) %>%
  # Sort by proportion for plotting
  arrange(prop)

# Merge summary data with color scheme
chordata_final <- chordata_summary %>%
  left_join(x = ., y = icun_rc_df, by = "red_list_category_code")

# Convert category codes to factor to maintain order in visualization
chordata_final$red_list_category_code <- factor(
  x = chordata_final$red_list_category_code,
  levels = chordata_final$red_list_category_code
)

# 5. CALCULATE VISUALIZATION PARAMETERS
# Total number of species for center label
total_chordata <- sum(chordata_summary$n)

# Y-axis positions for polar coordinate system
point_pos <- 75      # Position for category points
label_pos <- 100     # Position for proportion labels

# 6. TYPOGRAPHY SETUP
# Load custom Montserrat fonts for professional appearance
font_add("mb", "plots/montserrat/Montserrat-Bold.ttf")           # Bold
font_add("meb", "plots/montserrat/Montserrat-ExtraBold.ttf")     # Extra Bold
font_add("mm", "plots/montserrat/Montserrat-Medium.ttf")         # Medium
showtext_auto()  # Enable custom fonts in plots

# 7. CREATE SUBTITLE WITH INLINE STYLING
# Build subtitle text in HTML format with category-specific colors
subtitle_html <- paste0(
  "<p style='text-align:left;'>",
  "The IUCN Red List Categories and Criteria are intended to be an easily and widely
  <br> understood system for classifying species at high risk of global extinction.
  <br> It divides species into nine categories: <strong><span style='color:#ffffff; font-family:mb;'>Not Evaluated</span></strong>,
  <span style='color:#D1D1C6; font-family:mb;'>Data Deficient</span>,
  <span style='color:#61C658; font-family:mb;'>Least Concern</span>, <br>
  <span style='color:#CDE227; font-family:mb;'>Near Threatened</span>,
  <span style='color:#F9E915; font-family:mb;'>Vulnerable</span>,
  <span style='color:#FC7E3E; font-family:mb;'>Endangered</span>,
  <span style='color:#D91F05; font-family:mb;'>Critically Endangered</span>,
  <span style='color:#552244; font-family:mb;'>Extinct in the Wild</span>, <br>
  and <b><span style='color:#7b7b7b; font-family:mb;'>Extinct</span>.",
  "</p>"
)

# 8. CREATE VISUALIZATION
# Extract color values for manual color scaling
rc_color <- setNames(chordata_final$color, NULL)

# Create circular (polar coordinate) bar chart
ggplot2::ggplot(data = chordata_final,
                mapping = aes(x = red_list_category_code, y = prop)) +
  # Base bars showing proportions
  geom_col(fill = "gray60", color = "gray60") +
  # Horizontal reference line
  geom_hline(yintercept = label_pos, color = "gray60", linetype = 3, linewidth = 0.3) +
  # Set y-axis limits (negative values center the visualization)
  ylim(-50, 125) +
  # Add titles and attribution
  labs(title = "How at Risk Are Africa's Chordata Species?",
       subtitle = subtitle_html,
       caption = "By Stanislas Mahussi Gandaho | LinkedIn: @stangandaho") +
  # Remove default theme elements for clean circular design
  theme_void() +
  # Convert to polar coordinates for circular visualization
  coord_polar() +
  # Customize plot appearance
  theme(
    plot.margin = margin(r = 1, l = 1, unit = "lines"),
    plot.background = element_rect(fill = "black"),
    plot.title = element_text(color = "gray60", size = 70, family = "mb"),
    plot.title.position = "plot",
    plot.subtitle = ggtext::element_markdown(
      family = "mm", size = 37,
      margin = margin(t = .5, r = .5, unit = "lines"),
      lineheight = .4, colour = "white",
      hjust = 0
    ),
    plot.caption = element_text(
      size = 25, family = "mm", colour = "gray60",
      lineheight = 0.3,
      margin = margin(b = 0.5, r = 0.5, unit = "lines")
    ),
    plot.caption.position = "plot"
  ) +
  # Add connecting lines from bars to labels
  geom_linerange(
    data = chordata_final %>% mutate(point_pos_min = prop, point_pos_max = label_pos),
    mapping = aes(ymin = point_pos_min, ymax = point_pos_max, color = red_list_category_code),
    linewidth = 1, show.legend = FALSE
  ) +
  # Apply category-specific colors (with gray for EX category)
  scale_color_manual(values = c(rc_color[1:2], "gray20", rc_color[4:9])) +
  # Add category indicator points
  geom_point(
    data = chordata_final %>% mutate(point_pos = label_pos),
    mapping = aes(y = point_pos, fill = red_list_category_code),
    size = 12, shape = 21,
    # Special border colors for NE and EX categories
    color = ifelse(chordata_final$red_list_category_code == "NE", "gray90",
                   ifelse(chordata_final$red_list_category_code == "EX", "gray20", "NA")),
    show.legend = FALSE
  ) +
  # Apply IUCN official colors
  scale_fill_manual(values = setNames(chordata_final$color, NULL)) +
  # Add category code labels
  geom_text(
    mapping = aes(label = red_list_category_code, y = prop - prop + label_pos),
    # Black text for light backgrounds, white for dark backgrounds
    color = ifelse(chordata_final$red_list_category_code %in% c("NE", "VU"),
                   "#000000", "#FFFFFF"),
    family = "mb", size = 10
  ) +
  # Add percentage labels
  geom_text(
    mapping = aes(label = paste0(prop, "%"), y = prop - prop + label_pos + 25),
    color = "gray80", family = "mm", size = 12
  ) +
  # Add total species count in center of circular plot
  geom_richtext(
    data = data.frame(x = .5, y = -48),
    aes(x = x, y = y, label = paste0(
      total_chordata, "<br>",
      "<span style = 'color:#731F17'>Species</span>"
    )),
    fill = NA, label.color = NA,
    size = 25, color = "gray30",
    family = "mb", hjust = 0.5, vjust = 0.5,
    lineheight = .2
  )

# 9. EXPORT VISUALIZATION
ggsave("plots/pan_african_chordata_species_distribution.jpeg",
       width = 20, height = 22, units = "cm")
