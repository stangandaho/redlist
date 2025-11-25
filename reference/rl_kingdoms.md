# IUCN Red List taxa by kingdom

Retrieve species assessments by kingdom. If `kingdom_name = NULL`, it
returns a list of available kingdoms. If `kingdom_name` is provided, it
retrieves assessments for species in the specified kingdom.

## Usage

``` r
rl_kingdoms(
  kingdom_name = NULL,
  year_published = NULL,
  latest = NULL,
  scope_code = NULL,
  page = 1
)
```

## Arguments

- kingdom_name:

  Character. The kingdom name (e.g., "Animalia"). Use `rl_kingdoms()` to
  list available kingdoms.

- year_published:

  Optional. Single or numeric vector of years to filter assessments by
  publication year.

- latest:

  Optional. Logical. If `TRUE`, return only the latest assessment per
  species.

- scope_code:

  Optional. Integer One or more scope codes to filter assessments.

- page:

  Optional. Integer vector. Specify one or more page numbers to fetch.
  If `NULL` or `NA`, all pages will be fetched automatically.

## Value

A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column
represents a unique API response JSON key. If `kingdom_name = NULL`, the
tibble contains available kingdom names. If `kingdom_name` is provided,
the tibble contains assessment data for the specified kingdom, including
taxon details, red list category, year, and other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all available kingdoms
rl_kingdoms()

# Get assessments for species in Animalia kingdom
rl_kingdoms(kingdom_name = "Animalia")

# Get latest assessments for Plantae published in 2021
rl_kingdoms(
  kingdom_name = "Plantae",
  year_published = 2021,
  latest = TRUE
)
} # }
```
