# IUCN Red List taxa by phylum

Retrieve species assessments by phylum. If `phylum_name = NULL`, it
returns a list of available phyla. If `phylum_name` is provided, it
retrieves assessments for species in the specified phylum.

## Usage

``` r
rl_phylum(
  phylum_name = NULL,
  year_published = NULL,
  latest = NULL,
  scope_code = NULL,
  page = 1
)
```

## Arguments

- phylum_name:

  Character. The phylum name (e.g., "Chordata"). Use `rl_phylum()` to
  list available phyla.

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
represents a unique API response JSON key. If `phylum_name = NULL`, the
tibble contains available phylum names. If `phylum_name` is provided,
the tibble contains assessment data for the specified phylum, year,
latest, possibly extincts, and other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all available phyla
rl_phylum()

# Get assessments for species in Chordata phylum
rl_phylum(phylum_name = "Chordata")

# Get latest assessments for Arthropoda published in 2020
rl_phylum(
  phylum_name = "Arthropoda",
  year_published = 2020,
  latest = TRUE
)
} # }
```
