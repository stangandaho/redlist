#' Growth forms
#'
#' Retrieve IUCN Red List assessments by growth form.
#'
#' If `code` is `NULL`, this returns the available growth form codes and their descriptions.
#' If a `code` (or multiple codes) is provided, retrieves the IUCN assessments for those growth forms.
#'
#' @param code Character. One or more growth form codes (e.g. "TREE", "SHRUB").
#' Use `rl_growth_forms()` with no arguments to list available growth form codes.
#' @inheritParams rl_biogeographical_realms
#'
#' @return A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column represents a unique API response JSON key. 
#' If `code = NULL`, the tibble contains available growth form codes and their descriptions. 
#' If `code` is provided, the tibble contains assessment data for the specified growth form(s), including 
#' year, taxon details, and other relevant metadata.
#'
#' @examples \dontrun{
#' # List available growth form codes
#' rl_growth_forms()
#'
#' # Get assessments for tree growth form (e.g Geophyte)
#' rl_growth_forms(code = "GE")
#'
#' # Get assessments for multiple growth forms (e.g Hydrophyte, Lithophyte)
#' rl_growth_forms(code = c("H", "L"), page = c(1, 2))
#'}
#' @export
rl_growth_forms <- function(code = NULL,
                            year_published = NULL,
                            latest = NULL,
                            possibly_extinct = NULL,
                            possibly_extinct_in_the_wild = NULL,
                            scope_code = NULL,
                            page = 1) {
  base_url <- "https://api.iucnredlist.org/api/v4/growth_forms"

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
    endpoint_name = "code"
  )
}

