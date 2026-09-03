#' Assessment-readiness checks for occurrence data
#'
#' Run a set of data quality checks on occurrence records before they are passed
#' to the criterion B metrics [rl_eoo()] and [rl_aoo()]. The checks flag issues
#' that would compromise or bias the metrics. By default nothing is removed; the
#' function reports what it finds so the assessor can decide how to proceed. Set
#' `correct` to also drop the records behind the removable issues and return the
#' cleaned data, ready to pass straight to [rl_eoo()] or [rl_aoo()].
#'
#' The available checks are:
#' \describe{
#'   \item{`unique_localities`}{fewer than 3 unique localities (EOO is undefined
#'     below 3 points). Report only.}
#'   \item{`institution_diversity`}{all records from a single institution
#'     (possible collection bias). Report only.}
#'   \item{`recency`}{no records within the recency window (the data may be
#'     stale). Report only.}
#'   \item{`duplicates`}{records sharing the same coordinate, event date, and
#'     institution. Removable.}
#'   \item{`coordinate_precision`}{coordinates coarser than a threshold, from few
#'     decimal places or a large stated uncertainty (too imprecise for the 2 by
#'     2 km AOO grid). Removable.}
#'   \item{`outliers`}{spatial outliers far from the main cluster, which inflate
#'     the EOO convex hull. Removable. Needs `CoordinateCleaner`.}
#'   \item{`country`}{coordinates that fall outside the record's stated country
#'     (sign or transposition errors). Removable. Needs `CoordinateCleaner` and a
#'     `countryCode` column.}
#'   \item{`ocean_points`}{records in the ocean for a terrestrial taxon.
#'     Removable. Needs `CoordinateCleaner`.}
#'   \item{`centroids`}{country and capital centroids, biodiversity-institution
#'     and GBIF headquarters coordinates, and plain zeros. Removable. Needs
#'     `CoordinateCleaner`.}
#' }
#' Checks needing `CoordinateCleaner` are skipped, with a note, when it is not
#' installed.
#'
#' @param x Occurrence records: an `sf` POINT object (for example the output of
#'   [rl_occurrences()]) or a data frame with longitude and latitude columns.
#' @param coords Character vector of length two giving the longitude and latitude
#'   column names when `x` is a data frame. Default
#'   `c("decimalLongitude", "decimalLatitude")`.
#' @param checks Character vector selecting which checks to run. Default `NULL`
#'   runs every check.
#' @param correct Which removable issues to fix by dropping the offending
#'   records. `FALSE` (default) removes nothing and returns the report. `TRUE`
#'   removes every clear-error check that was run (`duplicates`, `outliers`,
#'   `country`, `ocean_points`, `centroids`) but not `coordinate_precision`,
#'   since dropping imprecise but real records is a completeness trade-off; name
#'   it explicitly to apply it. A character vector selects specific checks,
#'   including `coordinate_precision`. The report-only checks
#'   (`unique_localities`, `institution_diversity`, `recency`) describe the
#'   dataset as a whole and cannot be corrected by removing records.
#' @param recent_years Number of years back from today within which at least one
#'   record should fall. Default `20`.
#' @param precision_degrees Coordinate precision threshold in decimal degrees.
#'   Records coarser than this (too few decimal places, or a stated uncertainty
#'   larger than this distance) are flagged. The default, `2 / 111.32` (about
#'   0.018 degrees), corresponds to the 2 km AOO reference cell, so a record is
#'   flagged only when it genuinely cannot be placed in a 2 km grid cell.
#' @param terrestrial Logical. Treat the taxon as terrestrial and check for
#'   records in the ocean. Default `TRUE`.
#' @param outlier_multiplier Sensitivity of the outlier check: the multiplier
#'   passed to [CoordinateCleaner::cc_outl()]. Smaller flags more points. Default
#'   `5`.
#'
#' @return When `correct = FALSE`, a tibble with one row per check and the
#'   columns `check`, `status` (`"pass"`, `"warn"`, `"fail"` or `"skip"`),
#'   `n_flagged` and `detail`, returned invisibly after the results are printed.
#'   When `correct` removes issues, the cleaned occurrences are returned instead
#'   (same class as `x`), with the report attached as the `"report"` attribute.
#'
#' @seealso [rl_occurrences()], [rl_eoo()], [rl_aoo()]
#'
#' @examples \dontrun{
#' occ <- rl_occurrences("Afzelia africana", limit = 500, country = "BJ")
#'
#' # Report only
#' rl_check_occurrences(occ)
#'
#' # Clean and feed straight into a metric
#' clean_occ <- rl_check_occurrences(occ, correct = TRUE)
#' rl_aoo(clean_occ)
#' }
#' @export
rl_check_occurrences <- function(x,
                                 coords = c("decimalLongitude", "decimalLatitude"),
                                 checks = NULL,
                                 correct = FALSE,
                                 recent_years = 20,
                                 precision_degrees = 2 / 111.32,
                                 terrestrial = TRUE,
                                 outlier_multiplier = 5) {
  all_checks <- c("unique_localities", "institution_diversity", "recency",
                  "duplicates", "coordinate_precision", "outliers", "country",
                  "ocean_points", "centroids")
  correctable <- c("duplicates", "coordinate_precision", "outliers", "country",
                   "ocean_points", "centroids")

  if (is.null(checks)) checks <- all_checks
  unknown <- setdiff(checks, all_checks)
  if (length(unknown) > 0) {
    cli::cli_abort(c(
      "Unknown {cli::qty(unknown)}check{?s}: {.val {unknown}}.",
      i = "Choose from {.val {all_checks}}."
    ))
  }

  parts <- rl_occ_frame(x, coords = coords)
  df <- parts$df
  lon <- parts$lon
  lat <- parts$lat

  # Records without coordinates cannot be checked or mapped; drop them first.
  ok <- !is.na(lon) & !is.na(lat)
  if (any(!ok)) {
    x <- x[ok, , drop = FALSE]
    df <- df[ok, , drop = FALSE]
    lon <- lon[ok]
    lat <- lat[ok]
    cli::cli_alert_info("Dropped {sum(!ok)} record{?s} without coordinates.")
  }
  n <- length(lon)

  has_cc <- requireNamespace("CoordinateCleaner", quietly = TRUE)
  # The records describe a single taxon, so the CoordinateCleaner tests treat
  # them as one group. Grouping by scientificName would split authorship and
  # synonym variants and skip the outlier test on the small pieces.
  species <- rep("sp", n)

  results <- list()
  flags <- list()
  add <- function(check, status, n_flagged, detail) {
    results[[length(results) + 1]] <<- dplyr::tibble(
      check = check, status = status, n_flagged = n_flagged, detail = detail
    )
  }
  # Record a removable flag vector and its report row.
  report_flag <- function(name, bad, detail_pass, detail_fail) {
    if (is.null(bad)) {
      detail <- if (!has_cc) {
        "Install CoordinateCleaner to run this check."
      } else {
        "Skipped: check requirements not met (for example a missing column)."
      }
      add(name, "skip", NA_integer_, detail)
      return(invisible())
    }
    flags[[name]] <<- bad
    nbad <- sum(bad, na.rm = TRUE)
    if (nbad == 0) {
      add(name, "pass", 0L, detail_pass)
    } else {
      add(name, "fail", nbad, sprintf(detail_fail, nbad, n))
    }
  }

  if ("unique_localities" %in% checks) {
    n_unique <- nrow(unique(data.frame(lon = lon, lat = lat)))
    if (n_unique < 3) {
      add("unique_localities", "fail", n_unique,
          sprintf("%d unique localities; EOO needs at least 3.", n_unique))
    } else {
      add("unique_localities", "pass", n_unique,
          sprintf("%d unique localities.", n_unique))
    }
  }

  if ("institution_diversity" %in% checks) {
    if ("institutionCode" %in% names(df)) {
      inst <- df$institutionCode[!is.na(df$institutionCode) & nzchar(df$institutionCode)]
      n_inst <- length(unique(inst))
      if (length(inst) == 0) {
        add("institution_diversity", "warn", 0L, "No institution information available.")
      } else if (n_inst <= 1) {
        add("institution_diversity", "fail", n,
            sprintf("All records from a single institution (%s).", unique(inst)[1]))
      } else {
        add("institution_diversity", "pass", n_inst,
            sprintf("%d distinct institutions.", n_inst))
      }
    } else {
      add("institution_diversity", "skip", NA_integer_, "No institutionCode column.")
    }
  }

  if ("recency" %in% checks) {
    year <- rl_occ_year(df)
    this_year <- as.integer(format(Sys.Date(), "%Y"))
    if (all(is.na(year))) {
      add("recency", "skip", NA_integer_, "No year or eventDate information.")
    } else {
      recent <- sum(year >= this_year - recent_years, na.rm = TRUE)
      if (recent == 0) {
        add("recency", "fail", 0L,
            sprintf("No records in the last %d years (newest: %d).",
                    recent_years, max(year, na.rm = TRUE)))
      } else {
        add("recency", "pass", recent,
            sprintf("%d record%s within the last %d years.",
                    recent, if (recent == 1) "" else "s", recent_years))
      }
    }
  }

  if ("duplicates" %in% checks) {
    key <- data.frame(lon = round(lon, 6), lat = round(lat, 6))
    if ("eventDate" %in% names(df)) key$eventDate <- as.character(df$eventDate)
    if ("institutionCode" %in% names(df)) key$institutionCode <- as.character(df$institutionCode)
    report_flag("duplicates", duplicated(key),
                "No duplicate records.",
                "%d of %d records are duplicates.")
  }

  if ("coordinate_precision" %in% checks) {
    coarse <- rl_occ_coarse(df, lon, lat, precision_degrees)
    n_coarse <- sum(coarse, na.rm = TRUE)
    flags[["coordinate_precision"]] <- coarse
    if (n_coarse == 0) {
      add("coordinate_precision", "pass", 0L,
          sprintf("All coordinates finer than %g degrees.", precision_degrees))
    } else if (n_coarse > n / 2) {
      add("coordinate_precision", "fail", n_coarse,
          sprintf("%d of %d records coarser than %g degrees.", n_coarse, n, precision_degrees))
    } else {
      add("coordinate_precision", "warn", n_coarse,
          sprintf("%d of %d records coarser than %g degrees.", n_coarse, n, precision_degrees))
    }
  }

  if ("outliers" %in% checks) {
    bad <- if (!has_cc) NULL else tryCatch({
      flg <- CoordinateCleaner::cc_outl(
        data.frame(species = species, lon = lon, lat = lat),
        lon = "lon", lat = "lat", species = "species",
        mltpl = outlier_multiplier, value = "flagged", verbose = FALSE
      )
      !flg
    }, error = function(e) NULL)
    report_flag("outliers", bad,
                "No spatial outliers.",
                "%d of %d records are spatial outliers.")
  }

  if ("country" %in% checks) {
    bad <- rl_cc_country(df, lon, lat, has_cc)
    report_flag("country", bad,
                "All coordinates fall inside their stated country.",
                "%d of %d records fall outside their stated country.")
  }

  if ("ocean_points" %in% checks) {
    if (!terrestrial) {
      add("ocean_points", "skip", NA_integer_, "Taxon marked as not terrestrial.")
    } else {
      bad <- if (!has_cc) NULL else tryCatch({
        flg <- CoordinateCleaner::cc_sea(
          data.frame(lon = lon, lat = lat), lon = "lon", lat = "lat",
          value = "flagged", verbose = FALSE
        )
        !flg
      }, error = function(e) NULL)
      report_flag("ocean_points", bad,
                  "No records in the ocean.",
                  "%d of %d records fall in the ocean.")
    }
  }

  if ("centroids" %in% checks) {
    bad <- if (!has_cc) NULL else tryCatch({
      flg <- CoordinateCleaner::clean_coordinates(
        data.frame(species = species, lon = lon, lat = lat),
        lon = "lon", lat = "lat", species = "species",
        tests = c("capitals", "centroids", "gbif", "institutions", "zeros", "equal"),
        value = "flagged", verbose = FALSE
      )
      !flg
    }, error = function(e) NULL)
    report_flag("centroids", bad,
                "No centroid, institution, or zero coordinates.",
                "%d of %d records are centroids, institutions, or zeros.")
  }

  report <- dplyr::bind_rows(results)
  rl_print_checks(report)

  # Optionally drop the records behind the removable issues and return the
  # cleaned data instead of the report. `correct = TRUE` fixes the clear error
  # checks but leaves `coordinate_precision`, since removing imprecise but real
  # records is a completeness trade-off that must be requested by name.
  to_correct <- if (isTRUE(correct)) {
    setdiff(correctable, "coordinate_precision")
  } else if (is.character(correct)) {
    intersect(correct, correctable)
  } else {
    character(0)
  }
  to_correct <- intersect(to_correct, names(flags))

  if (length(to_correct) == 0) {
    return(invisible(report))
  }

  drop <- rep(FALSE, n)
  for (nm in to_correct) drop <- drop | (flags[[nm]] %in% TRUE)

  cleaned <- x[!drop, , drop = FALSE]
  cli::cli_alert_info(
    "Corrected {.val {to_correct}}: removed {sum(drop)} of {n} record{?s}."
  )
  if (sum(drop) > n / 2) {
    cli::cli_warn(c(
      "More than half of the records were removed.",
      i = "Review the flagged checks; for example raise {.arg precision_degrees} or narrow {.arg correct}."
    ))
  }
  attr(cleaned, "report") <- report
  cleaned
}


