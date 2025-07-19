#' IUCN Red List threat categories
#'
#' Retrieve species assessments based on threat categories.
#' If `code = NULL`, it returns a list of available threat categories.
#' If `code` is provided, it retrieves assessments for species affected by the specified threat(s).
#'
#' @param code Character. One or more threat codes (e.g., "1").
#' Use [rl_threats()] to list available threat categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing threat categories or species assessments.
#'
#' @examples \dontrun{
#' # List all threat categories
#' rl_threats()
#'
#' # Get species affected by agriculture & aquaculture threats (code 2)
#' rl_threats(code = 2)
#'
#' # Get species affected by Climate change & severe weather threats published in 2025
#' rl_threats(
#'   code = "11",
#'   year_published = 2025
#' )
#'}
#' @export
rl_threats <- function(code = NULL,
                       year_published = NULL,
                       latest = NULL,
                       possibly_extinct = NULL,
                       possibly_extinct_in_the_wild = NULL,
                       scope_code = NULL,
                       page = 1,
                       pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/threats"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
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
    endpoint_name = "code",
    pad_with_na = pad_with_na)
}
