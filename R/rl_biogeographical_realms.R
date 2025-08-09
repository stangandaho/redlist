#' IUCN Red List biogeographical realms
#'
#' Retrieve available biogeographical realms or detailed species assessments for one or more realms.
#'
#' This function has two modes:
#' - If `code = NULL`, it returns a list of available biogeographical realms.
#' - If `code` is provided, it retrieves assessments for the specified realm(s),
#' optionally filtered by year, extinction status, scope, and page(s).
#'
#' If `page` is not specified, the function will automatically paginate over all
#' available pages for each parameter combination.
#'
#' @param code Numeric or Character. One or more biogeographical realm codes (e.g. `0` or `"0"`).
#' Use [rl_biogeographical_realms()] to list available realms.
#' @param year_published Optional. Single or numeric vector of years to filter assessments by publication year.
#' @param latest Optional. Logical. If `TRUE`, return only the latest assessment per species.
#' @param possibly_extinct Optional. Logical. Filter for species flagged as possibly extinct.
#' @param possibly_extinct_in_the_wild Optional. Logical. Filter for species possibly extinct in the wild.
#' @param scope_code Optional. Integer One or more scope codes to filter assessments.
#' @param page Optional. Integer vector. Specify one or more page numbers to fetch.
#' If `NULL` or `NA`, all pages will be fetched automatically.
#'
#' @return A tibble (class `tbl_df``, `tbl`, `data.frame`) where each column represents a unique API response JSON key.
#' If `code = NULL`, the tibble contains available biogeographical realms with columns such as realm code and name.
#' If `code` is provided, the tibble contains assessment data for the specified realm(s), including taxon details,
#' red list category, year, and other relevant metadata.
#'
#' @examples \dontrun{
#' # List all available biogeographical realms
#' rl_biogeographical_realms()
#'
#' # Retrieve all assessments for realm code 0
#' rl_biogeographical_realms(code = 0)
#'
#' # Get latest assessments from multiple pages with filters
#' rl_biogeographical_realms(
#'   code = 0,
#'   year_published = c(2020, 2021),
#'   page = c(1, 2)
#' )
#' }
#'
#' @export
rl_biogeographical_realms <- function(code = NULL,
                                      year_published = NULL,
                                      latest = NULL,
                                      possibly_extinct = NULL,
                                      possibly_extinct_in_the_wild = NULL,
                                      scope_code = NULL,
                                      page = 1) {
  suppressMessages(rl_check_api())

  base_url <- "https://api.iucnredlist.org/api/v4/biogeographical_realms"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp))
  }

  # Build param list for expand.grid
  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "name")

}

