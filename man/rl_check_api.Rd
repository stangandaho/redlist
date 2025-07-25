% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rl_set_api.R
\name{rl_check_api}
\alias{rl_check_api}
\title{Check IUCN Red List API Status}
\usage{
rl_check_api()
}
\value{
Invisibly returns \code{TRUE} if the API is working properly. If not,
the function will abort with an appropriate error message.
}
\description{
Verifies whether the IUCN Red List API is accessible and the provided API key is valid.
This function checks both the presence of an API key in the environment and its validity.
}
\examples{
\dontrun{
# Check if API is properly set up
rl_check_api()
}

}
\seealso{
\code{\link[=rl_set_api]{rl_set_api()}}
}
