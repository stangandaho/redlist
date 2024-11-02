# Laod package
library(httr2)
library(dplyr)


#' @noRd
rl_get_count <- function(country_code = "BJ"){

  suppressMessages(rl_check_api())
  query_url <- paste0("https://api.iucnredlist.org/api/v4/countries/", country) %>%
    httr2::request() %>%
    httr2::req_headers(
      accept = "application/json",
      Authorization = Sys.getenv("redlist_api")
    ) %>%
    httr2::req_perform()

  total_count <- as.numeric(query_url$headers$`Total-Count`)
  return(total_count)
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
  redlist_api <- Sys.getenv("redlist_api")

  if (redlist_api == "") {
    stop("Any redlist API available. Use rl_set_api function to set an API")
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

    if (any(grepl("forbidden", api_response))) {
      stop("Your API is not working. Ckeck out or go to
           https://api.iucnredlist.org/users/edit and recycle", call. = F)
    }

    message(
      paste0("Your API is working ", sample(c("👍", "✨", "🎉" ,"🎊"), 1) )
    )
  }

}
