% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rl_faos.R
\name{rl_faos}
\alias{rl_faos}
\title{FAO marine fishing areas}
\usage{
rl_faos(
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
\item{code}{Character. One or more FAO region codes (e.g. "21", "27").
Use \code{rl_faos()} with no arguments to list available FAO region codes.}

\item{year_published}{Optional. Single or numeric vector of years to filter assessments by publication year.}

\item{latest}{Optional. Logical. If \code{TRUE}, return only the latest assessment per species.}

\item{possibly_extinct}{Optional. Logical. Filter for species flagged as possibly extinct.}

\item{possibly_extinct_in_the_wild}{Optional. Logical. Filter for species possibly extinct in the wild.}

\item{scope_code}{Optional. Character. One or more scope codes to filter assessments.}

\item{page}{Optional. Integer vector. Specify one or more page numbers to fetch.
If \code{NULL} or \code{NA}, all pages will be fetched automatically.}
}
\value{
A tibble of assessments for the specified FAO region(s), or a tibble of available FAO codes and descriptions.
}
\description{
List or retrieve IUCN Red List assessments for FAO Marine Fishing Areas.
}
\details{
If \code{code} is \code{NULL}, this returns the available FAO region codes and their descriptions.
If a \code{code} (or multiple codes) is provided, retrieves the IUCN assessments for those regions.
}
\examples{
\dontrun{
# List available FAO regions
rl_faos()

# Get assessments for FAO region 27
rl_faos(code = "27")

# Get assessments for regions 21 and 27 on page 1
rl_faos(code = c("21", "27"), page = 1)
}
}
