# Resolve a scientific name to the accepted IUCN Red List name

When you work with names from another source (for example GBIF), some
names differ from the ones the IUCN Red List uses, so a direct request
such as
[`rl_scientific_name()`](https://stangandaho.github.io/redlist/reference/rl_scientific_name.md)
returns *404 (species not found)*. This function forces a match: it
verifies the name against the [GlobalNames
Verifier](https://verifier.globalnames.org/apidoc) API and returns the
accepted (current) name the IUCN Red List uses, so the retrieval can be
repeated with the resolved name.

## Usage

``` r
rl_name_resolve(
  genus_name,
  species_name,
  infra_name = NULL,
  subpopulation_name = NULL,
  vernaculars = "all",
  data_sources = 163,
  all_matches = FALSE,
  capitalize = FALSE,
  species_group = FALSE,
  fuzzy_uninomial = FALSE,
  stats = FALSE,
  main_taxon_threshold = 0.6
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

- vernaculars:

  Character. Vernacular-name languages to return, as `"|"`-separated ISO
  639-3 codes (e.g. "eng\|rus\|deu" for multiple languages), or `"all"`
  for every language found. Default `"all"`.

- data_sources:

  Integer vector of GlobalNames data-source ids to match against.
  Default `163` for IUCN. See
  <https://verifier.globalnames.org/data_sources> for the full list.

- all_matches:

  Logical. If `TRUE`, return every match found instead of only the best
  one. Default `FALSE`.

- capitalize:

  Logical. Capitalize the first letter of the name before matching.
  Default `FALSE`.

- species_group:

  Logical. Expand the search to the species group where applicable.
  Default `FALSE`.

- fuzzy_uninomial:

  Logical. Allow fuzzy matching for uninomial names. Default `FALSE`.

- stats:

  Logical. Ask the API to find the kingdom and main taxon holding most
  names (Catalogue of Life only). Default `FALSE`.

- main_taxon_threshold:

  Numeric between 0.5 and 1 setting the minimal proportion for
  main-taxon discovery. Default `0.6`.

## Value

A tibble with one row per input name. A name that cannot be matched
returns a single row of `NA` fields.

## See also

[`rl_scientific_name()`](https://stangandaho.github.io/redlist/reference/rl_scientific_name.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# GBIF's "Corvinella corvina" is a synonym; IUCN uses "Lanius corvinus"
rl_name_resolve(genus_name = "Corvinella", species_name = "corvina")
} # }
```
