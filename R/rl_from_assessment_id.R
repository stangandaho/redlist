#' Retrieve IUCN Red List Assessment by ID
#'
#' This function retrieves detailed information from the IUCN Red List API for a specific species assessment
#' identified by an `assessment_id`. The returned data includes taxonomic details, assessment information,
#' population and habitat data, threats, and conservation measures.
#'
#' @param assessment_id Character. The unique assessment ID for the species to retrieve from the IUCN Red List.
#'
#' @return A data frame with detailed assessment information for the species, including:
#'   - **Taxonomic information**: kingdom, phylum, class, order, family, genus, and scientific name
#'   - **Assessment details**: assessment date, criteria, Red List category, population trends
#'   - **Population and habitat details**: population size, trends, habitat description
#'   - **Threats and conservation measures**: major threats, conservation actions, and documentation
#'
#' @details
#' This function makes an API call to the IUCN Red List service and processes the response into a
#' structured data frame. If the `assessment_id` is invalid or not found, an error message is returned.
#'
#' @note Requires an IUCN Red List API token to be set as an environment variable under `redlist_api` with [rl_set_api()] function.
#'
#' @examples
#' \dontrun{
#'   # Retrieve assessment information for a species by ID
#'   rl_from_assessment_id("1234567")
#' }
#'
#' @import httr2
#' @import dplyr
#' @export

rl_from_assessment_id <- function(assessment_id){

  assessment <- tryCatch({
    paste0("https://api.iucnredlist.org/api/v4/assessment/", assessment_id) %>%
      httr2::request() %>%
      httr2::req_headers(
        accept = "application/json",
        Authorization = Sys.getenv("redlist_api")
      ) %>%
      httr2::req_perform() %>%
      httr2::resp_body_json(simplifyDataFrame = T)
  }, error = function(e){paste0(tolower(e))})

  if (any(grepl("404 not found", assessment))) {
    stop("Invalid assessment id ", call. = F)
  }
  assess_ <<- assessment

  assessment <- dplyr::tibble(
    # taxon info
    kingdom_name = remove_null(assessment$taxon$kingdom_name),
    phylum_name = remove_null(assessment$taxon$phylum_name),
    class_name = remove_null(assessment$taxon$class_name),
    order_name = remove_null(assessment$taxon$order_name),
    family_name = remove_null(assessment$taxon$family_name),
    genus_name = remove_null(assessment$taxon$genus_name),
    subpopulation_name = remove_null(assessment$taxon$subpopulation_name),
    scientific_name = remove_null(assessment$taxon$scientific_name),

    # assessment info
    assessment_date = as.Date(remove_null(assessment$assessment_date)),
    year = remove_null(assessment$year_published),
    latest = remove_null(assessment$latest),
    possibly_extinct = remove_null(assessment$possibly_extinct),
    possibly_extinct_in_the_wild = remove_null(assessment$possibly_extinct_in_the_wild),
    criteria = remove_null(assessment$criteria),
    url = remove_null(assessment$url),
    citation = remove_null(assessment$citation),
    population_trend = remove_null(assessment$population_trend$description$en),
    category = remove_null(assessment$red_list_category$description$en),
    category_code = remove_null(assessment$red_list_category$code),
    category_version = remove_null(assessment$red_list_category$version),
    # supplementary info
    population_size = remove_null(assessment$supplementary_info$population_size),
    population_severely_fragmented = remove_null(assessment$supplementary_info$population_severely_fragmented),
    continuing_decline = remove_null(assessment$supplementary_info$population_continuing_decline),
    generational_length = remove_null(assessment$supplementary_info$generational_length),
    congregatory = remove_null(assessment$supplementary_info$congregatory),
    movement_patterns = remove_null(assessment$supplementary_info$movement_patterns),
    continuing_decline_in_area = remove_null(assessment$supplementary_info$continuing_decline_in_area),
    in_protected_area = remove_null(assessment$supplementary_info$conservation_actions_in_place$actions[[1]][[2]]),
    estimated_area_of_occupancy = remove_null(assessment$supplementary_info$estimated_area_of_occupancy),
    # documentation
    range = remove_null(assessment$documentation$range),
    population = remove_null(assessment$documentation$population),
    habitats_description = remove_null(assessment$documentation$habitats),
    threats = remove_null(assessment$documentation$threats),
    measures = remove_null(assessment$documentation$measures),
    use_trade = remove_null(assessment$documentation$use_trade),
    rationale = remove_null(assessment$documentation$rationale),
    # habitat
    habitats = remove_null(paste0(unique(assessment$habitats$description$en), collapse = ", ")),
    # location
    is_endemic = if(any(assessment$locations$is_endemic)){
      paste0(assessment$locations$description$en[assessment$locations$is_endemic], collapse = ", ")
    }else{
      "No"
    },

    country_of_extend = remove_null(paste0(assessment$locations$description$en, collapse = ", "))

  )
  # converte all column to character
  cols <- colnames(assessment)
  assessment <- assessment %>%
    mutate(across(.cols = all_of(cols), .fns = as.character))

  return(assessment)
}
