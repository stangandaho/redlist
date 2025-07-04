#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
#' @export
magrittr::`%>%`

#' Pipe operator
#'
#' @name %<>%
#' @rdname pipe
#' @keywords internal
#' @importFrom magrittr %<>%
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


# Check API working
#' @noRd
rl_check_api <- function(){
  redlist_api <- Sys.getenv("REDLIST_API")

  if (redlist_api == "") {
    cli::cli_abort("Any redlist API available. Use `rl_set_api()` function to set an API", call = NULL)
  }else{
    # Check the API is working
    api_response <- tryCatch({paste0("https://api.iucnredlist.org/api/v4/assessment/17946182") %>%
        httr2::request() %>%
        httr2::req_headers(
          accept = "application/json",
          Authorization = redlist_api
        ) %>%
        httr2::req_perform()},
        error = function(e){tolower(paste0(e))})

    if (any(grepl("401 unauthorized", api_response))) {
      cli::cli_abort("Your API is not working. Ckeck out! \n\n{symbol$arrow_right} Or go to {.url https://api.iucnredlist.org/users/edit} and recycle.",
                     call = NULL)
    }

    cli::cli_alert_success(
      paste0("Your API is working ", sample(c("\U0001F44D", "\u2728", "\U0001F389", "\U0001F38A"), 1))
    )
  }

}


#' Perform request
#' @noRd
perform_request <- function(base_url, params = NULL) {

  suppressMessages(rl_check_api())

  if (is.null(params)) {
    rp <- base_url %>%
      httr2::request() %>%
      httr2::req_headers(
        accept = "application/json",
        Authorization = Sys.getenv("redlist_api")
      ) %>%
      httr2::req_perform(error_call = NULL)
  }else{
    rp <- base_url %>%
      httr2::request() %>%
      httr2::req_url_query(!!!params) %>%
      httr2::req_headers(
        accept = "application/json",
        Authorization = Sys.getenv("redlist_api")
      ) %>%
      httr2::req_perform(error_call = NULL)
  }

  return(rp)
}

#' JSON to data frame
#'
#' Coerce JSON arrays containing only records (JSON objects) into a data frame.
#' Extracts and cleans text content using HTML parsing. When elements of the JSON
#' are of unequal lengths, columns can optionally be padded with NA to ensure the
#' resulting data frame has uniform row lengths.
#'
#' @param json_resp A nested list or parsed JSON structure (e.g., from `jsonlite::fromJSON`)
#'        that represents an array of JSON objects.
#' @param pad_with_na Logical; if `TRUE`, columns with unequal lengths will be padded with `NA`
#'        so that all columns have the same number of rows. If `FALSE`, each column will retain
#'        its raw structure, and content will be collapsed only when necessary.
#'
#' @return A tibble where each column represents a field extracted from the JSON objects.
#' @noRd
json_to_df <- function(json_resp, pad_with_na = FALSE) {
  unlisted <- unlist(json_resp)
  unlisted_names <- names(unlisted)

  if (pad_with_na) {
    parsed <- lapply(unique(unlisted_names), function(u_name){

      value <- unlisted[which(unlisted_names == u_name)]
      value <- paste0(value, collapse = "; ")
      value <- rvest::read_html(paste0("<html><body>", value, "</body></html>")) %>%
          rvest::html_text(trim = TRUE)
      index_df <- data.frame(i = value)
      colnames(index_df) <- gsub("\\.", "_", u_name)
      index_df
    }) %>% dplyr::bind_cols() %>% dplyr::as_tibble()
  }
  else{
    out_data <- lapply(unique(unlisted_names), function(u_name){

      value <- unlisted[which(unlisted_names == u_name)]
      value <- lapply(value, function(v){
        rvest::read_html(paste0("<html><body>", v, "</body></html>")) %>%
          rvest::html_text(trim = TRUE)
      }) %>% unlist()

      index_df <- data.frame(i = value)
      colnames(index_df) <- gsub("\\.", "_", u_name)
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
    }) %>% dplyr::bind_cols() %>% dplyr::as_tibble()

  }

  return(parsed)
}


#' Get total number of species assessed by IUCN
#'
#' This function retrieves the total number of species assessed by the IUCN Red
#' List
#'
#' @param url A character string specifying the query url
#'
#' @return A numeric value representing the total number of species assessed.
#'
#' @export
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
#' @param pad_with_na Logical. Whether to pad inconsistent JSON structures with NA during binding.
#'
#' @return A tibble with the combined results of all parameterized API queries.
#' @noRd
rl_paginated_query <- function(param_list,
                               endpoint_name,
                               base_url,
                               pad_with_na = FALSE) {
  suppressMessages(rl_check_api())

  # Build param list for expand.grid
  # param_list <- list(
  #   code = code,
  #   year_published = year_published %||% NA,
  #   latest = latest %||% NA,
  #   possibly_extinct = possibly_extinct %||% NA,
  #   possibly_extinct_in_the_wild = possibly_extinct_in_the_wild %||% NA,
  #   scope_code = scope_code %||% NA,
  #   page = page %||% NA
  # )

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
      json_to_df(pad_with_na = pad_with_na)

    multiple_out_df <- bind_rows(multiple_out_df, out)

    cli::cli_status_update(id = sb,
                           "{cli::symbol$arrow_right} Got {r} request{?s}, retrieving {paste0(round(r*100/nrow(param_grid), 1), '%')}")

  }
  cli::cli_status_clear(id = sb)
  cli::cli_alert_success("Downloads done.")
  # End of request

  return(multiple_out_df %>% dplyr::as_tibble())

}


#' Set download output file
#' @keywords internal
#' @noRd
out_file <- function(path, filename = "") {

  if (fs::is_dir(path)) {
    filename <- ifelse(nchar(filename), filename,
                       paste0("redlist_", Sys.Date()))
    of <- fs::path(path, fs::path_ext_remove(filename), ext = "csv")
  } else if (fs::is_file(path)) {
    of <- fs::path(fs::path_ext_remove(path),  ext = "csv")
  }else{
    of <- fs::path(getwd(), path,  ext = "csv")
  }

  return(of)
}


