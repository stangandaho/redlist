# IUCN Red List biogeographical realms

Retrieve available biogeographical realms or detailed species
assessments for one or more realms.

## Usage

``` r
rl_biogeographical_realms(
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

  Numeric or Character. One or more biogeographical realm codes (e.g.
  `0` or `"0"`). Use `rl_biogeographical_realms()` to list available
  realms.

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

A tibble (class
``` tbl_df``,  ```tbl`, `data.frame`) where each column represents a unique API response JSON key. If `code
=
NULL`, the tibble contains available biogeographical realms with columns such as realm code and name. If `code\`
is provided, the tibble contains assessment data for the specified
realm(s), including taxon details, red list category, year, and other
relevant metadata.

## Details

This function has two modes:

- If `code = NULL`, it returns a list of available biogeographical
  realms.

- If `code` is provided, it retrieves assessments for the specified
  realm(s), optionally filtered by year, extinction status, scope, and
  page(s).

If `page` is not specified, the function will automatically paginate
over all available pages for each parameter combination.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all available biogeographical realms
rl_biogeographical_realms()

# Retrieve all assessments for realm code 0
rl_biogeographical_realms(code = 0)

# Get latest assessments from multiple pages with filters
rl_biogeographical_realms(
  code = 0,
  year_published = c(2020, 2021),
  page = c(1, 2)
)
} # }
```
