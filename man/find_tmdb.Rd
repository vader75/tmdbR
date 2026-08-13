\name{find_tmdb}
\alias{find_tmdb}
\title{Find Tmdb from TMDB}
\usage{
find_tmdb(
  api_key = NULL,
  id,
  external_source,
  language = NA
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{external_source}{External identifier source, such as imdb_id.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/find/\\{id\\}} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
# Live examples run only in an interactive session with a bearer token.
if (interactive() && nzchar(Sys.getenv("TMDB_BEARER_TOKEN"))) {
find_tmdb(
  id = "tt0137523",
  external_source = "imdb_id",
  language = "en-AU"
)
}
}

