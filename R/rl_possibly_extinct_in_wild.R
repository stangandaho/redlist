#' IUCN Red List possibly extinct in the wild taxa
#'
#' Retrieve species assessments flagged as possibly extinct in the wild.
#' Returns all latest global assessments for taxa that are possibly extinct in the wild.
#'
#' @param pad_with_na Logical. If `TRUE`, pad shorter columns with `NA`.
#'
#' @return A tibble containing species assessments marked as possibly extinct in the wild.
#'
#' @examples \dontrun{
#' # Get all possibly extinct in the wild species
#' rl_possibly_extinct_in_wild()
#'}
#' @export
rl_possibly_extinct_in_wild <- function() {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/possibly_extinct_in_the_wild"

  resp <- perform_request(base_url = base_url) %>%
    httr2::resp_body_json()

  return(json_to_df(resp))
}
