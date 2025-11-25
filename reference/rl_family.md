# IUCN Red List taxa by family

Retrieve species assessments by taxonomic family. If
`family_name = NULL`, it returns a list of available families. If
`family_name` is provided, it retrieves assessments for species in the
specified family.

## Usage

``` r
rl_family(
  family_name = NULL,
  year_published = NULL,
  latest = NULL,
  scope_code = NULL,
  page = 1
)
```

## Arguments

- family_name:

  Character. The family name (e.g., "Felidae"). Use `rl_family()` to
  list available families.

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
represents a unique API response JSON key. If `family_name = NULL`, the
tibble contains available family names. If `family_name` is provided,
the tibble contains assessment data for the specified family, including
taxon details, red list category, year, and other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all available families
rl_family()

# Get assessments for Felidae family
rl_family(family_name = "Felidae")

# Get latest Canidae assessments published from 2019 to 2022
rl_family(
  family_name = "Canidae",
  year_published = 2019:2022,
  latest = TRUE
)
} # }
```
