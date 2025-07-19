#' Green status
#'
#' Retrieve all IUCN Green Status assessments.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble of Green Status assessments.
#'
#' @examples \dontrun{
#' rl_green_status()
#'}
#' @export
rl_green_status <- function(pad_with_na = FALSE) {
  base_url <- "https://api.iucnredlist.org/api/v4/green_status/all"

  resp <- perform_request(base_url = base_url) %>%
    httr2::resp_body_json()

  json_to_df(resp, pad_with_na = pad_with_na)
}


