% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rl_habitats.R
\name{rl_habitats}
\alias{rl_habitats}
\title{Habitats}
\usage{
rl_habitats(
  code = NULL,
  year_published = NULL,
  latest = NULL,
  possibly_extinct = NULL,
  possibly_extinct_in_the_wild = NULL,
  scope_code = NULL,
  page = 1
)
}
\arguments{
\item{code}{Character. One or more habitat classification codes.
Use \code{\link[=rl_habitats]{rl_habitats()}} with no arguments to list available habitat codes.}

\item{year_published}{Optional. Single or numeric vector of years to filter assessments by publication year.}

\item{latest}{Optional. Logical. If \code{TRUE}, return only the latest assessment per species.}

\item{possibly_extinct}{Optional. Logical. Filter for species flagged as possibly extinct.}

\item{possibly_extinct_in_the_wild}{Optional. Logical. Filter for species possibly extinct in the wild.}

\item{scope_code}{Optional. Character. One or more scope codes to filter assessments.}

\item{page}{Optional. Integer vector. Specify one or more page numbers to fetch.
If \code{NULL} or \code{NA}, all pages will be fetched automatically.}
}
\value{
A tibble of assessments for a given IUCN habitat classification code.
}
\description{
Retrieve IUCN Red List assessments by habitat classification.
}
\examples{
\dontrun{
# Retrieve available habitat codes
rl_habitats()

# Retrieve assessments for the Desert
rl_habitats(code = 8)
}
}
