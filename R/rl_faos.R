#' FAO marine fishing areas
#'
#' List or retrieve IUCN Red List assessments for FAO Marine Fishing Areas.
#'
#' If `code` is `NULL`, this returns the available FAO region codes and their descriptions.
#' If a `code` (or multiple codes) is provided, retrieves the IUCN assessments for those regions.
#'
#' @param code Character. One or more FAO region codes (e.g. "21", "27").
#' Use `rl_faos()` with no arguments to list available FAO region codes.
#' @inheritParams rl_biogeographical_realms
#'
#' @return A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column represents a unique API response JSON key. 
#' If `code = NULL`, the tibble contains available FAO region codes and their descriptions. 
#' If `code` is provided, the tibble contains assessment data for the specified FAO region(s), including description, taxon details, 
#' red list category, year, and other relevant metadata.
#' 
#' @examples \dontrun{
#' # List available FAO regions
#' rl_faos()
#'
#' # Get assessments for FAO region 27
#' rl_faos(code = "27")
#'
#' # Get assessments for regions 21 and 27 on page 1
#' rl_faos(code = c("21", "27"), page = 1)
#'}
#' @export
rl_faos <- function(code = NULL,
                    year_published = NULL,
                    latest = NULL,
                    possibly_extinct = NULL,
                    possibly_extinct_in_the_wild = NULL,
                    scope_code = NULL,
                    page = 1) {
  base_url <- "https://api.iucnredlist.org/api/v4/faos"

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


