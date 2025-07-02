  <!-- badges: start -->
  [![R-CMD-check](https://github.com/stangandaho/redlist/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/stangandaho/redlist/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

[![codecov](https://codecov.io/gh/stangandaho/redlist/graph/badge.svg?token=AS6SSJ8F1N)](https://codecov.io/gh/stangandaho/redlist)

![R](https://img.shields.io/badge/R-%2764.svg?style=for-the-badge&logo=R&logoColor=white)
![IUCN](https://img.shields.io/badge/IUCN_Red_List-API_V4-blue)

# IUCN Redlist API Wrapper

## About This Project

**Initiated September, 2024** - This project was developed when `rredlist` package 
was still using the deprecated V3 API. In January 2025, `rredlist` received a major 
update to V4, but this package represents an independent implementation with different design choices.

While both packages now use API V4, they differ significantly in:
- Implementation approach
- Documentation style
- Output formatting
- User interface design

This is **not** a competing package, but rather an alternative implementation for users who prefer:
- Consistent tibble outputs for all endpoints
- API-endpoint-aligned function organization
- Simplified parameter structures

## Installation

```r
# Install from GitHub
remotes::install_github("stangandaho/redlist")
library(redlist)

# Get all Critically Endangered species
cr_species <- rl_red_list_categories(code = "CR")
