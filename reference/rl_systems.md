# IUCN Red List ecological systems

Retrieve species assessments based on their ecological systems. If
`code = NULL`, it returns a list of available ecological systems. If
`code` is provided, it retrieves assessments for species in the
specified system(s).

## Usage

``` r
rl_systems(
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

  Character or Numeric. One or more system codes (e.g., "0", "1", "2").
  Use `rl_systems()` to list available ecological systems.

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
contains available ecological systems with columns such as code and
description. If `code` is provided, the tibble contains assessment data
for the specified system(s), including description, possible extinct in
the wild, scientific name, latest, taxon details, and other relevant
metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all ecological systems
rl_systems()

# Get terrestrial species assessments (code 0)
rl_systems(code = 0)

# Get marine species assessments published since 2021
rl_systems(
  code = "2",
  year_published = 2021:2023
)
} # }
```
