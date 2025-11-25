# IUCN Red List taxa by scientific name

Retrieve species assessments using scientific names (Latin binomials).
Returns summary assessment data including both latest and historic
assessments.

## Usage

``` r
rl_scientific_name(
  genus_name,
  species_name,
  infra_name = NULL,
  subpopulation_name = NULL
)
```

## Arguments

- genus_name:

  Character. The genus name (required).

- species_name:

  Character. The species name (required).

- infra_name:

  Character. The infraspecific name (optional).

- subpopulation_name:

  Character. The subpopulation name (optional).

## Value

A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column
represents a unique API response JSON key. The tibble contains
assessment data for the specified taxon, including taxon details.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get assessments for Panthera leo (lion)
rl_scientific_name(genus_name = "Panthera", species_name = "leo")
} # }
```
