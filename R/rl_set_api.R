# nocov start

#' Set the IUCN Red List API key
#'
#' This function sets the IUCN Red List API key as an environment variable, allowing other functions
#' in the package to authenticate requests to the IUCN Red List API.
#'
#' @param api_key Character. The API key provided by the IUCN Red List to authenticate requests.
#' You can obtain an API key by registering on the IUCN Red List website https://api.iucnredlist.org/users/sign_in.
#'
#' @details
#' The IUCN Red List API requires an API key to access data. This function sets the provided `api_key`
#' as an environment variable named `redlist_api`. This environment variable is accessed by other
#' functions in the package to perform authenticated API requests.
#'
#' @examples
#' \dontrun{
#'   # Set the API key for the IUCN Red List
#'   rl_set_api("your_api_key_here")
#' }
#'
#' @export
rl_set_api <- function(api_key){
  renv <- base::readLines("~/.Renviron")
  duplicated <- renv[renv == paste0("REDLIST_API=", api_key)]

  if (length(duplicated) > 0) {
    renv <- renv[renv != paste0("REDLIST_API=", api_key)]
  }
  renv[[length(renv) + 1]] <- paste0("REDLIST_API=", api_key)
  base::cat(renv, file = "~/.Renviron", sep = "\n")
  cli::cli_alert_success("API added successfully!")
}

#' Check IUCN Red List API Status
#'
#' Verifies whether the IUCN Red List API is accessible and the provided API key is valid.
#' This function checks both the presence of an API key in the environment and its validity.
#'
#' @return Invisibly returns `TRUE` if the API is working properly. If not,
#'   the function will abort with an appropriate error message.
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

  return(invisible(TRUE))

}

# nocov end
