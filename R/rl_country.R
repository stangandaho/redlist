#' Retrieve IUCN Red List Assessments by Country
#'
#' Fetches species assessments from the IUCN Red List API for a specified country and year.
#' This function returns data on threatened species assessed within the specified country,
#' filtered by year and/or page if specified.
#'
#' @param country_code Character. The ISO 3166-1 alpha-2 country code (e.g., "BJ" for Benin). Defaults to "BJ".
#' @param year Numeric or NULL. The year of the assessments to retrieve. If NULL, all years are retrieved.
#' @param page Numeric, character, or NULL. Specifies the page number(s) of data to retrieve.
#'   - If NULL, retrieves the first page.
#'   - If a single numeric value, retrieves that specific page.
#'   - If "all", retrieves all pages available.
#'   - If a numeric vector, retrieves multiple specific pages.
#' @param verbose Logical. If TRUE, prints progress messages when multiple pages are requested. Defaults to TRUE.
#'
#' @return A data frame containing the species assessment data, excluding columns `scopes` and `code_type`.
#'
#' @details
#' The function first checks the Red List API authorization, then constructs an API request based on the
#' specified parameters (`country_code`, `year`, and `page`). If `page` is set to "all", it automatically
#' retrieves all available pages of data by calling the [rl_get_count()] function to determine the total
#' number of pages required.
#'
#' The retrieved data frame contains the following fields:
#' - `taxonid`: Taxon ID of the species.
#' - `scientific_name`: Scientific name of the species.
#' - `year_published`: The year the assessment was published.
#' - and other relevant assessment details.
#'
#' @note Requires an IUCN Red List API token to be set as an environment variable under `redlist_api` with [rl_set_api()] function.
#'   For reliable functioning, the helper function [rl_check_api()] could be called to validate the API token.
#'
#' @examples
#' \dontrun{
#'   # Retrieve assessments for Benin (country code "BJ") for the year 2020
#'   rl_country("BJ", year = 2020)
#'
#'   # Retrieve all assessments for Brazil (country code "BR")
#'   rl_country("BR", page = "all")
#'
#'   # Retrieve assessments for Canada (country code "CA") on specific pages
#'   rl_country("CA", page = c(1, 2))
#' }
#'
#' @import httr2
#' @import dplyr
#' @export


rl_country <- function(country_code = "BJ",
                       year = NULL,
                       page = NULL,
                       verbose = TRUE){

  suppressMessages(rl_check_api())

  year_published <- year
  params <- list(page = page, year_published = year_published)

  if (is.null(page) || (length(page) == 1 && page != "all")) {

    # modify request URL for year and page
    assessment <- paste0("https://api.iucnredlist.org/api/v4/countries/", country_code) %>%
      httr2::request() %>%
      httr2::req_url_query(!!!params) %>%
      httr2::req_headers(
        accept = "application/json",
        Authorization = Sys.getenv("redlist_api")
      ) %>%
      httr2::req_perform() %>%
      httr2::resp_body_json(simplifyDataFrame = T)
    assessment <- assessment$assessments

  }else{

    if (length(page) > 1 & is.numeric(page)) {
      page_size <- length(page)
    }else if(page == "all"){
      page_size <- rl_page_size(rl_get_count(country_code =  country_code))
    }

    # process to data query
    assessment <- list()
    for (i in 1:page_size) {
      if(verbose){print(noquote(paste0("On page ", i, "/", page_size)))}

      params <- list(page = i, year_published = year_published)

      query_url <- paste0("https://api.iucnredlist.org/api/v4/countries/", country_code) %>%
        httr2::request() %>%
        httr2::req_url_query(!!!params) %>%
        httr2::req_headers(
          accept = "application/json",
          Authorization = Sys.getenv("redlist_api")
        ) %>%
        httr2::req_perform() %>%
        httr2::resp_body_json(simplifyDataFrame = T)

      assessment[[i]] <- query_url$assessments
      Sys.sleep(2)
    }

    assessment <- bind_rows(assessment)
  }

  return(dplyr::tibble(assessment %>% select(-c(scopes, code_type))))
}
