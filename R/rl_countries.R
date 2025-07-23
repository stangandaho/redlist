#' Retrieve IUCN Red List assessments by country
#'
#' Retrieves the species assessed by the IUCN for a specified countries.
#' See `code` argument for available countries codes
#'
#' @param code Character. One or more countries codes
#' Use [rl_countries()] to list available countries codes.
#' @inheritParams rl_biogeographical_realms
#'
#' @return Tibble of assessments for a given country ISO alpha-2 code.
#'
#' @examples \dontrun{
#'   # Retrieve assessments for Benin (country code "BJ") for the year 2020
#'   rl_countries("BJ", year = 2020)
#'
#'   # Retrieve all assessments for Brazil (country code "BR")
#'   rl_countries("BR", page = 2)
#'
#'   # Retrieve assessments for Canada (country code "CA") on specific pages
#'   rl_countries("CA", page = c(1, 2))
#'}
#' @export
rl_countries <- function(code = NULL,
                         year_published = NULL,
                         latest = NULL,
                         possibly_extinct = NULL,
                         possibly_extinct_in_the_wild = NULL,
                         scope_code = NULL,
                         page = 1) {
  base_url <- "https://api.iucnredlist.org/api/v4/countries"

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
