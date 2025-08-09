#' IUCN Red List population trends
#'
#' Retrieve available population trend categories or species assessments for one
#' or more trends.
#'
#' This function has two modes:
#' - If `code = NULL`, it returns a list of available population trend categories.
#' - If `code` is provided, it retrieves assessments for the specified trend(s),
#' optionally filtered by year, extinction status, scope, and page(s).
#'
#' Population trends include: Increasing, Decreasing, Stable, or Unknown.
#'
#' If `page` is not specified, the function will automatically paginate over all
#' available pages for each parameter combination.
#'
#' @param code Character or Numeric. One or more population trend codes (`0`-`3`).
#' Use [rl_population_trends()] to list available trend codes and definition.
#' @inheritParams rl_biogeographical_realms
#'
#' @return A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column represents a unique API response JSON key.
#' If `code = NULL`, the tibble contains available population trend categories with columns such as code and description.
#' If `code` is provided, the tibble contains assessment data for the specified trend(s), including population trend description, 
#' population trend code, year, latest, and other relevant metadata.
#'
#' @examples \dontrun{
#' # List all available population trend categories
#' rl_population_trends()
#'
#' # Retrieve assessments for species with decreasing populations
#' rl_population_trends(code = "1")
#'
#' # Get latest decreasing population assessments from 2020
#' rl_population_trends(
#'   code = 2,
#'   year_published = 2020,
#'   latest = TRUE
#' )
#'}
#' @export
rl_population_trends <- function(code = NULL,
                                 year_published = NULL,
                                 latest = NULL,
                                 possibly_extinct = NULL,
                                 possibly_extinct_in_the_wild = NULL,
                                 scope_code = NULL,
                                 page = 1) {

  base_url <- "https://api.iucnredlist.org/api/v4/population_trends"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp))
  }

  rl_paginated_query(
    param_list = list(
      code = code,
      year_published = year_published %||% NA,
      latest = latest %||% NA,
      possibly_extinct = possibly_extinct %||% NA,
      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
      scope_code = scope_code %||% NA,
      page = page %||% NA
    ),
    base_url = base_url,
    endpoint_name = "code"
  )
}

