#' Area of occupancy (AOO) for IUCN criterion B
#'
#' Compute the area of occupancy from occurrence records by counting the number
#' of occupied grid cells and multiplying by the cell area, following equation
#' 4.1 of the IUCN Red List guidelines (section 4.10). The guidelines require a
#' reference scale of 2 by 2 km cells (an area of 4 square kilometres), which is
#' the default here.
#'
#' Geographic coordinates (longitude and latitude) are projected to a local
#' Lambert azimuthal equal area system before the grid is applied, so cell sizes
#' are measured in metres regardless of the input coordinate system.
#'
#' @param x Occurrence records: an `sf` POINT object (for example the output of
#'   `rl_occurrences()`), or a data frame holding longitude and latitude
#'   columns.
#' @param coords Character vector of length two giving the longitude and
#'   latitude column names when `x` is a data frame. Default
#'   `c("longitude", "latitude")`.
#' @param crs Coordinate reference system of the input coordinates, passed to
#'   `sf`. Used only when `x` is a data frame or an `sf` object without a CRS.
#'   Default `4326` (WGS84).
#' @param cell_size Grid cell side length in metres. Default `2000` (the IUCN
#'   reference scale of 2 by 2 km). Change it only with good reason, since the
#'   criterion B2 thresholds assume this scale.
#'
#' @return A one row `sf` object whose `geometry` column holds the occupied grid
#'   cells as a MULTIPOLYGON, returned in the input coordinate system, and the
#'   columns:
#' \describe{
#'   \item{`metric`}{`"AOO"`.}
#'   \item{`area_km2`}{the area of occupancy in square kilometres.}
#'   \item{`n_records`}{the number of records used.}
#'   \item{`n_occupied_cells`}{the number of occupied grid cells.}
#'   \item{`cell_size_km`}{the cell side length in kilometres.}
#'   \item{`category_b2`}{the most threatened criterion B2 band the area reaches
#'     (`"CR"`, `"EN"` or `"VU"`), or `NA` when it reaches none. This is the
#'     spatial threshold only, not a full assessment, which also requires the
#'     criterion B subconditions.}
#' }
#'
#' @details
#' The count uses a single grid whose origin is fixed at the projected origin.
#' The guidelines note that shifting the grid can change the count and that the
#' smallest estimate should then be used; that refinement is left to the
#' assessor.
#'
#' `sf` is required and is asked for interactively when it is not installed.
#'
#' @references
#' IUCN Standards and Petitions Committee. 2024. Guidelines for Using the IUCN
#' Red List Categories and Criteria. Version 16, section 4.10.
#' \url{https://www.iucnredlist.org/documents/RedListGuidelines.pdf}
#'
#' @seealso [rl_eoo()]
#'
#' @examples \dontrun{
#' occ <- data.frame(
#'   longitude = c(2.1, 2.6, 3.0, 2.4, 2.9),
#'   latitude = c(9.1, 9.5, 9.0, 9.8, 9.3)
#' )
#' rl_aoo(occ)
#' }
#' @export
rl_aoo <- function(x, coords = c("longitude", "latitude"), crs = 4326,
                   cell_size = 2000) {
  points <- rl_prepare_points(x, coords = coords, crs = crs)
  orig_crs <- attr(points, "rl_orig_crs")

  coords_mat <- sf::st_coordinates(points)
  n_records <- nrow(coords_mat)

  # Assign each record to a grid cell of side cell_size and keep the distinct
  # occupied cells (equation 4.1 of the IUCN guidelines).
  col <- floor(coords_mat[, "X"] / cell_size)
  row <- floor(coords_mat[, "Y"] / cell_size)
  occupied <- unique(data.frame(col = col, row = row))
  n_cells <- nrow(occupied)

  cell_km2 <- (cell_size / 1000)^2
  area_km2 <- n_cells * cell_km2

  # Build the square footprint of each occupied cell and combine them into one
  # MULTIPOLYGON, then return it in the input coordinate system.
  cells <- lapply(seq_len(n_cells), function(i) {
    x0 <- occupied$col[i] * cell_size
    y0 <- occupied$row[i] * cell_size
    sf::st_polygon(list(rbind(
      c(x0, y0),
      c(x0 + cell_size, y0),
      c(x0 + cell_size, y0 + cell_size),
      c(x0, y0 + cell_size),
      c(x0, y0)
    )))
  })
  grid <- sf::st_combine(sf::st_sfc(cells, crs = sf::st_crs(points)))
  geometry <- sf::st_transform(grid, orig_crs)

  sf::st_sf(
    metric = "AOO",
    area_km2 = area_km2,
    n_records = n_records,
    n_occupied_cells = n_cells,
    cell_size_km = cell_size / 1000,
    category_b2 = rl_b2_category(area_km2),
    geometry = geometry
  )
}
