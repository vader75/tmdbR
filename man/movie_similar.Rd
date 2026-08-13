\name{movie_similar}
\alias{movie_similar}
\title{Movie Similar from TMDB}
\usage{
movie_similar(
  api_key = NULL,
  id,
  page = 1,
  language = NA,
  append_to_response = NA,
  paginate = FALSE,
  max_pages = 5L,
  max_results = 100L,
  max_memory_mb = 100,
  simplify = TRUE,
  deduplicate_by = NULL,
  progress = interactive(),
  delay = 0.05
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{page}{Result page, starting at 1. Use tmdb_paginate() to collect multiple pages.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
  \item{append_to_response}{Comma-separated related endpoints to include in the same response, with a maximum of 20.}
  \item{paginate}{Whether to retrieve and combine sequential result pages. Defaults to FALSE for backward compatibility.}
  \item{max_pages}{Maximum pages when paginate is TRUE. Defaults to 5; use Inf explicitly to remove this limit.}
  \item{max_results}{Maximum combined results when paginate is TRUE. Defaults to 100.}
  \item{max_memory_mb}{Approximate memory limit in megabytes for collected page results. Defaults to 100.}
  \item{simplify}{Whether compatible result pages should be combined into a data frame.}
  \item{deduplicate_by}{Optional field, normally id, used to remove duplicate records across pages.}
  \item{progress}{TRUE for progress messages, FALSE for silence, or a callback function receiving progress events.}
  \item{delay}{Non-negative delay in seconds between successful page requests.}
}
\value{A parsed response containing page metadata and a results data frame or list.}
\description{Request the \code{/movie/\\{id\\}/similar} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\section{Important pagination note}{
\strong{Important:} TMDB controls page size and does not document a supported page-size parameter. Standard search, discover, and list endpoints currently return up to 20 records per full page; global movie, TV, and person change feeds currently return up to 100. A final page can contain fewer records. These values are observed behavior, not a contractual guarantee. This function counts the actual results in each response and uses TMDB's total_pages metadata rather than assuming a fixed page size.
}
\seealso{\code{tmdb_paginate}, \code{tmdb_request}}
\examples{
# Live examples run only in an interactive session with a bearer token.
if (interactive() && nzchar(Sys.getenv("TMDB_BEARER_TOKEN"))) {
movie_similar(
  id = 550,
  language = "en-AU",
  paginate = TRUE,
  max_pages = 2,
  max_results = 40,
  progress = TRUE
)
}
}

