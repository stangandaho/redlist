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
#' rl_assessement_id(1425064)
#' }
#'
#' @export
rl_assessement_id <- function(assessment_id = 1425064, pad_with_na = FALSE) {
  suppressMessages(rl_check_api())

  base_url <- paste0("https://api.iucnredlist.org/api/v4/assessment/", assessment_id)
  ass_id <- perform_request(base_url = base_url) %>%
    httr2::resp_body_json()

  return(json_to_df(ass_id, pad_with_na = pad_with_na))

}

#' IUCN Red List biogeographical realms
#'
#' Retrieve available biogeographical realms or detailed species assessments for one or more realms.
#'
#' This function has two modes:
#' - If `code = NULL`, it returns a list of available biogeographical realms.
#' - If `code` is provided, it retrieves assessments for the specified realm(s),
#' optionally filtered by year, extinction status, scope, and page(s).
#'
#' If `page` is not specified, the function will automatically paginate over all
#' available pages for each parameter combination.
#'
#' @param code Numeric or Character. One or more biogeographical realm codes (e.g. `0` or `"0"`).
#' Use [rl_biogeographical_realms()] to list available realms.
#' @param year_published Optional. Single or numeric vector of years to filter assessments by publication year.
#' @param latest Optional. Logical. If `TRUE`, return only the latest assessment per species.
#' @param possibly_extinct Optional. Logical. Filter for species flagged as possibly extinct.
#' @param possibly_extinct_in_the_wild Optional. Logical. Filter for species possibly extinct in the wild.
#' @param scope_code Optional. Character. One or more scope codes to filter assessments.
#' @param page Optional. Integer vector. Specify one or more page numbers to fetch.
#' If `NULL` or `NA`, all pages will be fetched automatically.
#' @param pad_with_na Logical. If `TRUE`, pad shorter columns with `NA` for consistent binding.
#'
#' @return Tibble of biogeographical realms depending on parameters.
#'
#' @examples \dontrun{
#' # List all available biogeographical realms
#' rl_biogeographical_realms()
#'
#' # Retrieve all assessments for realm code 0
#' rl_biogeographical_realms(code = 0)
#'
#' # Get latest assessments from multiple pages with filters
#' rl_biogeographical_realms(
#'   code = 0,
#'   year_published = c(2020, 2021),
#'   page = c(1, 2)
#' )
#' }
#'
#' @export
rl_biogeographical_realms <- function(code = NULL,
                                      year_published = NULL,
                                      latest = NULL,
                                      possibly_extinct = NULL,
                                      possibly_extinct_in_the_wild = NULL,
                                      scope_code = NULL,
                                      page = 1,
                                      pad_with_na = FALSE) {
  suppressMessages(rl_check_api())

  base_url <- "https://api.iucnredlist.org/api/v4/biogeographical_realms"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  # Build param list for expand.grid
  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "name",
    pad_with_na = pad_with_na)

}


