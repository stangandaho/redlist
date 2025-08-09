#' Green status
#'
#' Retrieve all IUCN Green Status assessments.
#' @return A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column represents a unique API response JSON key. 
#' The columns include key information about the Green Status assessment, such as year, weights, justification, and
#' other relevant metadata.
#' 
#' @examples \dontrun{
#' rl_green_status()
#'}
#' @export
rl_green_status <- function() {
  base_url <- "https://api.iucnredlist.org/api/v4/green_status/all"

  resp <- perform_request(base_url = base_url) %>%
    httr2::resp_body_json()

  json_to_df(resp)
}


