# IUCN Red List research categories

Retrieve species assessments based on their research needs categories.
If `code = NULL`, it returns a list of available research categories. If
`code` is provided, it retrieves assessments for species with the
specified research need(s).

## Usage

``` r
rl_research(
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

  Character Or Numeric. One or more research category codes (e.g., "1",
  "2"). Use `rl_research()` to list available research categories.

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
contains available research categories with columns such as code and
description. If `code` is provided, the tibble contains assessment data
for the specified research need(s), including description, research
code, year, taxon details, and other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all research categories
rl_research()

# Get species needing population trends research (code 3_1)
rl_research(code = "3_1")

# Get species needing life history & ecology research published since 2019
rl_research(
  code = "1_3",
  year_published = 2019:2023
)
} # }
```
