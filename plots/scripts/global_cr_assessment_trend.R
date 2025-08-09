# =============================================================================
# IUCN Red List Critically Endangered Species Trend Visualization
# =============================================================================
# This script creates a visualization showing the number of species evaluated
# as Critically Endangered (CR) by the IUCN Red List each year, based on their
# most recent published assessment.

# =============================================================================
# PACKAGE INSTALLATION AND LOADING
# =============================================================================

# Define required packages
needed_pkg <- c("pak", "dplyr", "ggplot2", "ggtext", "showtext", "redlist")

# Check if packages are installed, install if missing, then load them
for (pkg in needed_pkg) {
  if (!requireNamespace(pkg)) {
    if (pkg == "pak") {
      # Note: There's a typo in original code - should be install.packages()
      install.packages("pak")  # Fixed typo from installed.packages()
    }
    pak::pkg_install(pkg)  # Use pak to install other packages
  }
  library(pkg, character.only = TRUE)  # Load each package
}

# Clean up temporary variables
rm(pkg, needed_pkg)

# =============================================================================
# DATA RETRIEVAL AND PROCESSING
# =============================================================================

# Query IUCN Red List API for all Critically Endangered (CR) species
# page = NA retrieves all pages of results
all_CR <- redlist::rl_red_list_categories(code = "CR", page = NA)

# Optional: Save data locally (commented out in original)
# write.csv(all_CR, row.names = F, file = "all_CR.csv")
# all_CR <- read.csv("all_CR.csv")

# Filter to get unique species with their latest assessments
unique_species <- all_CR %>%
  filter(latest) %>%  # Keep only the most recent assessment for each species
  distinct(taxon_scientific_name, .keep_all = TRUE)  # Remove duplicate species
# This returns 10,574 unique CR species records

# =============================================================================
# DATA SUMMARIZATION FOR VISUALIZATION
# =============================================================================

# Count number of species assessed per year
year_trend <- unique_species %>%
  summarise(n = n(), .by = "year_published")  # Group by year and count

# Create data frame for the vertical lines extending from each point to the maximum
# This creates the "lollipop" effect in the chart
linerange <- data.frame(
  year = year_trend$year_published,           # X-axis values (years)
  ymin = year_trend$n,                       # Bottom of each line (actual count)
  ymax = rep(max(year_trend$n), length(year_trend$n)),  # Top of lines (max value)
  n = year_trend$n                           # Count values for labels
)

# =============================================================================
# FONT SETUP
# =============================================================================

# Set path to custom Montserrat fonts
font_path <- "D:/R Projects/Stopover and Homerange/fonts/montserrat"

# Register different weights of Montserrat font
font_add("mb", paste0(font_path, "/Montserrat-Bold.ttf"))        # Bold
font_add("meb", paste0(font_path, "/Montserrat-ExtraBold.ttf"))  # Extra Bold
font_add("mm", paste0(font_path, "/Montserrat-Medium.ttf"))      # Medium

# Enable showtext for custom fonts in plots
showtext_auto()

# =============================================================================
# PLOT CREATION
# =============================================================================

ggplot(year_trend, mapping = aes(x = year_published, y = n)) +

  # Add vertical lines from each point to the maximum value (lollipop stems)
  geom_linerange(data = linerange,
                 mapping = aes(x = year, y = ymin, ymin = ymin, ymax = ymax),
                 color = "#9FC131",    # Light green color
                 linewidth = .2) +    # Thin lines

  # Add main trend line connecting all points
  geom_line(color = "#005C53",       # Dark green color
            linewidth = .7) +        # Medium thickness

  # Add outer points (larger, dark green)
  geom_point(color = "#005C53", size = 3) +

  # Add inner points (smaller, light green) - creates two-tone effect
  geom_point(color = "#9FC131", size = 1.5) +

  # Add data labels at the top of each vertical line
  geom_label(data = linerange,
             mapping = aes(label = sprintf("%.4d", n),  # Format as 4-digit number
                           x = year,
                           y = ymax),
             angle = 90,              # Rotate labels vertically
             hjust = .5,              # Center horizontally
             # Conditional coloring: red for maximum value, dark green for others
             color = if_else(linerange$n == max(linerange$n), "#8C1F28", "#005C53"),
             family = "meb",          # Use extra bold font
             size = 6,                # Font size
             label.padding = unit(.12, units = "lines"),    # Padding inside label
             label.r = unit(.1, units = "lines")) +        # Rounded corners

  # Customize x-axis to show all years
  scale_x_continuous(breaks = year_trend$year_published) +

  # Add titles with HTML formatting for colored text
  labs(title = "Latest IUCN Red List Assessments of <span style = 'color:#BF665E'>Critically Endangered</span> Species",
       subtitle = "Number of species evaluated each year, based on their most recent published assessment") +

  # Use minimal theme as base
  theme_void() +

  # Customize theme elements
  theme(
    # Set plot margins
    plot.margin = margin(t = .5, b = .5, l = .5, r = 0.5, unit = "lines"),

    # Add subtle vertical grid lines
    panel.grid.major.x = element_line(colour = "gray80",
                                      linewidth = 0.2,
                                      linetype = 2),  # Dashed lines

    # Style x-axis text (year labels)
    axis.text.x = element_text(size = 20,
                               angle = 90,        # Vertical text
                               vjust = .5,        # Center vertically
                               margin = margin(t = .5, unit = "lines"),
                               family = "mm",     # Medium font weight
                               color = "gray30"),

    # Add tick marks on x-axis
    axis.ticks.x = element_line(color = "gray", linewidth = 2),

    # Style main title (supports HTML/markdown formatting)
    plot.title = element_markdown(family = "mb", size = 35),

    # Style subtitle
    plot.subtitle = element_markdown(family = "mm",
                                     size = 30,
                                     color = "gray60",
                                     margin = margin(b = 1, unit = "lines"))
  )

# =============================================================================
# SAVE PLOT
# =============================================================================

# Save the plot as a JPEG file
ggsave("plots/globally_CR_trend.jpeg",
       width = 17,        # Width in cm
       height = 11,       # Height in cm
       units = "cm")
