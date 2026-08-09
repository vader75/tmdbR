\name{tmdb_request}
\alias{tmdb_request}
\title{Send a TMDB API request}
\usage{
tmdb_request(path, query = list(), api_key = NULL,
  bearer_token = NULL, version = 3L, config = NULL)
}
\arguments{
  \item{path}{Endpoint path with or without the API version prefix, such as \code{movie/550}.}
  \item{query}{Named list of query parameters. Vectors are encoded as comma-separated values.}
  \item{api_key}{Optional TMDB v3 API key.}
  \item{bearer_token}{Optional API Read Access Token. Preferred over an API key.}
  \item{version}{TMDB API version prepended to \code{path}; defaults to 3.}
  \item{config}{Optional configuration returned by \code{tmdb_config()}.}
}
\value{Parsed JSON represented by R lists, data frames, and vectors.}
\description{Send an authenticated HTTPS GET request to a TMDB v3 or v4 endpoint.}
\details{
Credential precedence is explicit bearer token, explicit API key,
\code{TMDB_BEARER_TOKEN}, then \code{TMDB_API_KEY}. Requests use configured
timeouts and retry HTTP 429 and transient server failures. Error messages
include TMDB status information but exclude credentials.
}
\seealso{\code{tmdb_config}, \code{tmdb_request_all}}
\examples{
\dontrun{
# Requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
tmdb_request("movie/550", query = list(language = "en-AU"))
tmdb_request("trending/movie/week")
}
}

