\name{tmdbR-package}
\alias{tmdbR-package}
\alias{tmdbR}
\title{tmdbR: Modern TMDB API Client for R}
\description{
A modern HTTPS client for The Movie Database (TMDB) API. It provides
read-only v3 convenience functions compatible with the legacy TMDb package,
generic v3 and v4 GET requests, bearer-token authentication, automatic
pagination, retries, and structured errors.
}
\section{Package provenance}{
\strong{Important:} tmdbR was developed from the compatibility interface of
Andrea Capozio's \code{TMDb} version 1.1 package, published on CRAN on 16 March
2020 under the Artistic License 2.0. tmdbR is a separately named, substantially
modified package and is not an official update by the original author. See
\url{https://CRAN.R-project.org/package=TMDb}.
}
\section{Quick start}{
Configure a bearer token once with \code{tmdb_auth()}, then search for a title
and request its details:
\preformatted{
tmdb_auth()
hits <- search_movie(query = "Spirited Away", language = "en-AU")
film <- movie(id = hits$results$id[[1]],
              append_to_response = "credits,videos")
}
}
\section{Authentication}{
Bearer authentication is recommended. Use interactive \code{tmdb_auth()} to
store an encrypted cached token, or set \code{TMDB_BEARER_TOKEN} for the current
process. The legacy \code{TMDB_API_KEY} mechanism remains available for
compatibility. Explicit credentials take precedence over environment and cached
credentials. See \code{\link{tmdb_auth}} and \code{\link{tmdb_credentials}}.
}
\section{Find functions by task}{
\itemize{
  \item Movies: \code{\link{tmdb_movies}}
  \item TV series, seasons, and episodes: \code{\link{tmdb_tv}}
  \item People and credits: \code{\link{tmdb_people}}
  \item Search and discover: \code{\link{tmdb_search}}
  \item Configuration and general catalogue data: \code{\link{tmdb_catalogue}}
  \item Lists: \code{\link{tmdb_lists}}
  \item Pagination: \code{\link{tmdb_pagination}}
  \item Authentication and low-level requests: \code{\link{tmdb_client}}
}
}
\section{Important pagination note}{
\strong{Important:} TMDB controls page size. It does not document a supported
\code{page_size}, \code{limit}, or \code{per_page} parameter. Standard search,
discover, and list endpoints currently return up to 20 records per full page;
global movie, TV, and person change feeds currently return up to 100. Final
pages can be shorter, and TMDB may change these values. The package counts each
response and follows \code{total_pages}; it never assumes a fixed page size.

Pagination is opt-in and defaults to five pages, 100 results, and approximately
100 MB. Interactive retrieval reports its plan, each completed page, and whether
the result is complete or truncated. See \code{\link{tmdb_paginate}}.
}
\section{Return values and errors}{
JSON responses are converted into ordinary R lists, data frames, and vectors.
Paginated calls return a \code{tmdb_paginated} list containing combined results,
counts, limits, memory use, and a \code{truncated} flag. HTTP failures report
TMDB's status code and message without including credentials. HTTP 429 and
transient server failures are retried.
}
\section{Package options and environment variables}{
\itemize{
  \item \code{options(tmdbR.token_path = ...)} overrides the cached-token path.
  \item \code{TMDB_TOKEN_FILE} changes the cached-token filename.
  \item \code{TMDB_BEARER_TOKEN} supplies the preferred bearer token.
  \item \code{TMDB_API_KEY} supplies a legacy v3 API key.
}
}
\section{Attribution}{
This product uses the TMDB API but is not endorsed or certified by TMDB.
Downstream applications must comply with TMDB's current terms and attribution
requirements.
}
\seealso{
\code{\link{tmdb_auth}}, \code{\link{tmdb_request}},
\code{\link{tmdb_paginate}},
\url{https://CRAN.R-project.org/package=TMDb},
\url{https://developer.themoviedb.org/docs/getting-started}, and
\url{https://developer.themoviedb.org/docs/rate-limiting}.
}
\docType{package}
\author{
Gordon Kuzet \email{30060726@westernsydney.edu.au}.

The compatibility interface is based on TMDb 1.1 by Andrea Capozio.
}
\examples{
tmdb_config(timeout = 20, max_tries = 3)
\dontrun{
# Interactive bearer-token setup:
tmdb_auth()

hits <- search_movie(query = "Spirited Away", language = "en-AU")
movie(id = hits$results$id[[1]], append_to_response = "credits,videos")

popular <- movie_popular(
  region = "AU", paginate = TRUE,
  max_pages = 3, max_results = 50,
  progress = TRUE
)
}
}
