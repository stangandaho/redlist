# IUCN Red List taxa by SIS ID

Retrieve species assessments using the Species Information Service (SIS)
identifier. Returns summary assessment data including both latest and
historic assessments.

## Usage

``` r
rl_sis(sis_id = 179359)
```

## Arguments

- sis_id:

  Numeric. One or more SIS identifiers for taxa.

## Value

A tibble (class `tbl_df`, `tbl`, `data.frame`) containing assessment
data for the specified SIS ID(s).

## Examples

``` r
if (FALSE) { # \dontrun{
# Get assessments for species with SIS ID 179359
rl_sis(179359)
} # }
```
