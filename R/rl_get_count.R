#' Get Total Number of Species Assessed by IUCN for a Given Country
#'
#' This function retrieves the total number of species assessed by the IUCN Red
#' List for a specified country.
#'
#' @param country_code A character string specifying the ISO 3166-1 alpha-2
#' country code for which the species count is to be retrieved. Defaults to `"BJ"` (Benin).
#'
#' @details
#' The function queries the IUCN Red List API to obtain the total count of species
#' assessed for the specified country. It requires your API key.
#'
#' @return A numeric value representing the total number of species assessed for the specified country.
#'
#' @examples
#' # Example usage
#' \dontrun{
#' # Set your IUCN API key as an environment variable
#' rl_set_api("your_api_key_here")
#'
#' # Get the total species count for Benin (default)
#' total_species <- rl_get_count()
#' print(total_species)
#'
#' # Get the total species count for India
#' total_species_india <- rl_get_count(country_code = "IN")
#' print(total_species_india)
#' }
#'
#' @export


rl_get_count <- function(country_code = "BJ"){

  suppressMessages(rl_check_api())
  query_url <- paste0("https://api.iucnredlist.org/api/v4/countries/", country_code) %>%
    httr2::request() %>%
    httr2::req_headers(
      accept = "application/json",
      Authorization = Sys.getenv("redlist_api")
    ) %>%
    httr2::req_perform()

  total_count <- as.numeric(query_url$headers$`Total-Count`)
  return(total_count)
}
