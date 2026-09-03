#' IUCN Red List taxa by scientific name
#'
#' Retrieve species assessments using scientific names (Latin binomials).
#' Returns summary assessment data including both latest and historic assessments.
#'
#' When the supplied name is not the one the IUCN Red List uses (a common case
#' for names coming from GBIF), the API returns a *404* and, if `resolve = TRUE`,
#' this function calls [rl_name_resolve()] to recover the accepted IUCN name and
#' retries the request with it. The resolved-name provenance is then appended as
#' the extra columns `outlink`, `entryDate`, `currentCanonicalFull`, `isSynonym`
#' and `matchType`.
#'
#' @param genus_name Character. The genus name (required).
#' @param species_name Character. The species name (required).
#' @param infra_name Character. The infraspecific name (optional).
#' @param subpopulation_name Character. The subpopulation name (optional).
#' @param resolve Logical. If `TRUE` (default), attempt to resolve the name via
#'   [rl_name_resolve()] and retry when the IUCN Red List returns a 404 (species
#'   not found). Set to `FALSE` to fail instead.
#'
#' @return A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column represents a unique API response JSON key.
#' The tibble contains assessment data for the specified taxon, including taxon details.
#' When the name had to be resolved, the columns `input_name`,
#' `isSynonym`, `entryDate`, and `matchType` from [rl_name_resolve()]
#' are appended.
#'
#' @seealso [rl_name_resolve()]
#'
#' @examples \dontrun{
#' # Get assessments for Panthera leo (lion)
#' rl_scientific_name(genus_name = "Panthera", species_name = "leo")
#'
#' # A GBIF synonym that IUCN lists under another name is resolved automatically
#' rl_scientific_name(genus_name = "Corvinella", species_name = "corvina")
#'}
#' @export
rl_scientific_name <- function(genus_name,
                               species_name,
                               infra_name = NULL,
                               subpopulation_name = NULL,
                               resolve = TRUE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/scientific_name"

  # Build query parameters
  query_params <- list(
    genus_name = genus_name,
    species_name = species_name,
    infra_name = infra_name %||% NULL,
    subpopulation_name = subpopulation_name %||% NULL
  )

  # A name unknown to the IUCN Red List returns a 404; catch it so we can try
  # to resolve the name instead of erroring out.
  resp <- tryCatch(
    perform_request(base_url = base_url, params = query_params),
    httr2_http_404 = function(e) NULL
  )

  if (is.null(resp)) {
    if (!resolve) {
      cli::cli_abort(c(
        "No IUCN Red List taxon found for {.val {trimws(paste(genus_name, species_name, infra_name))}}.",
        i = "Set {.code resolve = TRUE} to attempt a name match via {.fn rl_name_resolve}."
      ))
    }

    resolved <- rl_name_resolve(
      genus_name = genus_name,
      species_name = species_name,
      infra_name = infra_name,
      subpopulation_name = subpopulation_name
    )

    # The accepted IUCN name, split into genus/species to re-query.
    accepted <- suppressWarnings(resolved$currentCanonicalSimple %||% NA)
    if (is.na(accepted) || !nzchar(as.character(accepted))) {
      cli::cli_abort(
        "Could not resolve {.val {trimws(paste(genus_name, species_name, infra_name))}} to an IUCN Red List name."
      )
    }
    parts <- strsplit(trimws(as.character(accepted)), "\\s+")[[1]]

    query_params <- list(
      genus_name = parts[1],
      species_name = if (length(parts) >= 2) parts[2] else NULL,
      infra_name = if (length(parts) >= 3) paste(parts[-(1:2)], collapse = " ") else NULL,
      subpopulation_name = subpopulation_name %||% NULL
    )

    out <- perform_request(base_url = base_url, params = query_params) %>%
      httr2::resp_body_json() %>%
      json_to_df()

    # Append the resolved-name provenance columns.
    provenance <- c("input_name", "isSynonym", "entryDate", "matchType")
    out <- dplyr::mutate(
      out,
      input_name = resolved$input_name[1],
      isSynonym = resolved$isSynonym[1],
      entryDate = resolved$entryDate[1],
      matchType = resolved$matchType[1]
    ) %>%
      dplyr::relocate(dplyr::all_of(provenance), .before = 1)

    return(out)
  }

  return(json_to_df(httr2::resp_body_json(resp)))
}
