#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @description This operator allows for chaining commands in a more readable way.
#' @keywords internal
#' @importFrom magrittr %>%
#' @return The left-hand side value is passed to the right-hand side function.
#' @usage lhs \%>\% rhs
#' @export
magrittr::`%>%`

#' Pipe operator
#'
#' @name %<>%
#' @rdname pipe
#' @description This operator allows for chaining commands in a more readable way, while also updating the left-hand side value.
#' @keywords internal
#' @importFrom magrittr %<>%
#' @return The left-hand side value is modified by the right-hand side function and reassigned to the left-hand side.
#' @usage lhs \%<>\% rhs
#' @export
magrittr::`%<>%`


#' Pipe operator
#' use left if not NULL, else right
#' @name %||%
#' @noRd
`%||%` <- function(a, b) {
  if (!is.null(a)) a else b
}



#' Function to get total page available
#' @noRd
rl_page_size <- function(total_count){
  if (total_count > 100) {

    if (total_count %% 100 > 0) { # there is remaining
      pg_size <- total_count %/% 100 +1
    }else{
      pg_size <- total_count %/% 100
    }

  }else{
    pg_size <- 1
  }

  return(pg_size)
}

# a function to return NA if NULL
#' @noRd
remove_null <- function(x){
  if (is.null(x)) {
    x <- NA
  }else{
    x <- x
  }
  return(gsub("<p>|</p>|<em>|</em>|<a>|</a>", "", x))
}


# nocov start
#' Perform request
#' @noRd
perform_request <- function(base_url, params = NULL) {

  suppressMessages(rl_check_api())
  user_agent <- "redlist R package (https://stangandaho.github.io/redlist)"

  if (is.null(params)) {
    rp <- base_url %>%
      httr2::request() %>%
      httr2::req_headers(
        accept = "application/json",
        Authorization = Sys.getenv("REDLIST_API")
      ) %>%
      httr2::req_user_agent(user_agent) %>%
      httr2::req_perform(error_call = NULL)
  }else{
    rp <- base_url %>%
      httr2::request() %>%
      httr2::req_url_query(!!!params) %>%
      httr2::req_headers(
        accept = "application/json",
        Authorization = Sys.getenv("REDLIST_API")
      ) %>%
      httr2::req_user_agent(user_agent) %>%
      httr2::req_perform(error_call = NULL)
  }

  return(rp)
}
# nocov end

#' JSON to data frame
#'
#' Coerce JSON arrays containing only records (JSON objects) into a data frame.
#' Extracts and cleans text content using HTML parsing.
#'
#' @param json_resp A nested list or parsed JSON structure (e.g., from `jsonlite::fromJSON`)
#'        that represents an array of JSON objects.
#' @return A tibble where each column represents a field extracted from the JSON objects.
#' @noRd
json_to_df <- function(json_resp) {
  unlisted <- unlist(json_resp)
  unlisted_names <- names(unlisted)

  out_data <- lapply(unique(unlisted_names), function(u_name){
    value_to_parse <- unlisted[which(unlisted_names == u_name)]
    value <- lapply(value_to_parse, function(v){
      rvest::read_html(paste0("<html><body>", v, "</body></html>")) %>%
        rvest::html_text(trim = TRUE)
    }) %>% unlist()

    index_df <- data.frame(i = value)
    colnames(index_df) <- gsub("\\.", "_", u_name)
    colnames(index_df) <- gsub("^assessments_", "", colnames(index_df))
    index_df
  })
  # Find the max number of rows
  max_rows <- max(sapply(out_data, nrow))

  # Pad each dataframe with NA if necessary
  parsed <- lapply(out_data, function(df) {
    n_missing <- max_rows - nrow(df)
    if (n_missing > 0) {
      df[(nrow(df) + 1):max_rows, ] <- NA
    }
    df
  })
  # Remove duplicate columns (keep first occurrence)
  parsed <- parsed[!duplicated(unlist(lapply(parsed, names)))] %>%
    dplyr::bind_cols(.name_repair = "universal") %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                                .fns = fill_na_with_previous)) %>%
    dplyr::distinct(.keep_all = TRUE) %>%
    dplyr::as_tibble()

  return(parsed)
}


