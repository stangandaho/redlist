% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rl_set_api.R
\name{rl_set_api}
\alias{rl_set_api}
\title{Set the IUCN Red List API key}
\usage{
rl_set_api(api_key)
}
\arguments{
\item{api_key}{Character. The API key provided by the IUCN Red List to authenticate requests.
You can obtain an API key by registering on the IUCN Red List website https://api.iucnredlist.org/users/sign_in.}
}
\description{
This function sets the IUCN Red List API key as an environment variable, allowing other functions
in the package to authenticate requests to the IUCN Red List API.
}
\details{
The IUCN Red List API requires an API key to access data. This function sets the provided \code{api_key}
as an environment variable named \code{redlist_api}. This environment variable is accessed by other
functions in the package to perform authenticated API requests.
}
\examples{
\dontrun{
  # Set the API key for the IUCN Red List
  rl_set_api("your_api_key_here")
}

}
