#' IUCN Red List assessment scopes
#'
#' Retrieve species assessments based on their geographic assessment scopes.
#' If `code = NULL`, it returns a list of available assessment scopes.
#' If `code` is provided, it retrieves assessments for the specified scope(s).
#'
#' @param code Character or Numeric. One or more scope codes (e.g., "1", "2").
#' Use [rl_scopes()] to list available scope categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing assessment scopes or species assessments.
#'
#' @examples \dontrun{
#' # List all assessment scopes
#' rl_scopes()
#'
#' # Get globally assessed species (code 1)
#' rl_scopes(code = "1")
#'
#' # Get Pan-Africa species assessed species published since 2020
#' rl_scopes(
#'   code = "2",
#'   year_published = 2020:2023
#' )
#'}
#' @export
rl_scopes <- function(code = NULL,
                      year_published = NULL,
                      latest = NULL,
                      possibly_extinct = NULL,
                      possibly_extinct_in_the_wild = NULL,
                      scope_code = scope_code %||% NA,
                      page = 1) {

  base_url <- "https://api.iucnredlist.org/api/v4/scopes"

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
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code")
}

