# Assessment-readiness checks for occurrence data

Run a set of data quality checks on occurrence records before they are
passed to the criterion B metrics
[`rl_eoo()`](https://stangandaho.github.io/redlist/reference/rl_eoo.md)
and
[`rl_aoo()`](https://stangandaho.github.io/redlist/reference/rl_aoo.md).
The checks flag issues that would compromise or bias the metrics. By
default nothing is removed; the function reports what it finds so the
assessor can decide how to proceed. Set `correct` to also drop the
records behind the removable issues and return the cleaned data, ready
to pass straight to
[`rl_eoo()`](https://stangandaho.github.io/redlist/reference/rl_eoo.md)
or
[`rl_aoo()`](https://stangandaho.github.io/redlist/reference/rl_aoo.md).

## Usage

``` r
rl_check_occurrences(
  x,
  coords = c("decimalLongitude", "decimalLatitude"),
  checks = NULL,
  correct = FALSE,
  recent_years = 20,
  precision_degrees = 2/111.32,
  terrestrial = TRUE,
  outlier_multiplier = 5
)
```

## Arguments

- x:

  Occurrence records: an `sf` POINT object (for example the output of
  [`rl_occurrences()`](https://stangandaho.github.io/redlist/reference/rl_occurrences.md))
  or a data frame with longitude and latitude columns.

- coords:

  Character vector of length two giving the longitude and latitude
  column names when `x` is a data frame. Default
  `c("decimalLongitude", "decimalLatitude")`.

- checks:

  Character vector selecting which checks to run. Default `NULL` runs
  every check.

- correct:

  Which removable issues to fix by dropping the offending records.
  `FALSE` (default) removes nothing and returns the report. `TRUE`
  removes every clear-error check that was run (`duplicates`,
  `outliers`, `country`, `ocean_points`, `centroids`) but not
  `coordinate_precision`, since dropping imprecise but real records is a
  completeness trade-off; name it explicitly to apply it. A character
  vector selects specific checks, including `coordinate_precision`. The
  report-only checks (`unique_localities`, `institution_diversity`,
  `recency`) describe the dataset as a whole and cannot be corrected by
  removing records.

- recent_years:

  Number of years back from today within which at least one record
  should fall. Default `20`.

- precision_degrees:

  Coordinate precision threshold in decimal degrees. Records coarser
  than this (too few decimal places, or a stated uncertainty larger than
  this distance) are flagged. The default, `2 / 111.32` (about 0.018
  degrees), corresponds to the 2 km AOO reference cell, so a record is
  flagged only when it genuinely cannot be placed in a 2 km grid cell.

- terrestrial:

  Logical. Treat the taxon as terrestrial and check for records in the
  ocean. Default `TRUE`.

- outlier_multiplier:

  Sensitivity of the outlier check: the multiplier passed to
  [`CoordinateCleaner::cc_outl()`](https://ropensci.github.io/CoordinateCleaner/reference/cc_outl.html).
  Smaller flags more points. Default `5`.

## Value

When `correct = FALSE`, a tibble with one row per check and the columns
`check`, `status` (`"pass"`, `"warn"`, `"fail"` or `"skip"`),
`n_flagged` and `detail`, returned invisibly after the results are
printed. When `correct` removes issues, the cleaned occurrences are
returned instead (same class as `x`), with the report attached as the
`"report"` attribute.

## Details

The available checks are:

- `unique_localities`:

  fewer than 3 unique localities (EOO is undefined below 3 points).
  Report only.

- `institution_diversity`:

  all records from a single institution (possible collection bias).
  Report only.

- `recency`:

  no records within the recency window (the data may be stale). Report
  only.

- `duplicates`:

  records sharing the same coordinate, event date, and institution.
  Removable.

- `coordinate_precision`:

  coordinates coarser than a threshold, from few decimal places or a
  large stated uncertainty (too imprecise for the 2 by 2 km AOO grid).
  Removable.

- `outliers`:

  spatial outliers far from the main cluster, which inflate the EOO
  convex hull. Removable. Needs `CoordinateCleaner`.

- `country`:

  coordinates that fall outside the record's stated country (sign or
  transposition errors). Removable. Needs `CoordinateCleaner` and a
  `countryCode` column.

- `ocean_points`:

  records in the ocean for a terrestrial taxon. Removable. Needs
  `CoordinateCleaner`.

- `centroids`:

  country and capital centroids, biodiversity-institution and GBIF
  headquarters coordinates, and plain zeros. Removable. Needs
  `CoordinateCleaner`.

Checks needing `CoordinateCleaner` are skipped, with a note, when it is
not installed.

## See also

[`rl_occurrences()`](https://stangandaho.github.io/redlist/reference/rl_occurrences.md),
[`rl_eoo()`](https://stangandaho.github.io/redlist/reference/rl_eoo.md),
[`rl_aoo()`](https://stangandaho.github.io/redlist/reference/rl_aoo.md)

## Examples

``` r
if (FALSE) { # \dontrun{
occ <- rl_occurrences("Afzelia africana", limit = 500, country = "BJ")

# Report only
rl_check_occurrences(occ)

# Clean and feed straight into a metric
clean_occ <- rl_check_occurrences(occ, correct = TRUE)
rl_aoo(clean_occ)
} # }
```
