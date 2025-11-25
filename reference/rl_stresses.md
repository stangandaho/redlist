# IUCN Red List stress categories

Retrieve species assessments based on stress categories affecting
species. If `code = NULL`, it returns a list of available stress
categories. If `code` is provided, it retrieves assessments for species
affected by the specified stress(es).

## Usage

``` r
rl_stresses(
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

  Character or Numeric. One or more stress codes (e.g., "1", "2_1"). Use
  `rl_stresses()` to list available stress categories.

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

A tibble (class `tbl_df`, `tbl`, `data.frame`) containing stress
categories or species assessments. If `code = NULL`, the tibble contains
available stress categories with columns such as code and description.
If `code` is provided, the tibble contains assessment data for the
specified stress(es), including year, taxon details, and other relevant
metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all stress categories
rl_stresses()

# Get species affected by ecosystem stresses (code 1)
rl_stresses(code = "1") # or code = 1

# Get species affected by competition stresses published since 2020
rl_stresses(
  code = "2_3_2",
  year_published = 2020:2023
)
} # }
```
