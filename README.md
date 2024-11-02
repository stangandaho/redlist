**Access and Analyze IUCN Red List Data**

The `redlist` package provides tools to access and analyze data from the IUCN Red List API. 
It enables users to retrieve species assessments, conservation statuses, 
population trends, and taxonomic information for species listed on the IUCN Red 
List of Threatened Species. This package is designed to support conservation efforts 
and biodiversity research by programmatically accessing up-to-date Red List data.

## Installation

You can install the `redlist` package from GitHub using the following commands:

```r
# Install the remotes package if you haven't already
install.packages("remotes")

# Install the redlist package from GitHub
remotes::install_github("stangandaho/redlist")
```

## Usage

```r
library(redlist)

# Set your IUCN Red List API key
rl_set_api("your_api_key_here")

# Get assessments for a specific country (e.g., Benin)
assessments <- rl_country("BJ")

# Get assessment info from a specific species name
species_info <- rl_from_species_name("Panthera leo")
```