# nocov start
#' Get total number of species assessed by IUCN
#'
#' This function retrieves the total number of species assessed by the IUCN Red
#' List
#'
#' @param url A character string specifying the query url
#'
#' @return A numeric value representing the total number of species assessed.
#'
#' @noRd
rl_total_records <- function(url){
  suppressMessages(rl_check_api())

  query_url <- url %>%
    httr2::request() %>%
    httr2::req_headers(
      accept = "application/json",
      Authorization = Sys.getenv("redlist_api")
    ) %>%
    httr2::req_perform()

  total_count <- as.numeric(query_url$headers$`Total-Count`)
  return(total_count)
}


#' Paginated API query handler for IUCN endpoints
#'
#' Generic function to handle IUCN paginated API queries with optional filters and expand.grid support.
#'
#' @param base_url Character. The base API URL endpoint (without the trailing slash and key path).
#' @param key_param Character. The path parameter name to insert into the URL (e.g., "code", "name").
#' @param key_values Vector. One or more values to substitute for the key_param in the path.
#' @param query_params Named list of additional query parameters to expand via expand.grid.
#' @param auto_page Logical. If `TRUE` and no `page` parameter is provided, auto-paginates based on total records.
#'
#' @return A tibble with the combined results of all parameterized API queries.
#' @noRd
rl_paginated_query <- function(param_list,
                               endpoint_name,
                               base_url) {
  suppressMessages(rl_check_api())

  multiple_out_df <- data.frame()
  ## Handle total page query
  tcode <- list(); tpage <- list()
  not_null_na_pages <- all(is.na(param_list$page)) || all(is.null(param_list$page))
  if (not_null_na_pages) {
    for (epn in param_list[[endpoint_name]]) {
      url_prefix <- paste0(base_url, "/", epn)
      total_page <- rl_page_size(rl_total_records(url_prefix))
      tpage[[as.character(epn)]] <- 1:total_page

      tcode[[as.character(epn)]] <- rep(epn)

    }

    param_list$page <- unlist(tpage)
    param_list$code <- unlist(tcode)
    param_grid <- expand.grid(param_list, stringsAsFactors = FALSE)
  }
  else{
    param_grid <- expand.grid(param_list, stringsAsFactors = FALSE)

  }
  # Perform all request
  sb <- cli::cli_status("{cli::symbol$arrow_right} Retrieving {nrow(param_grid)} request{?s}")
  for(r in 1:nrow(param_grid)){
    url_prefix <- paste0(base_url, "/", param_grid[r, endpoint_name])
    ind_query_params <- list()
    for (p in colnames(param_grid)[colnames(param_grid) != endpoint_name]) {
      ind_query_params[[p]] <- if(is.na(param_grid[r, p])){NULL}else{tolower(param_grid[r, p])}
    }


    parsed_url <- paste0(url_prefix) %>%
      perform_request(params = ind_query_params)

    out <- parsed_url %>%
      httr2::resp_body_json() %>%
      json_to_df()

    multiple_out_df <- bind_rows(multiple_out_df, out)

    cli::cli_status_update(id = sb,
                           "{cli::symbol$arrow_right} Got {r} request{?s}, retrieving {paste0(round(r*100/nrow(param_grid), 1), '%')}")
  Sys.sleep(0.5)
  }
  cli::cli_status_clear(id = sb)
  cli::cli_alert_success("Downloads done.")
  # End of request

  call_out <- multiple_out_df %>%
    dplyr::as_tibble() %>%
    dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                                .fns = coerce_char)) %>%
    dplyr::distinct(.keep_all = TRUE)

  return(call_out)

}
# nocov end

#' Fill NA
#' Fill NA in a vector with previous non-na
#' @noRd
fill_na_with_previous <- function(x) {
  for (i in seq_along(x)) {
    if(is.na(x[i])){
      x[i] <- x[i-1]
    }
  }

  return(x)
}


