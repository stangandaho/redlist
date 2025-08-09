# nocov start
#' Set the IUCN Red List API key
#'
#' The function provide steps to set the IUCN Red List API key.
#'
#' @param api_key Character. The API key provided by the IUCN Red List to
#' authenticate requests, obtainable at \href{https://api.iucnredlist.org/users/sign_in}{IUCN Red List API website}.
#'
#' @return Invisibly returns `NULL` after setting the API key.
#' @examples
#' \dontrun{
#' # Set the API key for the IUCN Red List
#' rl_set_api("your_api_key")
#' }
#'
#' @export
rl_set_api <- function(api_key) {
  bullet <- cli::col_red(cli::symbol$bullet)

  if (!methods::hasArg(api_key)) {
    cli::cli_div(theme = list(span.href = list(color = "#0068e3")))
    cli::cli_inform("Missing API key! {.strong {.emph {.href [Login or Sign](https://api.iucnredlist.org/)}}} to get one.")
    return(invisible(NULL))
  }

  apikey <- paste0("REDLIST_API=", api_key)

  cli::cli_inform("{.strong {cli::symbol$arrow_down} Steps to set IUCN Red list API key:}")
  cli::cli_inform("{bullet} Run {.run redlist::rl_open_file()}")
  cli::cli_inform("{bullet} Add {apikey} to .Renviron file")
  cli::cli_inform("{bullet} Restart R for changes to take effect")
  cli::cli_end()

  return(invisible(NULL))
}

#' Check IUCN Red List API Status
#'
#' Verifies whether the IUCN Red List API is accessible and the provided API key is valid.
#'
#' @return Invisibly returns `TRUE` if the API is working properly. If not, the function will abort with an appropriate error message.
#'
#' @examples
#' \dontrun{
#' # Check if API is properly set up
#' rl_check_api()
#' }
#'
#' @seealso [rl_set_api()]
#'
#' @export
rl_check_api <- function(){
  redlist_api <- Sys.getenv("REDLIST_API")

  if (redlist_api == "") {
    cli::cli_abort("No Redlist API key found. Go to {.url https://api.iucnredlist.org/users/edit} to get one, and then use `rl_set_api()` to set.", call = NULL)
  }else{
    resp <- tryCatch({
      paste0("https://api.iucnredlist.org/api/v4/assessment/17946182") %>%
        httr2::request() %>%
        httr2::req_headers(
          accept = "application/json",
          Authorization = redlist_api
        ) %>%
        httr2::req_perform()},
      httr2_http_401 = function(e){cli::cli_abort("Your API is not working. Ckeck it! Or go to {.url https://api.iucnredlist.org/users/edit} and renew it.",
                                                  call = NULL)},
      httr2_http_error = function(e) {
        cli::cli_abort(e$message, call = NULL)
      },
      error = function(e) {
        cli::cli_abort(e$message, call = NULL)
      }
      )
  }

  cli::cli_alert_success(
    paste0("Your API is working ", sample(c("\U0001F44D", "\u2728", "\U0001F389", "\U0001F38A"), 1))
  )
  return(invisible(TRUE))

}

# nocov end
