#' IUCN Red List ecological systems
#'
#' Retrieve species assessments based on their ecological systems.
#' If `code = NULL`, it returns a list of available ecological systems.
#' If `code` is provided, it retrieves assessments for species in the specified system(s).
#'
#' @param code Character or Numeric. One or more system codes (e.g., "0", "1", "2").
#' Use [rl_systems()] to list available ecological systems.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing ecological systems or species assessments.
#'
#' @examples \dontrun{
#' # List all ecological systems
#' rl_systems()
#'
#' # Get terrestrial species assessments (code 0)
#' rl_systems(code = 0)
#'
#' # Get marine species assessments published since 2021
#' rl_systems(
#'   code = "2",
#'   year_published = 2021:2023
#' )
#'}
#' @export
rl_systems <- function(code = NULL,
                       year_published = NULL,
                       latest = NULL,
                       possibly_extinct = NULL,
                       possibly_extinct_in_the_wild = NULL,
                       scope_code = NULL,
                       page = 1,
                       pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/systems"

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

