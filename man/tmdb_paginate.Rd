\name{tmdb_paginate}
\alias{tmdb_paginate}
\title{Automatically paginate a TMDB wrapper}
\usage{
tmdb_paginate(.f, ..., start_page = 1L, max_pages = 5L,
  max_results = 100L, max_memory_mb = 100, simplify = TRUE, deduplicate_by = NULL,
  progress = interactive(), delay = 0.05)
}
\arguments{
  \item{.f}{Paginated wrapper function, or its exported name as a string.}
  \item{...}{Arguments passed to \code{.f}. Use \code{start_page}, not \code{page}.}
  \item{start_page}{First page to request.}
  \item{max_pages}{Maximum pages. Defaults to 5; use \code{Inf} explicitly for all reported pages.}
  \item{max_results}{Maximum combined results. Defaults to 100.}
  \item{max_memory_mb}{Approximate memory limit for collected page results. Defaults to 100 MB.}
  \item{simplify}{Combine compatible pages into a data frame; otherwise return record lists.}
  \item{deduplicate_by}{Optional field such as \code{"id"} used to remove duplicates.}
  \item{progress}{Logical value or callback function receiving progress metadata.}
  \item{delay}{Non-negative pause in seconds between successful requests.}
}
\value{A \code{tmdb_paginated} list containing results, page and result counts, and a \code{truncated} flag.}
\description{Fetch sequential pages from an existing TMDB wrapper and combine their results.}
\details{Safe defaults are five pages, 100 results, and 100 MB. Pagination reuses authentication, timeouts, retries, and HTTP 429 handling. Interactive calls report their plan, each page, and completion status. Existing single-page wrappers remain unchanged.}
\section{Important pagination note}{
\strong{Important:} TMDB controls page size and provides no documented
page-size parameter. Standard search, discover, and list endpoints currently
return up to 20 records per full page; global change feeds currently return up
to 100. Final pages can be shorter. The implementation counts actual results
and follows \code{total_pages}; it does not assume either value is fixed.
}
\seealso{\code{tmdb_request_all}}
\examples{
fake_page <- function(page = 1) list(
  page = page,
  results = data.frame(id = page, title = paste("Title", page)),
  total_pages = 3,
  total_results = 3
)
tmdb_paginate(fake_page, max_pages = Inf, delay = 0, progress = FALSE)

\dontrun{
# Requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
tmdb_paginate(search_movie, query = "Star Wars", max_pages = 5,
  max_results = 75, deduplicate_by = "id")
}
}
