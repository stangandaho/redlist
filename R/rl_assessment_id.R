#' IUCN Red List assessment
#'
#' Retrieves an assessment
#'
#' @param assessment_id Appeasement ID
#' @param pad_with_na Logical; if `TRUE`, columns with unequal lengths will be padded with `NA`
#'        so that all columns have the same number of rows. If `FALSE`, each column will retain
#'        its raw structure, and content will be collapsed only when necessary.
#'
#' @return Returns assessment data for a supplied assessment_id.
#'
#' @examples
#' \dontrun{
#' rl_assessment_id(1425064)
#' }
#'
#' @export
rl_assessment_id <- function(assessment_id = 1425064, pad_with_na = FALSE) {
  suppressMessages(rl_check_api())

  base_url <- paste0("https://api.iucnredlist.org/api/v4/assessment/", assessment_id)
  ass_id <- perform_request(base_url = base_url) %>%
    httr2::resp_body_json()

  return(json_to_df(ass_id, pad_with_na = pad_with_na))

}
