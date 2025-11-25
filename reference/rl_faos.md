# FAO marine fishing areas

List or retrieve IUCN Red List assessments for FAO Marine Fishing Areas.

## Usage

``` r
rl_faos(
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

  Character. One or more FAO region codes (e.g. "21", "27"). Use
  `rl_faos()` with no arguments to list available FAO region codes.

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
contains available FAO region codes and their descriptions. If `code` is
provided, the tibble contains assessment data for the specified FAO
region(s), including description, taxon details, red list category,
year, and other relevant metadata.

## Details

If `code` is `NULL`, this returns the available FAO region codes and
their descriptions. If a `code` (or multiple codes) is provided,
retrieves the IUCN assessments for those regions.

## Examples

``` r
if (FALSE) { # \dontrun{
# List available FAO regions
rl_faos()

# Get assessments for FAO region 27
rl_faos(code = "27")

# Get assessments for regions 21 and 27 on page 1
rl_faos(code = c("21", "27"), page = 1)
} # }
```
