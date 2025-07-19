#' IUCN Red List taxa by family
#'
#' Retrieve species assessments by taxonomic family.
#' If `family_name = NULL`, it returns a list of available families.
#' If `family_name` is provided, it retrieves assessments for species in the specified family.
#'
#' @param family_name Character. The family name (e.g., "Felidae").
#' Use [rl_family()] to list available families.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing families or species assessments.
#'
#' @examples \dontrun{
#' # List all available families
#' rl_family()
#'
#' # Get assessments for Felidae family
#' rl_family(family_name = "Felidae")
#'
#' # Get latest Canidae assessments published from 2019 to 2022
#' rl_family(
#'   family_name = "Canidae",
#'   year_published = 2019:2022,
#'   latest = TRUE
#' )
#'}
#' @export
rl_family <- function(family_name = NULL,
                      year_published = NULL,
                      latest = NULL,
                      scope_code = NULL,
                      page = 1,
                      pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/family"

  if (is.null(family_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()%>%
      json_to_df(pad_with_na = pad_with_na) %>%
      t() %>% as.data.frame()
    colnames(resp) <- "family_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(family_name = family_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "family_name",
    pad_with_na = pad_with_na)
}
