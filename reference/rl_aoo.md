# Area of occupancy (AOO) for IUCN criterion B

Compute the area of occupancy from occurrence records by counting the
number of occupied grid cells and multiplying by the cell area,
following equation 4.1 of the IUCN Red List guidelines (section 4.10).
The guidelines require a reference scale of 2 by 2 km cells (an area of
4 square kilometres), which is the default here.

## Usage

``` r
rl_aoo(x, coords = c("longitude", "latitude"), crs = 4326, cell_size = 2000)
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

- cell_size:

  Grid cell side length in metres. Default `2000` (the IUCN reference
  scale of 2 by 2 km). Change it only with good reason, since the
  criterion B2 thresholds assume this scale.

## Value

A one row `sf` object whose `geometry` column holds the occupied grid
cells as a MULTIPOLYGON, returned in the input coordinate system, and
the columns:

- `metric`:

  `"AOO"`.

- `area_km2`:

  the area of occupancy in square kilometres.

- `n_records`:

  the number of records used.

- `n_occupied_cells`:

  the number of occupied grid cells.

- `cell_size_km`:

  the cell side length in kilometres.

- `category_b2`:

  the most threatened criterion B2 band the area reaches (`"CR"`, `"EN"`
  or `"VU"`), or `NA` when it reaches none. This is the spatial
  threshold only, not a full assessment, which also requires the
  criterion B subconditions.

## Details

Geographic coordinates (longitude and latitude) are projected to a local
Lambert azimuthal equal area system before the grid is applied, so cell
sizes are measured in metres regardless of the input coordinate system.

The count uses a single grid whose origin is fixed at the projected
origin. The guidelines note that shifting the grid can change the count
and that the smallest estimate should then be used; that refinement is
left to the assessor.

`sf` is required and is asked for interactively when it is not
installed.

## References

IUCN Standards and Petitions Committee. 2024. Guidelines for Using the
IUCN Red List Categories and Criteria. Version 16, section 4.10.
<https://www.iucnredlist.org/documents/RedListGuidelines.pdf>

## See also

[`rl_eoo()`](https://stangandaho.github.io/redlist/reference/rl_eoo.md)

## Examples

``` r
if (FALSE) { # \dontrun{
occ <- data.frame(
  longitude = c(2.1, 2.6, 3.0, 2.4, 2.9),
  latitude = c(9.1, 9.5, 9.0, 9.8, 9.3)
)
rl_aoo(occ)
} # }
```
