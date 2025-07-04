% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/openapi.R
\name{rl_green_status}
\alias{rl_green_status}
\title{Green status}
\usage{
rl_green_status(pad_with_na = FALSE)
}
\arguments{
\item{pad_with_na}{Logical. If \code{TRUE}, pad shorter columns with \code{NA} for consistent binding.}
}
\value{
A tibble of Green Status assessments.
}
\description{
Retrieve all IUCN Green Status assessments.
}
\examples{
rl_green_status()

}
