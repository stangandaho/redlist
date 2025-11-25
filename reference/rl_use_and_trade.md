# IUCN Red List use and trade categories

Retrieve species assessments based on use and trade categories. If
`code = NULL`, it returns a list of available use and trade categories.
If `code` is provided, it retrieves assessments for species affected by
the specified use/trade category(ies).

## Usage

``` r
rl_use_and_trade(
  code = NULL,
  year_published = NULL,
  latest = NULL,
  possibly_extinct = NULL,
  possibly_extinct_in_the_wild = NULL,
  scope_code = NULL,
  page = 1
)
```

## Arguments

- code:

  Character. One or more use/trade codes (e.g., "1", "5_2"). Use
  `rl_use_and_trade()` to list available categories.

- year_published:

  Optional. Single or numeric vector of years to filter assessments by
  publication year.

- latest:

  Optional. Logical. If `TRUE`, return only the latest assessment per
  species.

- possibly_extinct:

  Optional. Logical. Filter for species flagged as possibly extinct.

- possibly_extinct_in_the_wild:

  Optional. Logical. Filter for species possibly extinct in the wild.

- scope_code:

  Optional. Integer One or more scope codes to filter assessments.

- page:

  Optional. Integer vector. Specify one or more page numbers to fetch.
  If `NULL` or `NA`, all pages will be fetched automatically.

## Value

A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column
represents a unique API response JSON key. If `code = NULL`, the tibble
contains available use and trade categories with columns such as code
and description. If `code` is provided, the tibble contains assessment
data for the specified use/trade category(ies), including description,
code, year, latest, and other relevant metatdata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all use and trade categories
rl_use_and_trade()

# Get species used for food - human (code 1)
rl_use_and_trade(code = "1")

# Get species hunted for Sport hunting/specimen collecting published in 2024
rl_use_and_trade(
  code = "15",
  year_published = 2024
)
} # }
```
