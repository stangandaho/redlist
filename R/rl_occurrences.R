#' Retrieve GBIF occurrence records for a taxon
#'
#' Fetch occurrence records from the Global Biodiversity Information Facility
#' (GBIF) and return them as a clean `sf` POINT object ready for the criterion B
#' metrics [rl_eoo()] and [rl_aoo()]. This uses the public GBIF search API
#' through `rgbif`, so no GBIF account, username, or password is needed. Only
#' bulk downloads (the GBIF download API) require credentials, and those are not
#' used here.
#'
#' Because records are queried by the GBIF backbone taxon key, occurrences that
#' GBIF indexes under synonyms of the accepted name are already included.
#'
#' @param x The taxon to retrieve. One of:
#'   * a scientific name, for example `"Afzelia africana"`;
#'   * a GBIF backbone taxon key (a number);
#'   * a data frame from a name resolution step (for example the output of
#'     [rl_name_resolve()] or [rl_scientific_name()]), from which a name column
#'     is detected.
#' @param limit Maximum number of records to return. Default `500`. Use `Inf`
#'   to fetch every available record. The search API is paged in blocks of 300
#'   behind the scenes, up to its ceiling of 100000 records; beyond that a GBIF
#'   download (which needs an account) would be required.
#' @param country Optional ISO 3166-1 alpha-2 country code to restrict records,
#'   for example `"BJ"` for Benin. Pass a vector for several countries (matched
#'   as OR), for example `c("BJ", "NG")`.
#' @param year Optional year filter. A single year (`2000`), a `"min,max"` range
#'   string (`"2000,2020"`, open-ended as `"2000,*"` or `"*,2000"`), or a
#'   comparator string (`">2025"`, `">=2025"`, `"<2000"`, `"<=2000"`). A range is
#'   one comma-separated string, not a vector.
#' @param basis_of_record Optional GBIF basis of record filter, for example
#'   `"HUMAN_OBSERVATION"` or `"PRESERVED_SPECIMEN"`. Pass a vector for several
#'   types (matched as OR), for example
#'   `c("HUMAN_OBSERVATION", "MACHINE_OBSERVATION")`.
#' @param has_coordinate Logical. Keep only records that carry coordinates.
#'   Default `TRUE`.
#' @param has_geospatial_issue Logical. Keep records that GBIF flags with a
#'   geospatial issue. Default `FALSE` (drop flagged records).
#' @param correct Which readiness checks from [rl_check_occurrences()] to run
#'   after the download finishes, and apply. One of:
#'   * `NULL` (default): run no checks.
#'   * `TRUE`: run every check and drop the records behind the clear-error
#'     issues (`duplicates`, `outliers`, `country`, `ocean_points`,
#'     `centroids`).
#'   * a character vector of check names (for example
#'     `c("outliers", "duplicates")`): run those and drop the records they flag.
#'
#'   `coordinate_precision` is always reported but never applied here, since
#'   dropping imprecise but real records can gut the sample and bias the metrics;
#'   to apply it deliberately, call [rl_check_occurrences()] with
#'   `correct = "coordinate_precision"`. The report-only checks
#'   (`unique_localities`, `institution_diversity`, `recency`) are reported but
#'   not corrected.
#'
#'   When any correction removes records the cleaned `sf` is returned; otherwise
#'   the readiness report is attached to the returned `sf` as its `"report"`
#'   attribute. For finer control (thresholds, report without correcting), call
#'   [rl_check_occurrences()] directly.
#' @param progress Logical. Show a progress bar while records are downloaded.
#'   Default `TRUE`.
#' @param crs Coordinate reference system for the returned `sf` object. Default
#'   `4326` (WGS84), the system GBIF coordinates use.
#' @param ... Further named filters passed straight to [rgbif::occ_search()],
#'   for example `continent`, `institutionCode`, `elevation`, or
#'   `coordinateUncertaintyInMeters`.
#'
#' @return An `sf` POINT object (WGS84 by default) with one row per occurrence
#'   record and the GBIF fields returned by the search, such as `scientificName`,
#'   `eventDate`, `year`, `country`, `basisOfRecord`, `institutionCode`, and
#'   `coordinateUncertaintyInMeters`. When no record matches, an empty `sf`
#'   object is returned with a warning. Records with invalid coordinates
#'   (missing, out of range, null island, or absence records) are always
#'   dropped; further data quality checks run only when `correct` is set.
#'
#' @seealso [rl_check_occurrences()], [rl_eoo()], [rl_aoo()], [rl_name_resolve()]
#'
#' @examples \dontrun{
#' # By scientific name, capped at 300 records, Benin only
#' occ <- rl_occurrences("Afzelia africana", limit = 300, country = "BJ")
#'
#' # Pass any GBIF filter through `...`
#' occ <- rl_occurrences("Panthera leo", year = "2010,2020",
#'                       basis_of_record = "HUMAN_OBSERVATION")
#'
#' # Download, then run and correct specific checks
#' occ <- rl_occurrences("Afzelia africana", limit = 500, country = "BJ",
#'                       correct = c("outliers", "duplicates"))
#'
#' # Straight into a criterion B metric
#' rl_eoo(occ)
#' }
#' @export
rl_occurrences <- function(x,
                           limit = 500,
                           country = NULL,
                           year = NULL,
                           basis_of_record = NULL,
                           has_coordinate = TRUE,
                           has_geospatial_issue = FALSE,
                           correct = NULL,
                           progress = TRUE,
                           crs = 4326,
                           ...) {
  rl_need_rgbif()
  rl_need_sf()

  taxon_key <- rl_gbif_taxonkey(x)
  taxon_name <- attr(taxon_key, "canonical")

  # Accept comparator years (">2025", "<=2000") as a convenience.
  year <- rl_gbif_year(year)

  # Public search API filters. NULL entries are dropped by occ_search.
  filters <- list(
    taxonKey = taxon_key,
    country = country,
    year = year,
    basisOfRecord = basis_of_record,
    hasCoordinate = has_coordinate,
    hasGeospatialIssue = has_geospatial_issue,
    ...
  )

  occ <- rl_gbif_fetch(filters, limit = limit, progress = progress)

  if (is.null(occ) || nrow(occ) == 0) {
    cli::cli_warn("No GBIF occurrence records found for {.val {taxon_name}} with the given filters.")
    return(sf::st_sf(geometry = sf::st_sfc(crs = crs)))
  }

  # Warn when the search API ceiling was reached and records remain.
  total <- attr(occ, "gbif_count") %||% nrow(occ)
  if (is.infinite(limit) && total > nrow(occ)) {
    cli::cli_warn(c(
      "GBIF returned {total} records but the search API stops at {nrow(occ)}.",
      i = "Use a GBIF download (which needs an account) to fetch the remainder."
    ))
  }

  # Drop records that cannot form a valid point (missing, out of range, null
  # island) and explicit absence records. Further quality checks are opt-in.
  occ <- rl_valid_coords(occ)
  if (nrow(occ) == 0) {
    cli::cli_warn("No records with valid coordinates for {.val {taxon_name}}.")
    return(sf::st_sf(geometry = sf::st_sfc(crs = crs)))
  }

  cli::cli_alert_success("Retrieved {nrow(occ)} occurrence record{?s} for {.val {taxon_name}}.")

  points <- sf::st_as_sf(occ, coords = c("decimalLongitude", "decimalLatitude"),
                         crs = crs, remove = FALSE)

  if (!is.null(correct) && !isFALSE(correct)) {
    if (isTRUE(correct)) {
      sel_checks <- NULL        # every check
      sel_correct <- TRUE       # correct all clear-error issues
    } else if (is.character(correct)) {
      sel_checks <- correct     # run (and report) every named check
      # coordinate_precision is never applied here; it drops imprecise but real
      # records, so it stays a report-only flag inside rl_occurrences().
      sel_correct <- setdiff(correct, "coordinate_precision")
      if ("coordinate_precision" %in% correct) {
        cli::cli_inform(c(
          "{.val coordinate_precision} is reported but not applied here.",
          i = "Call {.fn rl_check_occurrences} with {.code correct = \"coordinate_precision\"} to apply it."
        ))
      }
    } else {
      cli::cli_abort("{.arg correct} must be {.code NULL}, {.code TRUE}, or a character vector of check names.")
    }

    cli::cli_alert_info("Download complete. Running occurrence checks ...")
    res <- rl_check_occurrences(points, checks = sel_checks, correct = sel_correct)
    if (inherits(res, "sf")) {
      return(res)
    }
    attr(points, "report") <- res
  }

  points
}


