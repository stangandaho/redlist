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
# nocov end