#' IUCN Red List Comprehensive groups
#'
#' Get assessment data by comprehensive group name (e.g `amphibians`,
#' `mammals`, `birds`, `blennies`, `mangrove_plants`, `reptiles`,
#' `insects`, `fishes`, etc).
#' See `name` argument for available group names.
#'
#' @param name Character. One or more group names.
#' Use [rl_comprehensive_groups()] to list available group names.
#' @inheritParams rl_biogeographical_realms
#'
#' @return Tibble of assessments for a comprehensive group name
#'
#' @examples \dontrun{
#' rl_comprehensive_groups(name = "amphibians",
#'                         year_published = 2024:2025,
#'                         page = 1:3)
#'}
#' @export
rl_comprehensive_groups <- function(name = NULL,
                                    year_published = NULL,
                                    latest = NULL,
                                    possibly_extinct = NULL,
                                    possibly_extinct_in_the_wild = NULL,
                                    scope_code = NULL,
                                    page = 1,
                                    pad_with_na = FALSE) {
  base_url <- "https://api.iucnredlist.org/api/v4/comprehensive_groups"

  if (is.null(name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(name = name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "name",
    pad_with_na = pad_with_na)

}

#' IUCN Red List conservation action
#'
#' Get assessment data by conservation action
#' See `actions` argument for available action codes
#'
#' @param code Character. One or more action codes
#' Use [rl_conservation_actions()] to list available action codes.
#' @inheritParams rl_biogeographical_realms
#'
#' @return Tibble of assessments for a conservation action code.
#'
#' @examples \dontrun{
#' rl_conservation_actions(code = 1,
#'                         year_published = 2024:2025,
#'                         page = 1:3)
#'}
#' @export
rl_conservation_actions <- function(code = NULL,
                                    year_published = NULL,
                                    latest = NULL,
                                    possibly_extinct = NULL,
                                    possibly_extinct_in_the_wild = NULL,
                                    scope_code = NULL,
                                    page = 1,
                                    pad_with_na = FALSE) {
  base_url <- "https://api.iucnredlist.org/api/v4/conservation_actions"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na)

}


#' Retrieve IUCN Red List assessments by country
#'
#' Retrieves the species assessed by the IUCN for a specified countries.
#' See `code` argument for available countries codes
#'
#' @param code Character. One or more countries codes
#' Use [rl_countries()] to list available countries codes.
#' @inheritParams rl_biogeographical_realms
#'
#' @return Tibble of assessments for a given country ISO alpha-2 code.
#'
#' @examples \dontrun{
#'   # Retrieve assessments for Benin (country code "BJ") for the year 2020
#'   rl_countries("BJ", year = 2020)
#'
#'   # Retrieve all assessments for Brazil (country code "BR")
#'   rl_countries("BR", page = 2)
#'
#'   # Retrieve assessments for Canada (country code "CA") on specific pages
#'   rl_countries("CA", page = c(1, 2))
#'}
#' @export
rl_countries <- function(code = NULL,
                        year_published = NULL,
                        latest = NULL,
                        possibly_extinct = NULL,
                        possibly_extinct_in_the_wild = NULL,
                        scope_code = NULL,
                        page = 1,
                        pad_with_na = FALSE) {
  base_url <- "https://api.iucnredlist.org/api/v4/countries"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na)

}



#' FAO marine fishing areas
#'
#' List or retrieve IUCN Red List assessments for FAO Marine Fishing Areas.
#'
#' If `code` is `NULL`, this returns the available FAO region codes and their descriptions.
#' If a `code` (or multiple codes) is provided, retrieves the IUCN assessments for those regions.
#'
#' @param code Character. One or more FAO region codes (e.g. "21", "27").
#' Use `rl_faos()` with no arguments to list available FAO region codes.
#' @inheritParams rl_biogeographical_realms
#'
#' @return A tibble of assessments for the specified FAO region(s), or a tibble of available FAO codes and descriptions.
#'
#' @examples \dontrun{
#' # List available FAO regions
#' rl_faos()
#'
#' # Get assessments for FAO region 27
#' rl_faos(code = "27")
#'
#' # Get assessments for regions 21 and 27 on page 1
#' rl_faos(code = c("21", "27"), page = 1)
#'}
#' @export
rl_faos <- function(code = NULL,
                    year_published = NULL,
                    latest = NULL,
                    possibly_extinct = NULL,
                    possibly_extinct_in_the_wild = NULL,
                    scope_code = NULL,
                    page = 1,
                    pad_with_na = FALSE) {
  base_url <- "https://api.iucnredlist.org/api/v4/faos"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na
  )
}


#' Growth forms
#'
#' Retrieve IUCN Red List assessments by growth form.
#'
#' If `code` is `NULL`, this returns the available growth form codes and their descriptions.
#' If a `code` (or multiple codes) is provided, retrieves the IUCN assessments for those growth forms.
#'
#' @param code Character. One or more growth form codes (e.g. "TREE", "SHRUB").
#' Use `rl_growth_forms()` with no arguments to list available growth form codes.
#' @inheritParams rl_biogeographical_realms
#'
#' @return A tibble of assessments for the specified growth form(s), or a tibble of available growth form codes and descriptions.
#'
#' @examples \dontrun{
#' # List available growth form codes
#' rl_growth_forms()
#'
#' # Get assessments for tree growth form (e.g Geophyte)
#' rl_growth_forms(code = "GE")
#'
#' # Get assessments for multiple growth forms (e.g Hydrophyte, Lithophyte)
#' rl_growth_forms(code = c("H", "L"), page = c(1, 2))
#'}
#' @export
rl_growth_forms <- function(code = NULL,
                            year_published = NULL,
                            latest = NULL,
                            possibly_extinct = NULL,
                            possibly_extinct_in_the_wild = NULL,
                            scope_code = NULL,
                            page = 1,
                            pad_with_na = FALSE) {
  base_url <- "https://api.iucnredlist.org/api/v4/growth_forms"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na
  )
}


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