#' Flag records whose coordinates fall outside their stated country
#'
#' Convert GBIF `countryCode` (ISO2) to ISO3 using the reference table bundled
#' with CoordinateCleaner, then run [CoordinateCleaner::cc_coun()].
#'
#' @return A logical vector (TRUE = mismatch) or NULL when the check cannot run.
#' @noRd
rl_cc_country <- function(df, lon, lat, has_cc) {
  if (!has_cc || !"countryCode" %in% names(df)) return(NULL)
  tryCatch({
    ref <- CoordinateCleaner::countryref
    ref <- ref[!duplicated(ref$iso2), c("iso2", "iso3")]
    iso3 <- ref$iso3[match(as.character(df$countryCode), ref$iso2)]
    if (all(is.na(iso3))) return(NULL)
    dd <- data.frame(lon = lon, lat = lat, iso3 = iso3)
    flg <- CoordinateCleaner::cc_coun(
      dd, lon = "lon", lat = "lat", iso3 = "iso3",
      value = "flagged", verbose = FALSE
    )
    (!flg) & !is.na(iso3)
  }, error = function(e) NULL)
}


#' Extract a data frame and coordinate vectors from occurrence input
#' @noRd
rl_occ_frame <- function(x, coords = c("decimalLongitude", "decimalLatitude")) {
  if (inherits(x, "sf")) {
    rl_need_sf()
    cc <- sf::st_coordinates(x)
    list(df = sf::st_drop_geometry(x), lon = cc[, 1], lat = cc[, 2])
  } else if (is.data.frame(x)) {
    if (!all(coords %in% names(x))) {
      cli::cli_abort(c(
        "Coordinate columns {.val {coords}} were not found in {.arg x}.",
        i = "Pass the longitude and latitude column names with {.arg coords}."
      ))
    }
    list(df = x, lon = x[[coords[1]]], lat = x[[coords[2]]])
  } else {
    cli::cli_abort("{.arg x} must be an sf object or a data frame of occurrences.")
  }
}


