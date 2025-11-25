# IUCN Red List assessment

Retrieves an assessment

## Usage

``` r
rl_assessment_id(assessment_id = 1425064)
```

## Arguments

- assessment_id:

  Assessment ID

## Value

A tibble where each column represents a unique API response JSON key for
the supplied `assessment_id`. The columns include key information about
the Red List assessment, such as taxon details, category, year, and
other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
rl_assessment_id(1425064)
} # }
```