#' Habitats
#'
#' Retrieve IUCN Red List assessments by habitat classification.
#'
#' @param code Character. One or more habitat classification codes.
#' Use [rl_habitats()] with no arguments to list available habitat codes.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble of assessments for a given IUCN habitat classification code.
#'
#' @examples \dontrun{
#' # Retrieve available habitat codes
#' rl_habitats()
#'
#' # Retrieve assessments for the Desert
#' rl_habitats(code = 8)
#'}
#' @export
rl_habitats <- function(code = NULL,
                        year_published = NULL,
                        latest = NULL,
                        possibly_extinct = NULL,
                        possibly_extinct_in_the_wild = NULL,
                        scope_code = NULL,
                        page = 1,
                        pad_with_na = FALSE) {
  base_url <- "https://api.iucnredlist.org/api/v4/habitats"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) |>
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(
      code = code,
      year_published = year_published %||% NA,
      latest = latest %||% NA,
      possibly_extinct = possibly_extinct %||% NA,
      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
      scope_code = scope_code %||% NA,
      page = page %||% NA
    ),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na
  )
}

#' IUCN Red List and API version
#'
#' Returns the current version of the IUCN Red List of Threatened Species and API
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
}


#' IUCN Red List population trends
#'
#' Retrieve available population trend categories or species assessments for one
#' or more trends.
#'
#' This function has two modes:
#' - If `code = NULL`, it returns a list of available population trend categories.
#' - If `code` is provided, it retrieves assessments for the specified trend(s),
#' optionally filtered by year, extinction status, scope, and page(s).
#'
#' Population trends include: Increasing, Decreasing, Stable, or Unknown.
#'
#' If `page` is not specified, the function will automatically paginate over all
#' available pages for each parameter combination.
#'
#' @param code Character or Numeric. One or more population trend codes (`0`-`3`).
#' Use [rl_population_trends()] to list available trend codes and definition.
#' @inheritParams rl_biogeographical_realms
#'
#' @return Tibble of population trend categories or species assessments depending on parameters.
#'
#' @examples \dontrun{
#' # List all available population trend categories
#' rl_population_trends()
#'
#' # Retrieve assessments for species with decreasing populations
#' rl_population_trends(code = "1")
#'
#' # Get latest decreasing population assessments from 2020
#' rl_population_trends(
#'   code = 2,
#'   year_published = 2020,
#'   latest = TRUE
#' )
#'}
#' @export
rl_population_trends <- function(code = NULL,
                                 year_published = NULL,
                                 latest = NULL,
                                 possibly_extinct = NULL,
                                 possibly_extinct_in_the_wild = NULL,
                                 scope_code = NULL,
                                 page = 1,
                                 pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/population_trends"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(
      code = code,
      year_published = year_published %||% NA,
      latest = latest %||% NA,
      possibly_extinct = possibly_extinct %||% NA,
      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
      scope_code = scope_code %||% NA,
      page = page %||% NA
    ),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na
  )
}


#' IUCN Red List Categories
#'
#' Retrieve species assessments based on their Red List threat categories.
#' If `code = NULL`, it returns a list of available Red List categories.
#' If `code` is provided, it retrieves assessments for species in the specified category(ies).
#'
#' @param code Character. One or more Red List category codes (e.g., "CR", "EN").
#' Use [rl_red_list_categories()] to list available categories.
#' @inheritParams rl_biogeographical_realms
#'
#' @return A tibble containing Red List categories or species assessments.
#'
#' @examples \dontrun{
#' # List all Red List categories
#' rl_red_list_categories()
#'
#' # Get Critically Endangered species assessments
#' rl_red_list_categories(code = "CR")
#'
#' # Get Vulnerable species assessments published in 2020
#' rl_red_list_categories(
#'   code = "VU",
#'   year_published = 2020
#' )
#'}
#' @export
rl_red_list_categories <- function(code = NULL,
                                   year_published = NULL,
                                   latest = NULL,
                                   possibly_extinct = NULL,
                                   possibly_extinct_in_the_wild = NULL,
                                   scope_code = NULL,
                                   page = 1,
                                   pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/red_list_categories"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na)
}


