\name{tv_episode_external_ids}
\alias{tv_episode_external_ids}
\title{Tv Episode External Ids from TMDB}
\usage{
tv_episode_external_ids(
  api_key = NULL,
  id,
  season_number,
  episode_number,
  language = NA
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{season_number}{Season number within the TV series.}
  \item{episode_number}{Episode number within the season.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/tv/\\{id\\}/season/\\{season_number\\}/episode/\\{episode_number\\}/external_ids} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
# Live examples run only in an interactive session with a bearer token.
if (interactive() && nzchar(Sys.getenv("TMDB_BEARER_TOKEN"))) {
tv_episode_external_ids(
  id = 1399,
  season_number = 1,
  episode_number = 1,
  language = "en-AU"
)
}
}

