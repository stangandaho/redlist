# IUCN Red List possibly extinct taxa

Retrieve species assessments flagged as possibly extinct. Returns all
latest global assessments for taxa that are possibly extinct.

## Usage

``` r
rl_possibly_extinct()
```

## Value

A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column
represents a unique API response JSON key. Columns include year, latest,
possibly extinct, possibly extinct in the wild, sis taxon id, url, taxon
scientific name, red list category, assessment id, scopes description,
and scopes code

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all possibly extinct species
rl_possibly_extinct()
} # }
```
