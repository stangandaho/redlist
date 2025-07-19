#' IUCN Red List taxa by class
#'
#' Retrieve species assessments by taxonomic class.
#' If `class_name = NULL`, it returns a list of available classes.
#' If `class_name` is provided, it retrieves assessments for species in the specified class.
#'
#' @param class_name Character. The class name (e.g., "Mammalia").
#' Use [rl_classes()] to list available classes.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing classes or species assessments.
#'
#' @examples \dontrun{
#' # List all available classes
#' rl_classes()
#'
#' # Get assessments for Mammalia class
#' rl_classes(class_name = "Mammalia")
#'
#' # Get latest Aves assessments published since 2024
#' rl_classes(
#'   class_name = "Aves",
#'   year_published = 2024:2025,
#'   latest = TRUE
#' )
#'}
#'
#' @export
rl_classes <- function(class_name = NULL,
                       year_published = NULL,
                       latest = NULL,
                       scope_code = NULL,
                       page = 1,
                       pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/class"

  if (is.null(class_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()%>%
      json_to_df(pad_with_na = pad_with_na) %>%
      t() %>% as.data.frame()
    colnames(resp) <- "class_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(class_name = class_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "class_name",
    pad_with_na = pad_with_na)
}
