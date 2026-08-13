\name{person_latest}
\alias{person_latest}
\title{Person Latest from TMDB}
\usage{
person_latest(
  api_key = NULL,
  page = 1
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{page}{Result page, starting at 1. Use tmdb_paginate() to collect multiple pages.}
}
\value{A parsed response containing page metadata and a results data frame or list.}
\description{Request the \code{/person/latest} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_paginate}, \code{tmdb_request}}
\examples{
args(person_latest)
\dontrun{
# A live request requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
person_latest(
  page = 1
)
}
}

