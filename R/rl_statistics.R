#' IUCN Red List statistics
#'
#' Retrieve count of species with assessments.
#' This endpoint returns the total number of assessed species on the IUCN Red List.
#'
#' @return A tibble containing the count of assessed species.
#'
#' @examples \dontrun{
#' # Get total count of assessed species
#' rl_statistics()
#'}
#' @export
rl_statistics <- function() {

  base_url <- "https://api.iucnredlist.org/api/v4/statistics/count"

  resp <- perform_request(base_url = base_url) %>%
    httr2::resp_body_json()
  resp <- data.frame(count = as.integer(resp$count), date_of_access = Sys.time())

  return(dplyr::as_tibble(resp))
}
