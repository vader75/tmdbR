\name{tmdb_request_all}
\alias{tmdb_request_all}
\title{Automatically paginate a generic TMDB endpoint}
\usage{
tmdb_request_all(path, query = list(), api_key = NULL,
  bearer_token = NULL, version = 3L, config = NULL,
  start_page = 1L, max_pages = 5L, max_results = 100L,
  max_memory_mb = 100, simplify = TRUE, deduplicate_by = NULL,
  progress = interactive(), delay = 0.05)
}
\arguments{
  \item{path}{Paginated endpoint path, such as \code{discover/movie}.}
  \item{query}{Named query parameters excluding \code{page}.}
  \item{api_key}{Optional TMDB v3 API key.}
  \item{bearer_token}{Optional API Read Access Token.}
  \item{version}{TMDB API version.}
  \item{config}{Optional configuration from \code{tmdb_config()}.}
  \item{start_page}{First page to request.}
  \item{max_pages}{Maximum pages. Defaults to 5; use \code{Inf} explicitly for all pages.}
  \item{max_results}{Maximum combined results. Defaults to 100.}
  \item{max_memory_mb}{Approximate memory limit for collected page results. Defaults to 100 MB.}
  \item{simplify}{Combine compatible pages into a data frame.}
  \item{deduplicate_by}{Optional field such as \code{"id"} used to remove duplicates.}
  \item{progress}{Logical value or callback function receiving progress metadata.}
  \item{delay}{Non-negative pause in seconds between requests.}
}
\value{A \code{tmdb_paginated} list containing combined results and pagination metadata.}
\description{Fetch and combine pages from an arbitrary TMDB GET endpoint.}
\details{Use \code{start_page} instead of placing \code{page} in \code{query}. Requests are sequential and retain normal retry and error handling.}
\section{Important pagination note}{
\strong{Important:} TMDB controls page size and provides no documented
page-size parameter. Standard search, discover, and list endpoints currently
return up to 20 records per full page; global change feeds currently return up
to 100. Final pages can be shorter. This function counts actual results and
follows \code{total_pages} rather than assuming a fixed page size.
}
\seealso{\code{tmdb_paginate}, \code{tmdb_request}}
\examples{
args(tmdb_request_all)
\dontrun{
# Requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
tmdb_request_all("discover/movie",
  query = list(with_genres = 878, sort_by = "popularity.desc"),
  max_pages = 3, deduplicate_by = "id")
}
}