# Ensure sf is available, prompting an interactive install when possible.
#' @noRd
rl_need_sf <- function() {
  rlang::check_installed("sf", reason = "to compute spatial Red List metrics (EOO and AOO).")
}

# Ensure rgbif is available, prompting an interactive install when possible.
#' @noRd
rl_need_rgbif <- function() {
  rlang::check_installed("rgbif", reason = "to retrieve GBIF occurrence records.")
}

# Turn occurrence input into an sf geometry projected to a local equal area
# system in metres, so areas and the AOO grid are measured correctly.
# Accepts an sf POINT object (e.g. from rl_occurrences()) or a data frame with
# longitude and latitude columns.
#' @noRd
rl_prepare_points <- function(x, coords = c("longitude", "latitude"), crs = 4326) {
  rl_need_sf()

  if (inherits(x, "sf")) {
    geom_type <- as.character(unique(sf::st_geometry_type(x)))
    if (!all(geom_type %in% c("POINT", "MULTIPOINT"))) {
      cli::cli_abort("{.arg x} must be an sf object with POINT geometry.")
    }
    points <- sf::st_geometry(x)
    if (is.na(sf::st_crs(points))) {
      sf::st_crs(points) <- crs
    }
  } else if (is.data.frame(x)) {
    if (!all(coords %in% names(x))) {
      cli::cli_abort(c(
        "Coordinate columns {.val {coords}} were not found in {.arg x}.",
        i = "Pass the longitude and latitude column names with {.arg coords}."
      ))
    }
    xy <- x[, coords]
    xy <- xy[rowSums(is.na(xy)) == 0, , drop = FALSE]
    if (nrow(xy) == 0) {
      cli::cli_abort("No records with complete coordinates were found in {.arg x}.")
    }
    points <- sf::st_geometry(sf::st_as_sf(xy, coords = coords, crs = crs))
  } else {
    cli::cli_abort("{.arg x} must be an sf object or a data frame of coordinates.")
  }

  # Remember the input CRS so callers can return polygons aligned with the
  # coordinates the user supplied.
  orig_crs <- sf::st_crs(points)

  # Project geographic coordinates to a Lambert azimuthal equal area system
  # centred on the data, so that both the convex hull area and the 2 km grid
  # are computed in metres.
  if (isTRUE(sf::st_is_longlat(points))) {
    cc <- sf::st_coordinates(points)
    laea <- sprintf(
      "+proj=laea +lat_0=%f +lon_0=%f +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs",
      mean(cc[, 2]), mean(cc[, 1])
    )
    points <- sf::st_transform(points, laea)
  }

  attr(points, "rl_orig_crs") <- orig_crs
  points
}

# IUCN criterion B1 (EOO) spatial thresholds, in square kilometres.
# Returns the most threatened band the value reaches, or NA when it meets none.
#' @noRd
rl_b1_category <- function(area_km2) {
  if (is.na(area_km2)) return(NA_character_)
  if (area_km2 < 100) {
    "CR"
  } else if (area_km2 < 5000) {
    "EN"
  } else if (area_km2 < 20000) {
    "VU"
  } else {
    NA_character_
  }
}

# IUCN criterion B2 (AOO) spatial thresholds, in square kilometres.
#' @noRd
rl_b2_category <- function(area_km2) {
  if (is.na(area_km2)) return(NA_character_)
  if (area_km2 < 10) {
    "CR"
  } else if (area_km2 < 500) {
    "EN"
  } else if (area_km2 < 2000) {
    "VU"
  } else {
    NA_character_
  }
}


# Coerce character to numeric or boolean
coerce_char <- function(x) {
  # Try to convert to logical (TRUE/FALSE)
  logical_vals <- tolower(x)
  if (all(logical_vals %in% c("true", "false", "na"), na.rm = TRUE)) {
    return(as.logical(logical_vals))
  }
  # Try to convert to numeric
  suppressWarnings(num_x <- as.numeric(x))
  if (all(!is.na(num_x) | is.na(x))) {
    return(num_x)
  }
  # Return as-is (character)
  return(x)
}