#' Resolve occurrence input to a GBIF backbone taxon key
#'
#' Turn a scientific name, a numeric key, or a resolution data frame into a GBIF
#' backbone taxon key, carrying the matched canonical name as an attribute.
#'
#' @param x A scientific name, a GBIF taxon key, or a data frame with a name.
#' @return An integer taxon key with a `"canonical"` attribute.
#' @noRd
rl_gbif_taxonkey <- function(x) {
  if (is.numeric(x)) {
    key <- as.integer(x[1])
    attr(key, "canonical") <- as.character(x[1])
    return(key)
  }

  if (is.character(x)) {
    name <- x[1]
  } else if (is.data.frame(x)) {
    candidates <- c("currentCanonicalSimple", "currentCanonicalFull", "taxon_scientific_name",
                    "scientificName", "scientific_name", "accepted_name", "name")
    col <- intersect(candidates, names(x))
    if (length(col) > 0) {
      name <- as.character(x[[col[1]]][1])
    } else if (all(c("genus_name", "species_name") %in% names(x))) {
      name <- trimws(paste(x$genus_name[1], x$species_name[1]))
    } else {
      cli::cli_abort(c(
        "Could not find a name column in {.arg x}.",
        i = "Pass a scientific name, a GBIF taxon key, or a data frame with a name column."
      ))
    }
  } else {
    cli::cli_abort("{.arg x} must be a scientific name, a GBIF taxon key, or a data frame.")
  }

  if (is.na(name) || !nzchar(name)) {
    cli::cli_abort("No usable name was found in {.arg x}.")
  }

  backbone <- rgbif::name_backbone(name = name)
  # `name_backbone()` returns a tibble; use `[[` so a missing column yields NULL
  # instead of a warning. When the name is a synonym in the GBIF backbone,
  # occurrences are indexed under the accepted taxon, so follow acceptedUsageKey
  # rather than the synonym's own usageKey (which returns no records).
  key <- backbone[["acceptedUsageKey"]] %||% backbone[["usageKey"]]
  if (is.null(key) || is.na(key)) {
    cli::cli_abort(c(
      "No GBIF backbone match for {.val {name}}.",
      i = "Try the name GBIF uses, or pass a GBIF taxon key directly."
    ))
  }
  key <- as.integer(key)
  # Report the accepted name (GBIF's `species` field) when the match was a
  # synonym, otherwise the matched canonical name.
  attr(key, "canonical") <- backbone[["species"]] %||% backbone[["canonicalName"]] %||% name
  key
}


