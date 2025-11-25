# IUCN Red List Categories

Retrieve species assessments based on their Red List threat categories.
If `code = NULL`, it returns a list of available Red List categories. If
`code` is provided, it retrieves assessments for species in the
specified category(ies).

## Usage

``` r
rl_red_list_categories(
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

  Character. One or more Red List category codes (e.g., "CR", "EN"). Use
  `rl_red_list_categories()` to list available categories.

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
contains available Red List categories with columns such as code and
description. If `code` is provided, the tibble contains assessment data
for the specified category(ies), including year, taxon details, and
other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all Red List categories
rl_red_list_categories()

# Get Critically Endangered species assessments
rl_red_list_categories(code = "CR")

# Get Vulnerable species assessments published in 2020
rl_red_list_categories(
  code = "VU",
  year_published = 2020
)
} # }
```
