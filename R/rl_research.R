#' IUCN Red List research categories
#'
#' Retrieve species assessments based on their research needs categories.
#' If `code = NULL`, it returns a list of available research categories.
#' If `code` is provided, it retrieves assessments for species with the specified research need(s).
#'
#' @param code Character Or Numeric. One or more research category codes (e.g., "1", "2").
#' Use [rl_research()] to list available research categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column represents a unique API response JSON key.
#' If `code = NULL`, the tibble contains available research categories with columns such as code and description.
#' If `code` is provided, the tibble contains assessment data for the specified research need(s), including description, 
#' research code, year, taxon details, and other relevant metadata.
#'
#' @examples \dontrun{
#' # List all research categories
#' rl_research()
#'
#' # Get species needing population trends research (code 3_1)
#' rl_research(code = "3_1")
#'
#' # Get species needing life history & ecology research published since 2019
#' rl_research(
#'   code = "1_3",
#'   year_published = 2019:2023
#' )
#'}
#' @export
rl_research <- function(code = NULL,
                        year_published = NULL,
                        latest = NULL,
                        possibly_extinct = NULL,
                        possibly_extinct_in_the_wild = NULL,
                        scope_code = NULL,
                        page = 1) {

  base_url <- "https://api.iucnredlist.org/api/v4/research"

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
