\name{discover_movie}
\alias{discover_movie}
\title{Discover Movie from TMDB}
\usage{
discover_movie(api_key = NULL, certification_country = NA, certification = NA, 
    certification.lte = NA, include_adult = FALSE, include_video = TRUE, 
    language = NA, page = 1, primary_release_year = NA, primary_release_date.gte = NA, 
    primary_release_date.lte = NA, release_date.gte = NA, release_date.lte = NA, 
    sort_by = NA, vote_count.gte = NA, vote_count.lte = NA, vote_average.gte = NA, 
    vote_average.lte = NA, with_cast = NA, with_crew = NA, with_companies = NA, 
    with_genres = NA, with_keywords = NA, with_people = NA, year = NA, 
    region = NA, watch_region = NA, with_watch_providers = NA, 
    with_watch_monetization_types = NA, ..., paginate = FALSE, 
    max_pages = 5L, max_results = 100L, max_memory_mb = 100, 
    simplify = TRUE, deduplicate_by = NULL, progress = interactive(), 
    delay = 0.05) 
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{certification_country}{Country whose certification system should be used.}
  \item{certification}{Exact certification filter.}
  \item{certification.lte}{Maximum certification filter.}
  \item{include_adult}{Whether adult content may be included.}
  \item{include_video}{Whether video records may be included.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
  \item{page}{Result page, starting at 1. Use tmdb_paginate() to collect multiple pages.}
  \item{primary_release_year}{Four-digit primary release year.}
  \item{primary_release_date.gte}{Earliest primary release date in YYYY-MM-DD format.}
  \item{primary_release_date.lte}{Latest primary release date in YYYY-MM-DD format.}
  \item{release_date.gte}{Earliest release date in YYYY-MM-DD format.}
  \item{release_date.lte}{Latest release date in YYYY-MM-DD format.}
  \item{sort_by}{TMDB sort expression, such as popularity.desc.}
  \item{vote_count.gte}{Minimum vote count.}
  \item{vote_count.lte}{Maximum vote count.}
  \item{vote_average.gte}{Minimum average vote.}
  \item{vote_average.lte}{Maximum average vote.}
  \item{with_cast}{Cast IDs used to filter results.}
  \item{with_crew}{Crew IDs used to filter results.}
  \item{with_companies}{Company IDs used to filter results.}
  \item{with_genres}{Genre IDs used to filter results.}
  \item{with_keywords}{Keyword IDs used to filter results.}
  \item{with_people}{Person IDs used to filter results.}
  \item{year}{Four-digit release year.}
  \item{region}{ISO 3166-1 region code, such as AU.}
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
\description{Discover TMDB records using the \code{/discover/movie} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\section{Important pagination note}{
\strong{Important:} TMDB controls page size and does not document a supported page-size parameter. Standard search, discover, and list endpoints currently return up to 20 records per full page; global movie, TV, and person change feeds currently return up to 100. A final page can contain fewer records. These values are observed behavior, not a contractual guarantee. This function counts the actual results in each response and uses TMDB's total_pages metadata rather than assuming a fixed page size.
}
\seealso{\code{tmdb_paginate}, \code{tmdb_request}}
\examples{
\dontrun{
# Requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
discover_movie(language = "en-AU", region = "AU", watch_region = "AU", with_watch_providers = c(8, 9), with_watch_monetization_types = "flatrate", paginate = TRUE, max_pages = 2, max_results = 40, progress = TRUE)
}
}

