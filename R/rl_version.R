
#' IUCN Red List and API version
#'
#' Print the current version of the IUCN Red List of Threatened Species and API
#'
#' @return Invisibly returns `NULL` after printing the Red List and API versions.
#' 
#' @examples \dontrun{
#' rl_version()
#'}
#' @export
rl_version <- function() {

  rl_version <- "https://api.iucnredlist.org/api/v4/information/red_list_version"
  api_version <- "https://api.iucnredlist.org/api/v4/information/api_version"

  rl_version_resp <- perform_request(base_url = rl_version) %>%
    httr2::resp_body_json()

  api_version_resp <- perform_request(base_url = api_version) %>%
    httr2::resp_body_json()

  cli::cli_div(theme = list (.alert = list(color = "#AD180D")))
  cli::cli_alert_info("{.strong IUCN Red List version: {rl_version_resp$red_list_version}}")
  cli::cli_div(theme = list (.alert = list(color = "#008C46")))
  cli::cli_alert_info("{.strong API version: {api_version_resp$api_version}}")

  return(invisible(NULL))
}

