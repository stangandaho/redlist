#' Retrieve IUCN Red List Assessments by Species Name
#'
#' This function retrieves assessment information from the IUCN Red List API for a specified species
#' using its scientific name. The function fetches taxonomic, population, conservation, and threat data
#' for each assessment related to the species.
#'
#' @param scientific_name Character. The scientific name of the species (e.g., "Panthera leo").
#'
#' @return A data frame with detailed assessment information for the species, including:
#'   - **Taxonomic information**: kingdom, phylum, class, order, family, genus, and scientific name
#'   - **Assessment details**: assessment date, criteria, Red List category, population trends
#'   - **Population and habitat details**: population size, trends, habitat description
#'   - **Threats and conservation measures**: major threats, conservation actions, and documentation
#'
#' @details
#' The function first splits the `scientific_name` into genus and species components (with support for
#' infra-specific names if available) and then calls the IUCN API to retrieve the associated assessment
#' data. If multiple assessments exist for the species, they are all fetched and combined into a
#' single data frame.
#'
#' @note Requires an IUCN Red List API token to be set as an environment variable under `redlist_api`.
#'   Additionally, a helper function, `rl_check_api()`, should be defined to check the API connection.
#'
#' @examples
#' \dontrun{
#'   # Retrieve assessments for the African lion by its scientific name
#'   rl_from_species_name("Panthera leo")
#'
#'   # Retrieve assessments for the Bengal tiger
#'   rl_from_species_name("Panthera tigris tigris")
#' }
#'
#' @import httr2
#' @import dplyr
#' @export

rl_from_species_name <- function(scientific_name){
  splited <- strsplit(scientific_name, "\\s")
  genus <- trimws(splited[[1]][1])
  species <- trimws(splited[[1]][2])
  infra_name <- if(is.na(trimws(splited[[1]][3])))NULL else{trimws(splited[[1]][3])}
  params <- list(genus_name = genus, species_name = species, infra_name = infra_name)

  suppressMessages(rl_check_api())
  performed_request <- tryCatch({
    paste0("https://api.iucnredlist.org/api/v4/taxa/scientific_name/") %>%
      httr2::request() %>%
      httr2::req_url_query(!!!params) %>%
      httr2::req_headers(
        accept = "application/json",
        Authorization = Sys.getenv("REDLIST_API")
      ) %>%
      httr2::req_perform()
  },
  error = function(e){paste0("error")})

  if (any(performed_request == "error")) {
    cli::cli_abort("Species scientific name doesn't exist")
  }

  if (performed_request$status == 200) {
    assessment <- performed_request %>%
      httr2::resp_body_json(simplifyDataFrame = T)

    assessment_ids <- lapply(strsplit(assessment$assessments$url, "/"),
                             function(x){
                               x[length(x)]
                             })

    all_assessment <- list()
    for (ass_id in assessment_ids) {
      ass <- rl_from_assessment_id(assessment_id = ass_id)
      all_assessment[[ass_id]] <- ass
    }
    all_assessment <- dplyr::bind_rows(all_assessment)

  }else{
    cli::cli_alert_info("Species not found")
  }

  return(all_assessment)
}