#' IUCN Red List research categories
#'
#' Retrieve species assessments based on their research needs categories.
#' If `code = NULL`, it returns a list of available research categories.
#' If `code` is provided, it retrieves assessments for species with the specified research need(s).
#'
#' @param code Character Or Numeric. One or more research category codes (e.g., "1", "2").
#' Use [rl_research()] to list available research categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing research categories or species assessments.
#'
#' @examples \dontrun{
#' # List all research categories
#' rl_research()
#'
#' # Get species needing population trends research (code 3_1)
#' rl_research(code = "3_1")
#'
#' # Get species needing life history & ecology research published since 2019
#' rl_research(
#'   code = "1_3",
#'   year_published = 2019:2023
#' )
#'}
#' @export
rl_research <- function(code = NULL,
                        year_published = NULL,
                        latest = NULL,
                        possibly_extinct = NULL,
                        possibly_extinct_in_the_wild = NULL,
                        scope_code = NULL,
                        page = 1,
                        pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/research"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na)
}



#' IUCN Red List assessment scopes
#'
#' Retrieve species assessments based on their geographic assessment scopes.
#' If `code = NULL`, it returns a list of available assessment scopes.
#' If `code` is provided, it retrieves assessments for the specified scope(s).
#'
#' @param code Character or Numeric. One or more scope codes (e.g., "1", "2").
#' Use [rl_scopes()] to list available scope categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing assessment scopes or species assessments.
#'
#' @examples \dontrun{
#' # List all assessment scopes
#' rl_scopes()
#'
#' # Get globally assessed species (code 1)
#' rl_scopes(code = "1")
#'
#' # Get Pan-Africa species assessed species published since 2020
#' rl_scopes(
#'   code = "2",
#'   year_published = 2020:2023
#' )
#'}
#' @export
rl_scopes <- function(code = NULL,
                      year_published = NULL,
                      latest = NULL,
                      possibly_extinct = NULL,
                      possibly_extinct_in_the_wild = NULL,
                      scope_code = scope_code %||% NA,
                      page = 1,
                      pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/scopes"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na)
}


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


#' IUCN Red List stress categories
#'
#' Retrieve species assessments based on stress categories affecting species.
#' If `code = NULL`, it returns a list of available stress categories.
#' If `code` is provided, it retrieves assessments for species affected by the specified stress(es).
#'
#' @param code Character or Numeric. One or more stress codes (e.g., "1", "2_1").
#' Use [rl_stresses()] to list available stress categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing stress categories or species assessments.
#'
#' @examples \dontrun{
#' # List all stress categories
#' rl_stresses()
#'
#' # Get species affected by ecosystem stresses (code 1)
#' rl_stresses(code = "1") # or code = 1
#'
#' # Get species affected by competition stresses published since 2020
#' rl_stresses(
#'   code = "2_3_2",
#'   year_published = 2020:2023
#' )
#'}
#' @export
rl_stresses <- function(code = NULL,
                        year_published = NULL,
                        latest = NULL,
                        possibly_extinct = NULL,
                        possibly_extinct_in_the_wild = NULL,
                        scope_code = NULL,
                        page = 1,
                        pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/stresses"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na)
}


