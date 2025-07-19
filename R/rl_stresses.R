#' IUCN Red List stress categories
#'
#' Retrieve species assessments based on stress categories affecting species.
#' If `code = NULL`, it returns a list of available stress categories.
#' If `code` is provided, it retrieves assessments for species affected by the specified stress(es).
#'
#' @param code Character or Numeric. One or more stress codes (e.g., "1", "2_1").
#' Use [rl_stresses()] to list available stress categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing stress categories or species assessments.
#'
#' @examples \dontrun{
#' # List all stress categories
#' rl_stresses()
#'
#' # Get species affected by ecosystem stresses (code 1)
#' rl_stresses(code = "1") # or code = 1
#'
#' # Get species affected by competition stresses published since 2020
#' rl_stresses(
#'   code = "2_3_2",
#'   year_published = 2020:2023
#' )
#'}
#' @export
rl_stresses <- function(code = NULL,
                        year_published = NULL,
                        latest = NULL,
                        possibly_extinct = NULL,
                        possibly_extinct_in_the_wild = NULL,
                        scope_code = NULL,
                        page = 1,
                        pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/stresses"

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
