#' IUCN Red List conservation action
#'
#' Get assessment data by conservation action
#' See `actions` argument for available action codes
#'
#' @param code Character. One or more action codes
#' Use [rl_conservation_actions()] to list available action codes.
#' @inheritParams rl_biogeographical_realms
#'
#' @return Tibble of assessments for a conservation action code.
#'
#' @examples \dontrun{
#' rl_conservation_actions(code = 1,
#'                         year_published = 2024:2025,
#'                         page = 1:3)
#'}
#' @export
rl_conservation_actions <- function(code = NULL,
                                    year_published = NULL,
                                    latest = NULL,
                                    possibly_extinct = NULL,
                                    possibly_extinct_in_the_wild = NULL,
                                    scope_code = NULL,
                                    page = 1) {
  base_url <- "https://api.iucnredlist.org/api/v4/conservation_actions"

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
