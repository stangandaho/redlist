# Retrieve IUCN Red List assessments by country

Retrieves the species assessed by the IUCN for a specified countries.
See `code` argument for available countries codes

## Usage

``` r
rl_countries(
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

  Character. One or more countries ISO alpha-2 code. Use
  `rl_countries()` to list available countries codes.

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
contains available country codes. If `code` is provided, the tibble
contains assessment data for the specified country code(s), including
taxon details, red list category, year, and other relevant metadata

## Examples

``` r
if (FALSE) { # \dontrun{
  # Retrieve assessments for Benin (country code "BJ") for the year 2020
  rl_countries("BJ", year = 2020)

  # Retrieve all assessments for Brazil (country code "BR")
  rl_countries("BR", page = 2)

  # Retrieve assessments for Canada (country code "CA") on specific pages
  rl_countries("CA", page = c(1, 2))
} # }
```