#' Translate a comparator year into a GBIF range string
#'
#' GBIF's search API takes a single year or a `"min,max"` range, with `*` for an
#' open end. This accepts the convenience forms `">2025"`, `">=2025"`, `"<2000"`
#' and `"<=2000"` and rewrites them; anything else is returned unchanged.
#'
#' @param year A year, a `"min,max"` range, or a comparator string. May be NULL.
#' @return A GBIF-ready year string, or NULL.
#' @noRd
rl_gbif_year <- function(year) {
  if (is.null(year)) return(NULL)
  y <- trimws(as.character(year))
  if (!grepl("^[<>]=?", y)) return(y)

  op <- regmatches(y, regexpr("^[<>]=?", y))
  num <- suppressWarnings(as.integer(sub("^[<>]=?\\s*", "", y)))
  if (is.na(num)) {
    cli::cli_abort("Could not parse {.arg year} value {.val {year}}.")
  }
  switch(op,
    ">"  = paste0(num + 1L, ",*"),
    ">=" = paste0(num, ",*"),
    "<"  = paste0("*,", num - 1L),
    "<=" = paste0("*,", num)
  )
}


#' Page through the GBIF occurrence search API
#'
#' Call [rgbif::occ_search()] in blocks of 300 until `limit` records are
#' collected or the results are exhausted. Uses the public search API, so no
#' credentials are required.
#'
#' @param filters Named list of GBIF search filters (NULL entries are ignored).
#' @param limit Maximum number of records to collect.
#' @param progress Logical, whether to show a cli progress bar while paging.
#' @return A data frame of occurrence records, or `NULL` when none are found.
#' @noRd
rl_gbif_fetch <- function(filters, limit = 500, progress = TRUE) {
  filters <- filters[!vapply(filters, is.null, logical(1))]
  # A vector value makes rgbif run one search per element and return a list with
  # no combined $data. GBIF expresses OR as a ";"-joined string, so collapse any
  # multi-value filter into one. Ranges use a single "," string and stay as is.
  filters <- lapply(filters, function(v) if (length(v) > 1) paste(v, collapse = ";") else v)
  per_page <- 300L
  # The GBIF search API cannot page beyond 100000 records.
  hard_cap <- 100000L
  target <- min(limit, hard_cap)

  pages <- list()
  fetched <- 0L
  start <- 0L
  total <- 0L
  bar <- NULL

  repeat {
    page_limit <- min(per_page, target - fetched)
    if (page_limit <= 0) break

    args <- c(filters, list(limit = page_limit, start = start))
    res <- do.call(rgbif::occ_search, args)

    page <- res$data
    if (is.null(page) || !is.data.frame(page) || nrow(page) == 0) break

    pages[[length(pages) + 1]] <- page
    fetched <- fetched + nrow(page)
    start <- start + nrow(page)
    total <- res$meta$count %||% fetched

    # Start the bar once the total is known, then advance it each page.
    if (progress) {
      goal <- min(target, total)
      if (is.null(bar)) {
        bar <- cli::cli_progress_bar(
          "Downloading GBIF records",
          total = goal, .envir = environment()
        )
      }
      cli::cli_progress_update(set = min(fetched, goal), id = bar,
                               .envir = environment())
    }

    if (fetched >= target || start >= total || nrow(page) < page_limit) break
  }

  if (progress && !is.null(bar)) {
    cli::cli_progress_done(id = bar, .envir = environment())
  }

  if (length(pages) == 0) return(NULL)
  out <- dplyr::bind_rows(pages)
  attr(out, "gbif_count") <- total
  out
}


#' Drop records with invalid coordinates or explicit absence
#'
#' Always-on hygiene: keep only records with coordinates in range, not at null
#' island `(0, 0)`, and not marked as absences. Subtler quality issues are left
#' to [rl_check_occurrences()].
#'
#' @param occ A data frame with `decimalLongitude` and `decimalLatitude` columns.
#' @return The filtered data frame.
#' @noRd
rl_valid_coords <- function(occ) {
  lon <- occ$decimalLongitude
  lat <- occ$decimalLatitude

  keep <- !is.na(lon) & !is.na(lat) &
    abs(lon) <= 180 & abs(lat) <= 90 &
    !(lon == 0 & lat == 0)
  if ("occurrenceStatus" %in% names(occ)) {
    keep <- keep & (is.na(occ$occurrenceStatus) |
                      toupper(occ$occurrenceStatus) != "ABSENT")
  }
  occ[keep, , drop = FALSE]
}
