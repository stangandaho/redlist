# IUCN Red List threat categories

Retrieve species assessments based on threat categories. If
`code = NULL`, it returns a list of available threat categories. If
`code` is provided, it retrieves assessments for species affected by the
specified threat(s).

## Usage

``` r
rl_threats(
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

  Character. One or more threat codes (e.g., "1"). Use `rl_threats()` to
  list available threat categories.

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
contains available threat categories with columns such as code and
description. If `code` is provided, the tibble contains assessment data
for the specified threat(s), including threat description, threat code
and year.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all threat categories
rl_threats()

# Get species affected by agriculture & aquaculture threats (code 2)
rl_threats(code = 2)

# Get species affected by Climate change & severe weather threats published in 2025
rl_threats(
  code = "11",
  year_published = 2025
)
} # }
```
