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
  subpopulation_name = NULL,
  resolve = TRUE
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

- resolve:

  Logical. If `TRUE` (default), attempt to resolve the name via
  [`rl_name_resolve()`](https://stangandaho.github.io/redlist/reference/rl_name_resolve.md)
  and retry when the IUCN Red List returns a 404 (species not found).
  Set to `FALSE` to fail instead.

## Value

A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column
represents a unique API response JSON key. The tibble contains
assessment data for the specified taxon, including taxon details. When
the name had to be resolved, the columns `input_name`, `isSynonym`,
`entryDate`, and `matchType` from
[`rl_name_resolve()`](https://stangandaho.github.io/redlist/reference/rl_name_resolve.md)
are appended.

## Details

When the supplied name is not the one the IUCN Red List uses (a common
case for names coming from GBIF), the API returns a *404* and, if
`resolve = TRUE`, this function calls
[`rl_name_resolve()`](https://stangandaho.github.io/redlist/reference/rl_name_resolve.md)
to recover the accepted IUCN name and retries the request with it. The
resolved-name provenance is then appended as the extra columns
`outlink`, `entryDate`, `currentCanonicalFull`, `isSynonym` and
`matchType`.

## See also

[`rl_name_resolve()`](https://stangandaho.github.io/redlist/reference/rl_name_resolve.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Get assessments for Panthera leo (lion)
rl_scientific_name(genus_name = "Panthera", species_name = "leo")

# A GBIF synonym that IUCN lists under another name is resolved automatically
rl_scientific_name(genus_name = "Corvinella", species_name = "corvina")
} # }
```
