\name{tv_season}
\alias{tv_season}
\title{Tv Season from TMDB}
\usage{
tv_season(
  api_key = NULL,
  id,
  season_number,
  language = NA,
  append_to_response = NA
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{season_number}{Season number within the TV series.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
  \item{append_to_response}{Comma-separated related endpoints to include in the same response, with a maximum of 20.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/tv/\\{id\\}/season/\\{season_number\\}} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
args(tv_season)
\dontrun{
# A live request requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
tv_season(
  id = 1399,
  season_number = 1,
  language = "en-AU"
)
}
}

