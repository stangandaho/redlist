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
