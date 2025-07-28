# IUCN Red List R Package
# <img src="man/figures/logo.png" align="right" height="100" alt="redlist logo"/>
<!-- badges: start -->
[![R-CMD-check](https://github.com/stangandaho/redlist/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/stangandaho/redlist/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->
[![codecov](https://codecov.io/gh/stangandaho/redlist/graph/badge.svg?token=AS6SSJ8F1N)](https://codecov.io/gh/stangandaho/redlist)

## About This Project
Started in September 2024, this project originated when [`rredlist`](https://github.com/ropensci/rredlist) 
was still tied to the deprecated IUCN Red List V3 API. By January 2025, `rredlist` had transitioned to support 
the V4 API, introducing substantial structural changes. I continued 
developing my own approach, which led to [`redlist`](https://github.com/stangandaho/redlist) — a standalone client 
designed around consistent tibble outputs and streamlined workflows.  

In parallel, there is also the official IUCN-supported package 
[`iucnredlist`](https://iucn-uk.github.io/iucnredlist/), which provides direct access to the same V4 API. 
Although these packages all use API V4, they differ in design: `redlist` focuses on a fresh, independent approach 
with uniform inputs and outputs for all endpoints, while `iucnredlist` represents the official reference implementation.  
These differences mean the packages are not in competition but are complementary, serving different user preferences.

## Get started
### 📦 Installation

```r
# Install from GitHub
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak", dependencies = TRUE)
}
pak::pkg_install("stangandaho/redlist")

# Load
library(redlist)
```

### 🔑 Set Your API Key
If you're using this package for the first time, you'll likely need an IUCN Red List API key.  
You can check whether it's set by running `rl_check_api()`.  
If this throws an error like '*! No Redlist API key found... *', you'll need to set 
an API key before using any of the package functions. Just follow these two simple steps:  
1. Visit the official IUCN Red List API website [here](https://api.iucnredlist.org/users/edit). 
Create an account if you don't already have one. Once logged in, you can request your API key.  
2. Copy your API key and set it using the `rl_set_api()` function, like this `rl_set_api("2GoWiThmYrEDlitApiThatWorkS4me")`.  
You can then run `rl_check_api()` again to confirm that your API key is set successfully.  

> *Please ensure that you have read and agreed to the [API key terms of use](https://www.iucnredlist.org/terms/terms-of-use) and have complied with them during your usage.*

## Usage

The `redlist` package offers simple functions to retrieve and explore IUCN Red List data.

```r
# Retrieve Red List data for Benin (country code "BJ"), first page by default
benin_redlist <- rl_countries(code = "BJ")  # Get first 100 records
head(benin_redlist)                         # Preview the data

# Retrieve data from first 5 pages (up to 500 records)
benin_redlist_pages <- rl_countries(code = "BJ", page = 1:5)

# Retrieve data from first 5 pages, filtered by year published 2023
benin_redlist_2023 <- rl_countries(code = "BJ", page = 1:5, year_published = 2023)

# Retrieve all available data for Benin (no page limit)
benin_redlist_all <- rl_countries(code = "BJ", page = NA)

# Get detailed species info by passing a species sis_id (example: 137286)
species_info <- rl_sis(sis_id = 137286)

# Get detailed assessment info by passing an assessment_id (example: 522738)
assessment_info <- rl_assessment_id(assessment_id = 522738)

# Loop through multiple assessment_ids to collect detailed data for all species
all_species_details <- lapply(benin_redlist$assessments_assessment_id, function(id) {
  rl_assessment_id(assessment_id = id)
}) %>% dplyr::bind_rows()
```

**For a full overview of all available functions, please visit the [redlist website](https://stangandaho.github.io/redlist/reference/index.html)**

## Code of conduct
Please note that this project is based on the [Contributor Covenant v2.1](https://github.com/stangandaho/redlist/blob/main/CODE_OF_CONDUCT.md). 
By participating in this project you agree to abide by its terms.

## Getting help
If you encounter a clear bug, please file an [issue](https://github.com/stangandaho/redlist/issues) with a minimal reproducible 
example. For questions and other discussion, please use [relevant section](https://github.com/stangandaho/redlist/discussions).
