# IUCN Red List population trends

Retrieve available population trend categories or species assessments
for one or more trends.

## Usage

``` r
rl_population_trends(
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

  Character or Numeric. One or more population trend codes (`0`-`3`).
  Use `rl_population_trends()` to list available trend codes and
  definition.

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
contains available population trend categories with columns such as code
and description. If `code` is provided, the tibble contains assessment
data for the specified trend(s), including population trend description,
population trend code, year, latest, and other relevant metadata.

## Details

This function has two modes:

- If `code = NULL`, it returns a list of available population trend
  categories.

- If `code` is provided, it retrieves assessments for the specified
  trend(s), optionally filtered by year, extinction status, scope, and
  page(s).

Population trends include: Increasing, Decreasing, Stable, or Unknown.

If `page` is not specified, the function will automatically paginate
over all available pages for each parameter combination.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all available population trend categories
rl_population_trends()

# Retrieve assessments for species with decreasing populations
rl_population_trends(code = "1")

# Get latest decreasing population assessments from 2020
rl_population_trends(
  code = 2,
  year_published = 2020,
  latest = TRUE
)
} # }
```
