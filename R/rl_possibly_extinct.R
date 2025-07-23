#' IUCN Red List possibly extinct taxa
#'
#' Retrieve species assessments flagged as possibly extinct.
#' Returns all latest global assessments for taxa that are possibly extinct.
#'
#' @return A tibble containing species assessments marked as possibly extinct.
#'
#' @examples \dontrun{
#' # Get all possibly extinct species
#' rl_possibly_extinct()
#'}
#' @export
rl_possibly_extinct <- function() {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/possibly_extinct"

  resp <- perform_request(base_url = base_url) %>%
    httr2::resp_body_json()

  return(json_to_df(resp))
}
