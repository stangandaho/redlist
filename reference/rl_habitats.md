# Habitats

Retrieve IUCN Red List assessments by habitat classification.

## Usage

``` r
rl_habitats(
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

  Character. One or more habitat classification codes. Use
  `rl_habitats()` with no arguments to list available habitat codes.

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
contains available habitat codes and their descriptions. If `code` is
provided, the tibble contains assessment data for the specified
habitat(s), including taxon details, description, red list category,
year, assessment id, and other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve available habitat codes
rl_habitats()

# Retrieve assessments for the Desert
rl_habitats(code = 8)
} # }
```
