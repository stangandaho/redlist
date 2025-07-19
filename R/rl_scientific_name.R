#' IUCN Red List taxa by scientific name
#'
#' Retrieve species assessments using scientific names (Latin binomials).
#' Returns summary assessment data including both latest and historic assessments.
#'
#' @param genus_name Character. The genus name (required).
#' @param species_name Character. The species name (required).
#' @param infra_name Character. The infraspecific name (optional).
#' @param subpopulation_name Character. The subpopulation name (optional).
#' @param pad_with_na Logical. If `TRUE`, pad shorter columns with `NA`.
#'
#' @return A tibble containing assessment data for the specified taxon.
#'
#' @examples \dontrun{
#' # Get assessments for Panthera leo (lion)
#' rl_scientific_name(genus_name = "Panthera", species_name = "leo")
#'}
#' @export
rl_scientific_name <- function(genus_name,
                               species_name,
                               infra_name = NULL,
                               subpopulation_name = NULL,
                               pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/scientific_name"

  # Build query parameters
  query_params <- list(
    genus_name = genus_name,
    species_name = species_name,
    infra_name = infra_name %||% NULL,
    subpopulation_name = subpopulation_name %||% NULL
  )

  resp <- perform_request(base_url = base_url, params = query_params) %>%
    httr2::resp_body_json()

  return(json_to_df(resp, pad_with_na = pad_with_na))
}
