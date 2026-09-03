# Extent of occurrence (EOO) for IUCN criterion B

Compute the extent of occurrence from occurrence records as the area of
the minimum convex polygon (convex hull) that encloses all points,
following the IUCN Red List guidelines (section 4.9). The convex hull is
the method the guidelines recommend for assessing the spatial thresholds
of criterion B1.

## Usage

``` r
rl_eoo(x, coords = c("longitude", "latitude"), crs = 4326)
```

## Arguments

- x:

  Occurrence records: an `sf` POINT object (for example the output of
  [`rl_occurrences()`](https://stangandaho.github.io/redlist/reference/rl_occurrences.md)),
  or a data frame holding longitude and latitude columns.

- coords:

  Character vector of length two giving the longitude and latitude
  column names when `x` is a data frame. Default
  `c("longitude", "latitude")`.

- crs:

  Coordinate reference system of the input coordinates, passed to `sf`.
  Used only when `x` is a data frame or an `sf` object without a CRS.
  Default `4326` (WGS84).

## Value

A one row `sf` object with the convex hull in its `geometry` column (an
empty polygon when fewer than three unique locations are available),
returned in the input coordinate system, and the columns:

- `metric`:

  `"EOO"`.

- `area_km2`:

  the extent of occurrence in square kilometres, or `NA` when fewer than
  three unique locations are available.

- `n_records`:

  the number of records used.

- `n_unique`:

  the number of unique locations.

- `method`:

  the estimation method, `"convex hull"`.

- `category_b1`:

  the most threatened criterion B1 band the area reaches (`"CR"`, `"EN"`
  or `"VU"`), or `NA` when it reaches none (the area exceeds every band,
  or the metric is undefined). This is the spatial threshold only, not a
  full assessment, which also requires the criterion B subconditions.

## Details

Geographic coordinates (longitude and latitude) are projected to a local
Lambert azimuthal equal area system before the area is measured, so the
result is returned in square kilometres regardless of the input
coordinate system.

The extent of occurrence is undefined with fewer than three unique
locations, since a polygon cannot be drawn; in that case `area_km2` is
`NA` and a warning is issued. The guidelines also state that when EOO is
smaller than AOO it should be raised to equal AOO; that adjustment is
left to the assessor and is not applied here.

`sf` is required and is asked for interactively when it is not
installed.

## References

IUCN Standards and Petitions Committee. 2024. Guidelines for Using the
IUCN Red List Categories and Criteria. Version 16, section 4.9.
<https://www.iucnredlist.org/documents/RedListGuidelines.pdf>

## See also

[`rl_aoo()`](https://stangandaho.github.io/redlist/reference/rl_aoo.md)

## Examples

``` r
if (FALSE) { # \dontrun{
occ <- data.frame(
  longitude = c(2.1, 2.6, 3.0, 2.4, 2.9),
  latitude = c(9.1, 9.5, 9.0, 9.8, 9.3)
)
rl_eoo(occ)
} # }
```
