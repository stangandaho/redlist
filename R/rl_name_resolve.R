#' Resolve a scientific name to the accepted IUCN Red List name
#'
#' When you work with names from another source (for example GBIF), some names
#' differ from the ones the IUCN Red List uses, so a direct request such as
#' [rl_scientific_name()] returns *404 (species not found)*. This function forces
#' a match: it verifies the name against the
#' \href{https://verifier.globalnames.org/apidoc}{GlobalNames Verifier} API and
#' returns the accepted (current) name the IUCN Red List uses, so the retrieval
#' can be repeated with the resolved name.
#'
#' @param genus_name Character. The genus name (required).
#' @param species_name Character. The species name (required).
#' @param infra_name Character. The infraspecific name (optional).
#' @param subpopulation_name Character. The subpopulation name (optional).
#' @param vernaculars Character. Vernacular-name languages to return, as
#'   `"|"`-separated ISO 639-3 codes (e.g. "eng|rus|deu" for multiple languages),
#'   or `"all"` for every language found. Default `"all"`.
#' @param data_sources Integer vector of GlobalNames data-source ids to match
#'   against. Default `163` for IUCN.  See
#' \url{https://verifier.globalnames.org/data_sources} for the full list.
#' @param all_matches Logical. If `TRUE`, return every match found instead of
#'   only the best one. Default `FALSE`.
#' @param capitalize Logical. Capitalize the first letter of the name before
#'   matching. Default `FALSE`.
#' @param species_group Logical. Expand the search to the species group where
#'   applicable. Default `FALSE`.
#' @param fuzzy_uninomial Logical. Allow fuzzy matching for uninomial names.
#'   Default `FALSE`.
#' @param stats Logical. Ask the API to find the kingdom and main taxon holding
#'   most names (Catalogue of Life only). Default `FALSE`.
#' @param main_taxon_threshold Numeric between 0.5 and 1 setting the minimal
#'   proportion for main-taxon discovery. Default `0.6`.
#'
#' @return A tibble with one row per input name. A name that cannot be
#'   matched returns a single row of `NA` fields.
#'
#' @seealso [rl_scientific_name()]
#'
#' @examples \dontrun{
#' # GBIF's "Corvinella corvina" is a synonym; IUCN uses "Lanius corvinus"
#' rl_name_resolve(genus_name = "Corvinella", species_name = "corvina")
#' }
#' @export
rl_name_resolve <- function(genus_name,
                            species_name,
                            infra_name = NULL,
                            subpopulation_name = NULL,
                            vernaculars = "all",
                            data_sources = 163, # Only IUCN
                            all_matches = FALSE,
                            capitalize = FALSE,
                            species_group = FALSE,
                            fuzzy_uninomial = FALSE,
                            stats = FALSE,
                            main_taxon_threshold = 0.6) {

  base_url <- "https://verifier.globalnames.org/api/v1/verifications/"

  # The name is a path segment, not a query parameter, and must be URL-encoded
  # (the space between genus and species becomes %20).
  name <- paste(genus_name, species_name, infra_name, subpopulation_name)
  name <- utils::URLencode(trimws(name), reserved = TRUE)

  # The API expects lowercase "true"/"false" for its boolean flags.
  fmt <- function(x) if (is.logical(x)) tolower(as.character(x)) else x
  params <- list(
    vernaculars = vernaculars,
    data_sources = paste(data_sources, collapse = "|"),
    all_matches = fmt(all_matches),
    capitalize = fmt(capitalize),
    species_group = fmt(species_group),
    fuzzy_uninomial = fmt(fuzzy_uninomial),
    stats = fmt(stats),
    main_taxon_threshold = main_taxon_threshold
  )

  # Perform request
  rp <- base_url %>%
    httr2::request() %>%
    httr2::req_url_path_append(name) %>%
    httr2::req_url_query(!!!params) %>%
    httr2::req_headers(
      accept = "application/json"
    ) %>%
    httr2::req_perform(error_call = NULL)

  return(resp_to_tibble(rp))
}


#' Flatten a GlobalNames verification response into a tibble
#'
#' Coerce the parsed JSON returned by the GlobalNames Verifier into a tibble,
#' keeping the scalar fields of each name's `bestResult` and dropping nested
#' lists such as `scoreDetails`. Unmatched names yield a row of `NA`.
#'
#' @param rp An httr2 response from the verifier `/verifications` endpoint.
#' @return A tibble with one row per input name.
#' @noRd
resp_to_tibble <- function(rp) {
  body <- httr2::resp_body_json(rp)
  names_list <- body$names %||% list()

  rows <- lapply(names_list, function(n) {
    best_result <- n$bestResult %||% list()
    # drop nested lists (e.g. scoreDetails), keeping only scalar fields
    best_result <- best_result[!vapply(best_result, is.list, logical(1))]
    # `overall_matchType` is the name-level match; `bestResult` keeps its own
    # `matchType`, so name them apart to avoid duplicate columns.
    row <- c(list(input_name = n$name, overall_matchType = n$matchType), best_result)
    row <- lapply(row, function(x) if (is.null(x)) NA else x) # NULL -> NA (unmatched names)
    dplyr::as_tibble(row)
  })

  dplyr::bind_rows(rows)
}
