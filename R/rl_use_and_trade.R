#' IUCN Red List use and trade categories
#'
#' Retrieve species assessments based on use and trade categories.
#' If `code = NULL`, it returns a list of available use and trade categories.
#' If `code` is provided, it retrieves assessments for species affected by the specified use/trade category(ies).
#'
#' @param code Character. One or more use/trade codes (e.g., "1", "5_2").
#' Use [rl_use_and_trade()] to list available categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing use/trade categories or species assessments.
#'
#' @examples \dontrun{
#' # List all use and trade categories
#' rl_use_and_trade()
#'
#' # Get species used for food - human (code 1)
#' rl_use_and_trade(code = "1")
#'
#' # Get species hunted for Sport hunting/specimen collecting published in 2024
#' rl_use_and_trade(
#'   code = "15",
#'   year_published = 2024
#' )
#'}
#' @export
rl_use_and_trade <- function(code = NULL,
                             year_published = NULL,
                             latest = NULL,
                             possibly_extinct = NULL,
                             possibly_extinct_in_the_wild = NULL,
                             scope_code = NULL,
                             page = 1) {
  suppressMessages(rl_check_api())

  base_url <- "https://api.iucnredlist.org/api/v4/use_and_trade"

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
