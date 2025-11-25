# IUCN Red List assessment scopes

Retrieve species assessments based on their geographic assessment
scopes. If `code = NULL`, it returns a list of available assessment
scopes. If `code` is provided, it retrieves assessments for the
specified scope(s).

## Usage

``` r
rl_scopes(
  code = NULL,
  year_published = NULL,
  latest = NULL,
  possibly_extinct = NULL,
  possibly_extinct_in_the_wild = NULL,
  scope_code = scope_code %||% NA,
  page = 1
)
```

## Arguments

- code:

  Character or Numeric. One or more scope codes (e.g., "1", "2"). Use
  `rl_scopes()` to list available scope categories.

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
contains available assessment scopes with columns such as code and
description. If `code` is provided, the tibble contains assessment data
for the specified scope(s), including, description, year, latest, taxon
details, and other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all assessment scopes
rl_scopes()

# Get globally assessed species (code 1)
rl_scopes(code = "1")

# Get Pan-Africa species assessed species published since 2020
rl_scopes(
  code = "2",
  year_published = 2020:2023
)
} # }
```
