\name{movie_releases}
\alias{movie_releases}
\title{Movie Releases from TMDB}
\usage{
movie_releases(
  api_key = NULL,
  id,
  append_to_response = NA
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{append_to_response}{Comma-separated related endpoints to include in the same response, with a maximum of 20.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/movie/\\{id\\}/release_dates} endpoint.}
\details{This compatibility function uses the current /release_dates endpoint. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
args(movie_releases)
\dontrun{
# A live request requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
movie_releases(
  id = 550
)
}
}

