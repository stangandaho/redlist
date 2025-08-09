#' IUCN Red List Comprehensive groups
#'
#' Get assessment data by comprehensive group name (e.g `amphibians`,
#' `mammals`, `birds`, `blennies`, `mangrove_plants`, `reptiles`,
#' `insects`, `fishes`, etc).
#' See `name` argument for available group names.
#'
#' @param name Character. One or more group names.
#' Use [rl_comprehensive_groups()] to list available group names.
#' @inheritParams rl_biogeographical_realms
#'
#' @return A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column represents a unique API response JSON key. 
#' If `name = NULL`, the tibble contains available comprehensive group names. 
#' If `name` is provided, the tibble contains assessment data for the specified group(s), including taxon details, red list category, year,
#'and other relevant metadata.
#' @examples \dontrun{
#' rl_comprehensive_groups(name = "amphibians",
#'                         year_published = 2024:2025,
#'                         page = 1:3)
#'}
#' @export
rl_comprehensive_groups <- function(name = NULL,
                                    year_published = NULL,
                                    latest = NULL,
                                    possibly_extinct = NULL,
                                    possibly_extinct_in_the_wild = NULL,
                                    scope_code = NULL,
                                    page = 1) {
  base_url <- "https://api.iucnredlist.org/api/v4/comprehensive_groups"

  if (is.null(name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp))
  }

  rl_paginated_query(
    param_list = list(name = name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "name")

}
