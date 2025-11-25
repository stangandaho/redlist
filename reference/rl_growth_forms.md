# Growth forms

Retrieve IUCN Red List assessments by growth form.

## Usage

``` r
rl_growth_forms(
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

  Character. One or more growth form codes (e.g. "TREE", "SHRUB"). Use
  `rl_growth_forms()` with no arguments to list available growth form
  codes.

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
contains available growth form codes and their descriptions. If `code`
is provided, the tibble contains assessment data for the specified
growth form(s), including year, taxon details, and other relevant
metadata.

## Details

If `code` is `NULL`, this returns the available growth form codes and
their descriptions. If a `code` (or multiple codes) is provided,
retrieves the IUCN assessments for those growth forms.

## Examples

``` r
if (FALSE) { # \dontrun{
# List available growth form codes
rl_growth_forms()

# Get assessments for tree growth form (e.g Geophyte)
rl_growth_forms(code = "GE")

# Get assessments for multiple growth forms (e.g Hydrophyte, Lithophyte)
rl_growth_forms(code = c("H", "L"), page = c(1, 2))
} # }
```
