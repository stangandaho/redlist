#' Extent of occurrence (EOO) for IUCN criterion B
#'
#' Compute the extent of occurrence from occurrence records as the area of the
#' minimum convex polygon (convex hull) that encloses all points, following the
#' IUCN Red List guidelines (section 4.9). The convex hull is the method the
#' guidelines recommend for assessing the spatial thresholds of criterion B1.
#'
#' Geographic coordinates (longitude and latitude) are projected to a local
#' Lambert azimuthal equal area system before the area is measured, so the
#' result is returned in square kilometres regardless of the input coordinate
#' system.
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
#'
#' @return A one row `sf` object with the convex hull in its `geometry` column
#'   (an empty polygon when fewer than three unique locations are available),
#'   returned in the input coordinate system, and the columns:
#' \describe{
#'   \item{`metric`}{`"EOO"`.}
#'   \item{`area_km2`}{the extent of occurrence in square kilometres, or `NA`
#'     when fewer than three unique locations are available.}
#'   \item{`n_records`}{the number of records used.}
#'   \item{`n_unique`}{the number of unique locations.}
#'   \item{`method`}{the estimation method, `"convex hull"`.}
#'   \item{`category_b1`}{the most threatened criterion B1 band the area reaches
#'     (`"CR"`, `"EN"` or `"VU"`), or `NA` when it reaches none (the area exceeds
#'     every band, or the metric is undefined). This is the spatial threshold
#'     only, not a full assessment, which also requires the criterion B
#'     subconditions.}
#' }
#'
#' @details
#' The extent of occurrence is undefined with fewer than three unique locations,
#' since a polygon cannot be drawn; in that case `area_km2` is `NA` and a warning
#' is issued. The guidelines also state that when EOO is smaller than AOO it
#' should be raised to equal AOO; that adjustment is left to the assessor and is
#' not applied here.
#'
#' `sf` is required and is asked for interactively when it is not installed.
#'
#' @references
#' IUCN Standards and Petitions Committee. 2024. Guidelines for Using the IUCN
#' Red List Categories and Criteria. Version 16, section 4.9.
#' \url{https://www.iucnredlist.org/documents/RedListGuidelines.pdf}
#'
#' @seealso [rl_aoo()]
#'
#' @examples \dontrun{
#' occ <- data.frame(
#'   longitude = c(2.1, 2.6, 3.0, 2.4, 2.9),
#'   latitude = c(9.1, 9.5, 9.0, 9.8, 9.3)
#' )
#' rl_eoo(occ)
#' }
#' @export
rl_eoo <- function(x, coords = c("longitude", "latitude"), crs = 4326) {
  points <- rl_prepare_points(x, coords = coords, crs = crs)
  orig_crs <- attr(points, "rl_orig_crs")

  coords_mat <- sf::st_coordinates(points)
  n_records <- nrow(coords_mat)
  n_unique <- nrow(unique(coords_mat[, c("X", "Y"), drop = FALSE]))

  if (n_unique < 3) {
    cli::cli_warn(c(
      "EOO needs at least 3 unique locations, but {n_unique} {?was/were} found.",
      i = "The extent of occurrence is undefined and reported as {.val NA}."
    ))
    empty <- sf::st_sfc(sf::st_polygon(), crs = orig_crs)
    return(sf::st_sf(
      metric = "EOO",
      area_km2 = NA_real_,
      n_records = n_records,
      n_unique = n_unique,
      method = "convex hull",
      category_b1 = NA_character_,
      geometry = empty
    ))
  }

  hull <- sf::st_convex_hull(sf::st_union(points))
  area_km2 <- as.numeric(sf::st_area(hull)) / 1e6
  geometry <- sf::st_transform(hull, orig_crs)

  sf::st_sf(
    metric = "EOO",
    area_km2 = area_km2,
    n_records = n_records,
    n_unique = n_unique,
    method = "convex hull",
    category_b1 = rl_b1_category(area_km2),
    geometry = geometry
  )
}
