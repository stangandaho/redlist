# IUCN Red List taxa by class

Retrieve species assessments by taxonomic class. If `class_name = NULL`,
it returns a list of available classes. If `class_name` is provided, it
retrieves assessments for species in the specified class.

## Usage

``` r
rl_classes(
  class_name = NULL,
  year_published = NULL,
  latest = NULL,
  scope_code = NULL,
  page = 1
)
```

## Arguments

- class_name:

  Character. The class name (e.g., "Mammalia"). Use `rl_classes()` to
  list available classes.

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
represents a unique API response JSON key. If `class_name = NULL`, the
tibble contains available taxonomic classes with a column for class
names. If `class_name` is provided, the tibble contains assessment data
for the specified class, including taxon details, red list category,
year, and other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all available classes
rl_classes()

# Get assessments for Mammalia class
rl_classes(class_name = "Mammalia")

# Get latest Aves assessments published since 2024
rl_classes(
  class_name = "Aves",
  year_published = 2024:2025,
  latest = TRUE
)
} # }
```
