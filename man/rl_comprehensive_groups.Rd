% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rl_comprehensive_groups.R
\name{rl_comprehensive_groups}
\alias{rl_comprehensive_groups}
\title{IUCN Red List Comprehensive groups}
\usage{
rl_comprehensive_groups(
  name = NULL,
  year_published = NULL,
  latest = NULL,
  possibly_extinct = NULL,
  possibly_extinct_in_the_wild = NULL,
  scope_code = NULL,
  page = 1
)
}
\arguments{
\item{name}{Character. One or more group names.
Use \code{\link[=rl_comprehensive_groups]{rl_comprehensive_groups()}} to list available group names.}

\item{year_published}{Optional. Single or numeric vector of years to filter assessments by publication year.}

\item{latest}{Optional. Logical. If \code{TRUE}, return only the latest assessment per species.}

\item{possibly_extinct}{Optional. Logical. Filter for species flagged as possibly extinct.}

\item{possibly_extinct_in_the_wild}{Optional. Logical. Filter for species possibly extinct in the wild.}

\item{scope_code}{Optional. Character. One or more scope codes to filter assessments.}

\item{page}{Optional. Integer vector. Specify one or more page numbers to fetch.
If \code{NULL} or \code{NA}, all pages will be fetched automatically.}
}
\value{
Tibble of assessments for a comprehensive group name
}
\description{
Get assessment data by comprehensive group name (e.g \code{amphibians},
\code{mammals}, \code{birds}, \code{blennies}, \code{mangrove_plants}, \code{reptiles},
\code{insects}, \code{fishes}, etc).
See \code{name} argument for available group names.
}
\examples{
\dontrun{
rl_comprehensive_groups(name = "amphibians",
                        year_published = 2024:2025,
                        page = 1:3)
}
}