#' IUCN Red List ecological systems
#'
#' Retrieve species assessments based on their ecological systems.
#' If `code = NULL`, it returns a list of available ecological systems.
#' If `code` is provided, it retrieves assessments for species in the specified system(s).
#'
#' @param code Character or Numeric. One or more system codes (e.g., "0", "1", "2").
#' Use [rl_systems()] to list available ecological systems.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing ecological systems or species assessments.
#'
#' @examples \dontrun{
#' # List all ecological systems
#' rl_systems()
#'
#' # Get terrestrial species assessments (code 0)
#' rl_systems(code = 0)
#'
#' # Get marine species assessments published since 2021
#' rl_systems(
#'   code = "2",
#'   year_published = 2021:2023
#' )
#'}
#' @export
rl_systems <- function(code = NULL,
                       year_published = NULL,
                       latest = NULL,
                       possibly_extinct = NULL,
                       possibly_extinct_in_the_wild = NULL,
                       scope_code = NULL,
                       page = 1,
                       pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/systems"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na)
}


#' IUCN Red List taxa by SIS ID
#'
#' Retrieve species assessments using the Species Information Service (SIS) identifier.
#' Returns summary assessment data including both latest and historic assessments.
#'
#' @param sis_id Numeric. One or more SIS identifiers for taxa.
#' @param pad_with_na Logical. If `TRUE`, pad shorter columns with `NA`.
#'
#' @return A tibble containing assessment data for the specified SIS ID(s).
#'
#' @examples \dontrun{
#' # Get assessments for species with SIS ID 179359
#' rl_sis(179359)
#'}
#' @export
rl_sis <- function(sis_id = 179359,
                   pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/sis/"

    resp <- perform_request(base_url = paste0(base_url, sis_id)) %>%
      httr2::resp_body_json() %>%
      json_to_df(pad_with_na = pad_with_na)

    return(resp)
}


############ TEXA ##########################

#' IUCN Red List taxa by scientific name
#'
#' Retrieve species assessments using scientific names (Latin binomials).
#' Returns summary assessment data including both latest and historic assessments.
#'
#' @param genus_name Character. The genus name (required).
#' @param species_name Character. The species name (required).
#' @param infra_name Character. The infraspecific name (optional).
#' @param subpopulation_name Character. The subpopulation name (optional).
#' @param pad_with_na Logical. If `TRUE`, pad shorter columns with `NA`.
#'
#' @return A tibble containing assessment data for the specified taxon.
#'
#' @examples \dontrun{
#' # Get assessments for Panthera leo (lion)
#' rl_scientific_name(genus_name = "Panthera", species_name = "leo")
#'}
#' @export
rl_scientific_name <- function(genus_name,
                                species_name,
                                infra_name = NULL,
                                subpopulation_name = NULL,
                                pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/scientific_name"

  # Build query parameters
  query_params <- list(
    genus_name = genus_name,
    species_name = species_name,
    infra_name = infra_name %||% NULL,
    subpopulation_name = subpopulation_name %||% NULL
  )

  resp <- perform_request(base_url = base_url, params = query_params) %>%
    httr2::resp_body_json()

  return(json_to_df(resp, pad_with_na = pad_with_na))
}


