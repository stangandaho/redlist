  <!-- badges: start -->
  [![R-CMD-check](https://github.com/stangandaho/redlist/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/stangandaho/redlist/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

[![codecov](https://codecov.io/gh/stangandaho/redlist/graph/badge.svg?token=AS6SSJ8F1N)](https://codecov.io/gh/stangandaho/redlist)


# IUCN Redlist API Wrapper

## About This Project

Started in September 2024, this project began while the [`rredlist`](https://github.com/ropensci/rredlist) 
package was still relying on the deprecated IUCN Red List V3 API. In January 2025, 
`rredlist` transitioned to support the V4 API, introducing significant changes.
Rather than adapting it, I chose to continue building on my original work — resulting in `redlist`, 
a standalone package that provides access to the Red List V4 API through a fresh, 
independent implementation with distinct design principles and workflows.

While both packages now use API V4, they differ significantly in implementation 
approach and output formatting. This is **NOT** a competing package, but rather 
an alternative implementation for users who prefer consistent tibble outputs for all endpoints.

## Installation

```r
# Install from GitHub using (required `pak` or `remotes` package)
pak::pkg_install("stangandaho/redlist") # Or remotes::install_github("stangandaho/redlist")
# Load
library(redlist)

# Get the first page (i.e first 100 records) of Critically Endangered species
cr_species <- rl_red_list_categories(code = "CR")
```

## Code of conduct
Please note that this project is based on the [Contributor Covenant v2.1](https://github.com/stangandaho/redlist/blob/main/CODE_OF_CONDUCT.md). 
By participating in this project you agree to abide by its terms.

## Getting help
If you encounter a clear bug, please file an [issue](https://github.com/stangandaho/redlist/issues) with a minimal reproducible 
example. For questions and other discussion, please use [relevant section](https://github.com/stangandaho/redlist/discussions).
