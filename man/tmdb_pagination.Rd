\name{tmdb_pagination}
\alias{tmdb_pagination}
\title{Pagination Functions Index}
\description{Functions for collecting and combining sequential TMDB result pages.}
\section{Functions}{
\code{\link{tmdb_paginate}} paginates an existing wrapper.
\code{\link{tmdb_request_all}} paginates a generic endpoint.
}
\section{Important pagination note}{
\strong{Important:} TMDB controls page size. Most standard result endpoints
currently return up to 20 records per full page, while global change feeds
return up to 100. Final pages may be shorter, and no supported page-size query
parameter is documented. Pagination therefore uses actual response counts and
TMDB's \code{total_pages} metadata.
}
\seealso{\code{\link{tmdb_client}}}
