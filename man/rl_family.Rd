% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rl_family.R
\name{rl_family}
\alias{rl_family}
\title{IUCN Red List taxa by family}
\usage{
rl_family(
  family_name = NULL,
  year_published = NULL,
  latest = NULL,
  scope_code = NULL,
  page = 1
)
}
\arguments{
\item{family_name}{Character. The family name (e.g., "Felidae").
Use \code{\link[=rl_family]{rl_family()}} to list available families.}

\item{year_published}{Optional. Single or numeric vector of years to filter assessments by publication year.}

\item{latest}{Optional. Logical. If \code{TRUE}, return only the latest assessment per species.}

\item{scope_code}{Optional. Character. One or more scope codes to filter assessments.}

\item{page}{Optional. Integer vector. Specify one or more page numbers to fetch.
If \code{NULL} or \code{NA}, all pages will be fetched automatically.}
}
\value{
A tibble containing families or species assessments.
}
\description{
Retrieve species assessments by taxonomic family.
If \code{family_name = NULL}, it returns a list of available families.
If \code{family_name} is provided, it retrieves assessments for species in the specified family.
}
\examples{
\dontrun{
# List all available families
rl_family()

# Get assessments for Felidae family
rl_family(family_name = "Felidae")

# Get latest Canidae assessments published from 2019 to 2022
rl_family(
  family_name = "Canidae",
  year_published = 2019:2022,
  latest = TRUE
)
}
}
