#' IUCN Red List taxa by SIS ID
#'
#' Retrieve species assessments using the Species Information Service (SIS) identifier.
#' Returns summary assessment data including both latest and historic assessments.
#'
#' @param sis_id Numeric. One or more SIS identifiers for taxa.
#' @param pad_with_na Logical. If `TRUE`, pad shorter columns with `NA`.
#'
#' @return A tibble containing assessment data for the specified SIS ID(s).
#'
#' @examples \dontrun{
#' # Get assessments for species with SIS ID 179359
#' rl_sis(179359)
#'}
#' @export
rl_sis <- function(sis_id = 179359,
                   pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/sis/"

  resp <- perform_request(base_url = paste0(base_url, sis_id)) %>%
    httr2::resp_body_json() %>%
    json_to_df(pad_with_na = pad_with_na)

  return(resp)
}