#' IUCN Red List taxa by kingdom
#'
#' Retrieve species assessments by kingdom.
#' If `kingdom_name = NULL`, it returns a list of available kingdoms.
#' If `kingdom_name` is provided, it retrieves assessments for species in the specified kingdom.
#'
#' @param kingdom_name Character. The kingdom name (e.g., "Animalia").
#' Use [rl_kingdoms()] to list available kingdoms.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing kingdoms or species assessments.
#'
#' @examples \dontrun{
#' # List all available kingdoms
#' rl_kingdoms()
#'
#' # Get assessments for species in Animalia kingdom
#' rl_kingdoms(kingdom_name = "Animalia")
#'
#' # Get latest assessments for Plantae published in 2021
#' rl_kingdoms(
#'   kingdom_name = "Plantae",
#'   year_published = 2021,
#'   latest = TRUE
#' )
#'}
#' @export
rl_kingdoms <- function(kingdom_name = NULL,
                        year_published = NULL,
                        latest = NULL,
                        scope_code = NULL,
                        page = 1,
                        pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/kingdom"

  if (is.null(kingdom_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()%>%
      json_to_df(pad_with_na = pad_with_na) %>%
      t() %>% as.data.frame()
    colnames(resp) <- "kingdom_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(kingdom_name = kingdom_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "kingdom_name",
    pad_with_na = pad_with_na)
}


#' IUCN Red List taxa by phylum
#'
#' Retrieve species assessments by phylum.
#' If `phylum_name = NULL`, it returns a list of available phyla.
#' If `phylum_name` is provided, it retrieves assessments for species in the specified phylum.
#'
#' @param phylum_name Character. The phylum name (e.g., "Chordata").
#' Use [rl_phylum()] to list available phyla.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing phyla or species assessments.
#'
#' @examples \dontrun{
#' # List all available phyla
#' rl_phylum()
#'
#' # Get assessments for species in Chordata phylum
#' rl_phylum(phylum_name = "Chordata")
#'
#' # Get latest assessments for Arthropoda published in 2020
#' rl_phylum(
#'   phylum_name = "Arthropoda",
#'   year_published = 2020,
#'   latest = TRUE
#' )
#'}
#' @export
rl_phylum <- function(phylum_name = NULL,
                      year_published = NULL,
                      latest = NULL,
                      scope_code = NULL,
                      page = 1,
                      pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/phylum"

  if (is.null(phylum_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json() %>%
      json_to_df(pad_with_na = pad_with_na) %>%
      t() %>% as.data.frame()
    colnames(resp) <- "phylum_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(phylum_name = phylum_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "phylum_name",
    pad_with_na = pad_with_na)
}


#' IUCN Red List taxa by class
#'
#' Retrieve species assessments by taxonomic class.
#' If `class_name = NULL`, it returns a list of available classes.
#' If `class_name` is provided, it retrieves assessments for species in the specified class.
#'
#' @param class_name Character. The class name (e.g., "Mammalia").
#' Use [rl_classes()] to list available classes.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing classes or species assessments.
#'
#' @examples \dontrun{
#' # List all available classes
#' rl_classes()
#'
#' # Get assessments for Mammalia class
#' rl_classes(class_name = "Mammalia")
#'
#' # Get latest Aves assessments published since 2024
#' rl_classes(
#'   class_name = "Aves",
#'   year_published = 2024:2025,
#'   latest = TRUE
#' )
#'}
#'
#' @export
rl_classes <- function(class_name = NULL,
                       year_published = NULL,
                       latest = NULL,
                       scope_code = NULL,
                       page = 1,
                       pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/class"

  if (is.null(class_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()%>%
      json_to_df(pad_with_na = pad_with_na) %>%
      t() %>% as.data.frame()
    colnames(resp) <- "class_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(class_name = class_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "class_name",
    pad_with_na = pad_with_na)
}


#' IUCN Red List taxa by order
#'
#' Retrieve species assessments by taxonomic order.
#' If `order_name = NULL`, it returns a list of available orders.
#' If `order_name` is provided, it retrieves assessments for species in the specified order.
#'
#' @param order_name Character. The order name (e.g., "Carnivora").
#' Use [rl_orders()] to list available orders.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing orders or species assessments.
#'
#' @examples \dontrun{
#' # List all available orders
#' rl_orders()
#'
#' # Get assessments for Carnivora order
#' rl_orders(order_name = "Carnivora")
#'
#' # Get latest Primates assessments published in 2022
#' rl_orders(
#'   order_name = "Primates",
#'   year_published = 2022,
#'   latest = TRUE
#' )
#'}
#' @export
rl_orders <- function(order_name = NULL,
                      year_published = NULL,
                      latest = NULL,
                      scope_code = NULL,
                      page = 1,
                      pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/order"

  if (is.null(order_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()%>%
      json_to_df(pad_with_na = pad_with_na) %>%
      t() %>% as.data.frame()
    colnames(resp) <- "order_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(order_name = order_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "order_name",
    pad_with_na = pad_with_na)
}


#' IUCN Red List taxa by family
#'
#' Retrieve species assessments by taxonomic family.
#' If `family_name = NULL`, it returns a list of available families.
#' If `family_name` is provided, it retrieves assessments for species in the specified family.
#'
#' @param family_name Character. The family name (e.g., "Felidae").
#' Use [rl_family()] to list available families.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing families or species assessments.
#'
#' @examples \dontrun{
#' # List all available families
#' rl_family()
#'
#' # Get assessments for Felidae family
#' rl_family(family_name = "Felidae")
#'
#' # Get latest Canidae assessments published from 2019 to 2022
#' rl_family(
#'   family_name = "Canidae",
#'   year_published = 2019:2022,
#'   latest = TRUE
#' )
#'}
#' @export
rl_family <- function(family_name = NULL,
                        year_published = NULL,
                        latest = NULL,
                        scope_code = NULL,
                        page = 1,
                        pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/family"

  if (is.null(family_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()%>%
      json_to_df(pad_with_na = pad_with_na) %>%
      t() %>% as.data.frame()
    colnames(resp) <- "family_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(family_name = family_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "family_name",
    pad_with_na = pad_with_na)
}


#' IUCN Red List possibly extinct taxa
#'
#' Retrieve species assessments flagged as possibly extinct.
#' Returns all latest global assessments for taxa that are possibly extinct.
#'
#' @param pad_with_na Logical. If `TRUE`, pad shorter columns with `NA`.
#'
#' @return A tibble containing species assessments marked as possibly extinct.
#'
#' @examples \dontrun{
#' # Get all possibly extinct species
#' rl_possibly_extinct()
#'}
#' @export
rl_possibly_extinct <- function(pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/possibly_extinct"

  resp <- perform_request(base_url = base_url) %>%
    httr2::resp_body_json()

  return(json_to_df(resp, pad_with_na = pad_with_na))
}


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
rl_possibly_extinct_in_wild <- function(pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/possibly_extinct_in_the_wild"

  resp <- perform_request(base_url = base_url) %>%
    httr2::resp_body_json()

  return(json_to_df(resp, pad_with_na = pad_with_na))
}


#' IUCN Red List threat categories
#'
#' Retrieve species assessments based on threat categories.
#' If `code = NULL`, it returns a list of available threat categories.
#' If `code` is provided, it retrieves assessments for species affected by the specified threat(s).
#'
#' @param code Character. One or more threat codes (e.g., "1").
#' Use [rl_threats()] to list available threat categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing threat categories or species assessments.
#'
#' @examples \dontrun{
#' # List all threat categories
#' rl_threats()
#'
#' # Get species affected by agriculture & aquaculture threats (code 2)
#' rl_threats(code = 2)
#'
#' # Get species affected by Climate change & severe weather threats published in 2025
#' rl_threats(
#'   code = "11",
#'   year_published = 2025
#' )
#'}
#' @export
rl_threats <- function(code = NULL,
                       year_published = NULL,
                       latest = NULL,
                       possibly_extinct = NULL,
                       possibly_extinct_in_the_wild = NULL,
                       scope_code = NULL,
                       page = 1,
                       pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/threats"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na)
}


#' IUCN Red List use and trade categories
#'
#' Retrieve species assessments based on use and trade categories.
#' If `code = NULL`, it returns a list of available use and trade categories.
#' If `code` is provided, it retrieves assessments for species affected by the specified use/trade category(ies).
#'
#' @param code Character. One or more use/trade codes (e.g., "1", "5_2").
#' Use [rl_use_and_trade()] to list available categories.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing use/trade categories or species assessments.
#'
#' @examples \dontrun{
#' # List all use and trade categories
#' rl_use_and_trade()
#'
#' # Get species used for food - human (code 1)
#' rl_use_and_trade(code = "1")
#'
#' # Get species hunted for Sport hunting/specimen collecting published in 2024
#' rl_use_and_trade(
#'   code = "15",
#'   year_published = 2024
#' )
#'}
#' @export
rl_use_and_trade <- function(code = NULL,
                             year_published = NULL,
                             latest = NULL,
                             possibly_extinct = NULL,
                             possibly_extinct_in_the_wild = NULL,
                             scope_code = NULL,
                             page = 1,
                             pad_with_na = FALSE) {
  suppressMessages(rl_check_api())

  base_url <- "https://api.iucnredlist.org/api/v4/use_and_trade"

  if (is.null(code)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()
    return(json_to_df(resp, pad_with_na = pad_with_na))
  }

  rl_paginated_query(
    param_list = list(code = code,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      possibly_extinct = possibly_extinct %||% NA,
                      possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "code",
    pad_with_na = pad_with_na)
}
