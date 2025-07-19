#' IUCN Red List taxa by kingdom
#'
#' Retrieve species assessments by kingdom.
#' If `kingdom_name = NULL`, it returns a list of available kingdoms.
#' If `kingdom_name` is provided, it retrieves assessments for species in the specified kingdom.
#'
#' @param kingdom_name Character. The kingdom name (e.g., "Animalia").
#' Use [rl_kingdoms()] to list available kingdoms.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing kingdoms or species assessments.
#'
#' @examples \dontrun{
#' # List all available kingdoms
#' rl_kingdoms()
#'
#' # Get assessments for species in Animalia kingdom
#' rl_kingdoms(kingdom_name = "Animalia")
#'
#' # Get latest assessments for Plantae published in 2021
#' rl_kingdoms(
#'   kingdom_name = "Plantae",
#'   year_published = 2021,
#'   latest = TRUE
#' )
#'}
#' @export
rl_kingdoms <- function(kingdom_name = NULL,
                        year_published = NULL,
                        latest = NULL,
                        scope_code = NULL,
                        page = 1,
                        pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/kingdom"

  if (is.null(kingdom_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()%>%
      json_to_df(pad_with_na = pad_with_na) %>%
      t() %>% as.data.frame()
    colnames(resp) <- "kingdom_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(kingdom_name = kingdom_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "kingdom_name",
    pad_with_na = pad_with_na)
}
