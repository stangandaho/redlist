# IUCN Red List Comprehensive groups

Get assessment data by comprehensive group name (e.g `amphibians`,
`mammals`, `birds`, `blennies`, `mangrove_plants`, `reptiles`,
`insects`, `fishes`, etc). See `name` argument for available group
names.

## Usage

``` r
rl_comprehensive_groups(
  name = NULL,
  year_published = NULL,
  latest = NULL,
  possibly_extinct = NULL,
  possibly_extinct_in_the_wild = NULL,
  scope_code = NULL,
  page = 1
)
```

## Arguments

- name:

  Character. One or more group names. Use `rl_comprehensive_groups()` to
  list available group names.

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
represents a unique API response JSON key. If `name = NULL`, the tibble
contains available comprehensive group names. If `name` is provided, the
tibble contains assessment data for the specified group(s), including
taxon details, red list category, year, and other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
rl_comprehensive_groups(name = "amphibians",
                        year_published = 2024:2025,
                        page = 1:3)
} # }
```
