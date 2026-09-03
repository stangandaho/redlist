# Retrieve GBIF occurrence records for a taxon

Fetch occurrence records from the Global Biodiversity Information
Facility (GBIF) and return them as a clean `sf` POINT object ready for
the criterion B metrics
[`rl_eoo()`](https://stangandaho.github.io/redlist/reference/rl_eoo.md)
and
[`rl_aoo()`](https://stangandaho.github.io/redlist/reference/rl_aoo.md).
This uses the public GBIF search API through `rgbif`, so no GBIF
account, username, or password is needed. Only bulk downloads (the GBIF
download API) require credentials, and those are not used here.

## Usage

``` r
rl_occurrences(
  x,
  limit = 500,
  country = NULL,
  year = NULL,
  basis_of_record = NULL,
  has_coordinate = TRUE,
  has_geospatial_issue = FALSE,
  correct = NULL,
  progress = TRUE,
  crs = 4326,
  ...
)
```

## Arguments

- x:

  The taxon to retrieve. One of:

  - a scientific name, for example `"Afzelia africana"`;

  - a GBIF backbone taxon key (a number);

  - a data frame from a name resolution step (for example the output of
    [`rl_name_resolve()`](https://stangandaho.github.io/redlist/reference/rl_name_resolve.md)
    or
    [`rl_scientific_name()`](https://stangandaho.github.io/redlist/reference/rl_scientific_name.md)),
    from which a name column is detected.

- limit:

  Maximum number of records to return. Default `500`. Use `Inf` to fetch
  every available record. The search API is paged in blocks of 300
  behind the scenes, up to its ceiling of 100000 records; beyond that a
  GBIF download (which needs an account) would be required.

- country:

  Optional ISO 3166-1 alpha-2 country code to restrict records, for
  example `"BJ"` for Benin. Pass a vector for several countries (matched
  as OR), for example `c("BJ", "NG")`.

- year:

  Optional year filter. A single year (`2000`), a `"min,max"` range
  string (`"2000,2020"`, open-ended as `"2000,*"` or `"*,2000"`), or a
  comparator string (`">2025"`, `">=2025"`, `"<2000"`, `"<=2000"`). A
  range is one comma-separated string, not a vector.

- basis_of_record:

  Optional GBIF basis of record filter, for example
  `"HUMAN_OBSERVATION"` or `"PRESERVED_SPECIMEN"`. Pass a vector for
  several types (matched as OR), for example
  `c("HUMAN_OBSERVATION", "MACHINE_OBSERVATION")`.

- has_coordinate:

  Logical. Keep only records that carry coordinates. Default `TRUE`.

- has_geospatial_issue:

  Logical. Keep records that GBIF flags with a geospatial issue. Default
  `FALSE` (drop flagged records).

- correct:

  Which readiness checks from
  [`rl_check_occurrences()`](https://stangandaho.github.io/redlist/reference/rl_check_occurrences.md)
  to run after the download finishes, and apply. One of:

  - `NULL` (default): run no checks.

  - `TRUE`: run every check and drop the records behind the clear-error
    issues (`duplicates`, `outliers`, `country`, `ocean_points`,
    `centroids`).

  - a character vector of check names (for example
    `c("outliers", "duplicates")`): run those and drop the records they
    flag.

  `coordinate_precision` is always reported but never applied here,
  since dropping imprecise but real records can gut the sample and bias
  the metrics; to apply it deliberately, call
  [`rl_check_occurrences()`](https://stangandaho.github.io/redlist/reference/rl_check_occurrences.md)
  with `correct = "coordinate_precision"`. The report-only checks
  (`unique_localities`, `institution_diversity`, `recency`) are reported
  but not corrected.

  When any correction removes records the cleaned `sf` is returned;
  otherwise the readiness report is attached to the returned `sf` as its
  `"report"` attribute. For finer control (thresholds, report without
  correcting), call
  [`rl_check_occurrences()`](https://stangandaho.github.io/redlist/reference/rl_check_occurrences.md)
  directly.

- progress:

  Logical. Show a progress bar while records are downloaded. Default
  `TRUE`.

- crs:

  Coordinate reference system for the returned `sf` object. Default
  `4326` (WGS84), the system GBIF coordinates use.

- ...:

  Further named filters passed straight to
  [`rgbif::occ_search()`](https://docs.ropensci.org/rgbif/reference/occ_search.html),
  for example `continent`, `institutionCode`, `elevation`, or
  `coordinateUncertaintyInMeters`.

## Value

An `sf` POINT object (WGS84 by default) with one row per occurrence
record and the GBIF fields returned by the search, such as
`scientificName`, `eventDate`, `year`, `country`, `basisOfRecord`,
`institutionCode`, and `coordinateUncertaintyInMeters`. When no record
matches, an empty `sf` object is returned with a warning. Records with
invalid coordinates (missing, out of range, null island, or absence
records) are always dropped; further data quality checks run only when
`correct` is set.

## Details

Because records are queried by the GBIF backbone taxon key, occurrences
that GBIF indexes under synonyms of the accepted name are already
included.

## See also

[`rl_check_occurrences()`](https://stangandaho.github.io/redlist/reference/rl_check_occurrences.md),
[`rl_eoo()`](https://stangandaho.github.io/redlist/reference/rl_eoo.md),
[`rl_aoo()`](https://stangandaho.github.io/redlist/reference/rl_aoo.md),
[`rl_name_resolve()`](https://stangandaho.github.io/redlist/reference/rl_name_resolve.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# By scientific name, capped at 300 records, Benin only
occ <- rl_occurrences("Afzelia africana", limit = 300, country = "BJ")

# Pass any GBIF filter through `...`
occ <- rl_occurrences("Panthera leo", year = "2010,2020",
                      basis_of_record = "HUMAN_OBSERVATION")

# Download, then run and correct specific checks
occ <- rl_occurrences("Afzelia africana", limit = 500, country = "BJ",
                      correct = c("outliers", "duplicates"))

# Straight into a criterion B metric
rl_eoo(occ)
} # }
```