#' Pull a year vector from occurrence records
#' @noRd
rl_occ_year <- function(df) {
  year <- rep(NA_integer_, nrow(df))
  if ("year" %in% names(df)) {
    year <- suppressWarnings(as.integer(df$year))
  }
  if (all(is.na(year)) && "eventDate" %in% names(df)) {
    year <- suppressWarnings(as.integer(substr(as.character(df$eventDate), 1, 4)))
  }
  year
}


#' Flag records coarser than a coordinate precision threshold
#' @noRd
rl_occ_coarse <- function(df, lon, lat, precision_degrees) {
  # Count decimal places of the coordinates; fewer places than the threshold
  # implies coarser precision.
  decimals <- function(v) {
    s <- sub("0+$", "", format(v, scientific = FALSE, trim = TRUE))
    ifelse(grepl("\\.", s), nchar(sub("^[^.]*\\.", "", s)), 0L)
  }
  needed <- ceiling(-log10(precision_degrees))
  coarse <- pmax(decimals(lon), decimals(lat)) < needed

  # Also treat a large stated uncertainty as coarse.
  if ("coordinateUncertaintyInMeters" %in% names(df)) {
    unc <- suppressWarnings(as.numeric(df$coordinateUncertaintyInMeters))
    coarse <- coarse | (!is.na(unc) & unc > precision_degrees * 111320)
  }
  coarse
}


#' Print a readiness-check report with cli
#' @noRd
rl_print_checks <- function(report) {
  cli::cli_h3("Occurrence readiness checks")
  for (i in seq_len(nrow(report))) {
    row <- report[i, ]
    msg <- "{row$check}: {row$detail}"
    switch(row$status,
      pass = cli::cli_alert_success(msg),
      warn = cli::cli_alert_warning(msg),
      fail = cli::cli_alert_danger(msg),
      skip = cli::cli_alert_info(msg)
    )
  }
  invisible(report)
}
