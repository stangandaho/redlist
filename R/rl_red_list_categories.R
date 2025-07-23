#' IUCN Red List Categories
#'
#' Retrieve species assessments based on their Red List threat categories.
#' If `code = NULL`, it returns a list of available Red List categories.
#' If `code` is provided, it retrieves assessments for species in the specified category(ies).
#'
#' @param code Character. One or more Red List category codes (e.g., "CR", "EN").
#' Use [rl_red_list_categories()] to list available categories.
#' @inheritParams rl_biogeographical_realms
#'
#' @return A tibble containing Red List categories or species assessments.
#'
#' @examples \dontrun{
#' # List all Red List categories
#' rl_red_list_categories()
#'
#' # Get Critically Endangered species assessments
#' rl_red_list_categories(code = "CR")
#'
#' # Get Vulnerable species assessments published in 2020
#' rl_red_list_categories(
#'   code = "VU",
#'   year_published = 2020
#' )
#'}
#' @export
rl_red_list_categories <- function(code = NULL,
                                   year_published = NULL,
                                   latest = NULL,
                                   possibly_extinct = NULL,
                                   possibly_extinct_in_the_wild = NULL,
                                   scope_code = NULL,
                                   page = 1) {

  base_url <- "https://api.iucnredlist.org/api/v4/red_list_categories"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code")
}
