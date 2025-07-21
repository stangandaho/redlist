<img src="man/figures/logo.png" align="right" height="132" alt="redlist" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/stangandaho/redlist/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/stangandaho/redlist/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->
[![codecov](https://codecov.io/gh/stangandaho/redlist/graph/badge.svg?token=AS6SSJ8F1N)](https://codecov.io/gh/stangandaho/redlist)


# IUCN Red List R Package

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

## Get started
### 📦 Installation

```r
# Install from GitHub using (required `pak` or `remotes` package)
pak::pkg_install("stangandaho/redlist") # Or remotes::install_github("stangandaho/redlist")
# Load
library(redlist)
```

### 🔑 Set Your API Key
If you're using this package for the first time, you'll likely need an IUCN Red List API key.  
You can check whether it's set by running `rl_check_api()`.  
If this throws an error like '*! Any redlist API available... *', you'll need to set 
an API key before using any of the package functions. Just follow these two simple steps:  
1. Visit the official IUCN Red List API website [here](https://api.iucnredlist.org/users/edit). 
Create an account if you don't already have one. Once logged in, you can generate your API key.  
2. Copy your API key and set it using the `rl_set_api()` function, like this `rl_set_api("xxAx9x..xe")`.  
You can then run `rl_check_api()` again to confirm that your API key is set successfully.


## Code of conduct
Please note that this project is based on the [Contributor Covenant v2.1](https://github.com/stangandaho/redlist/blob/main/CODE_OF_CONDUCT.md). 
By participating in this project you agree to abide by its terms.

## Getting help
If you encounter a clear bug, please file an [issue](https://github.com/stangandaho/redlist/issues) with a minimal reproducible 
example. For questions and other discussion, please use [relevant section](https://github.com/stangandaho/redlist/discussions).
