#' IUCN Red List taxa by phylum
#'
#' Retrieve species assessments by phylum.
#' If `phylum_name = NULL`, it returns a list of available phyla.
#' If `phylum_name` is provided, it retrieves assessments for species in the specified phylum.
#'
#' @param phylum_name Character. The phylum name (e.g., "Chordata").
#' Use [rl_phylum()] to list available phyla.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing phyla or species assessments.
#'
#' @examples \dontrun{
#' # List all available phyla
#' rl_phylum()
#'
#' # Get assessments for species in Chordata phylum
#' rl_phylum(phylum_name = "Chordata")
#'
#' # Get latest assessments for Arthropoda published in 2020
#' rl_phylum(
#'   phylum_name = "Arthropoda",
#'   year_published = 2020,
#'   latest = TRUE
#' )
#'}
#' @export
rl_phylum <- function(phylum_name = NULL,
                      year_published = NULL,
                      latest = NULL,
                      scope_code = NULL,
                      page = 1) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/phylum"

  if (is.null(phylum_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json() %>%
      json_to_df() %>%
      t() %>% as.data.frame()
    colnames(resp) <- "phylum_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(phylum_name = phylum_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "phylum_name")
}
