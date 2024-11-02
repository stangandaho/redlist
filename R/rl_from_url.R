#' Retrieve IUCN Red List Assessments from URLs
#'
#' This function retrieves one or multiple IUCN Red List species assessments from their URL. The assessment ID
#' is extracted from the URL.
#'
#' @param urls Character vector. A vector of URLs pointing to specific IUCN Red List species assessments.
#' @param verbose Logical. If TRUE, prints progress messages for each assessment being retrieved. Defaults to TRUE.
#'
#' @return A data frame combining all the species assessment data retrieved, with the same fields as
#'   [rl_from_assessment_id()].
#'
#' @details
#' The function parses each URL to extract the assessment ID, then calls `rl_from_assessment_id` for each
#' ID to fetch and compile assessment data. A one-second delay is added between API calls to avoid rate-limiting.
#'
#' @note Requires an IUCN Red List API token to be set as an environment variable under `redlist_api`.
#'
#' @examples
#' \dontrun{
#'   # Retrieve multiple assessments using a vector of URLs
#'   urls <- c("https://api.iucnredlist.org/api/v4/assessment/1234567",
#'             "https://api.iucnredlist.org/api/v4/assessment/7654321")
#'   rl_from_url(urls)
#' }
#'
#' @import httr2
#' @import dplyr
#' @export

rl_from_url <- function(urls, verbose = TRUE){

  assessment_ids <- lapply(strsplit(urls, "/"),
                           function(x){
                             x[length(x)]
                           })

  all_assessment <- list(); lvl <- 0
  for (ass_id in assessment_ids) {
    lvl <- lvl + 1
    if (verbose) {message(noquote(paste0("On id ", lvl, "/", length(assessment_ids))))}

    ass <- rl_from_assessment_id(assessment_id = ass_id)
    all_assessment[[ass_id]] <- ass
    Sys.sleep(1)
  }
  all_assessment <- dplyr::bind_rows(all_assessment)
}
