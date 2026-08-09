\name{discover_tv}
\alias{discover_tv}
\title{Discover Tv from TMDB}
\usage{
discover_tv(api_key = NULL, page = 1, language = NA, sort_by = NA, 
    first_air_date_year = NA, vote_count.gte = NA, vote_average.gte = NA, 
    with_genres = NA, with_networks = NA, first_air_date.gte = NA, 
    first_air_date.lte = NA, watch_region = NA, with_watch_providers = NA, 
    with_watch_monetization_types = NA, ..., paginate = FALSE, 
    max_pages = 5L, max_results = 100L, max_memory_mb = 100, 
    simplify = TRUE, deduplicate_by = NULL, progress = interactive(), 
    delay = 0.05) 
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{page}{Result page, starting at 1. Use tmdb_paginate() to collect multiple pages.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
  \item{sort_by}{TMDB sort expression, such as popularity.desc.}
  \item{first_air_date_year}{Four-digit first-air year.}
  \item{vote_count.gte}{Minimum vote count.}
  \item{vote_average.gte}{Minimum average vote.}
  \item{with_genres}{Genre IDs used to filter results.}
  \item{with_networks}{Network IDs used to filter results.}
  \item{first_air_date.gte}{Earliest first-air date in YYYY-MM-DD format.}
  \item{first_air_date.lte}{Latest first-air date in YYYY-MM-DD format.}
  \item{watch_region}{ISO 3166-1 region used for watch-provider availability.}
  \item{with_watch_providers}{Watch-provider IDs, supplied as a vector or TMDB filter expression.}
  \item{with_watch_monetization_types}{Monetisation filters such as flatrate, free, ads, rent, or buy.}
  \item{...}{Additional current TMDB query parameters supported by this endpoint.}
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
\description{Discover TMDB records using the \code{/discover/tv} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\section{Important pagination note}{
\strong{Important:} TMDB controls page size and does not document a supported page-size parameter. Standard search, discover, and list endpoints currently return up to 20 records per full page; global movie, TV, and person change feeds currently return up to 100. A final page can contain fewer records. These values are observed behavior, not a contractual guarantee. This function counts the actual results in each response and uses TMDB's total_pages metadata rather than assuming a fixed page size.
}
\seealso{\code{tmdb_paginate}, \code{tmdb_request}}
\examples{
\dontrun{
# Requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
discover_tv(language = "en-AU", watch_region = "AU", with_watch_providers = c(8, 9), with_watch_monetization_types = "flatrate", paginate = TRUE, max_pages = 2, max_results = 40, progress = TRUE)
}
}

