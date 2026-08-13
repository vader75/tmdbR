\name{tv_episode_credits}
\alias{tv_episode_credits}
\title{Tv Episode Credits from TMDB}
\usage{
tv_episode_credits(
  api_key = NULL,
  id,
  season_number,
  episode_number
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{season_number}{Season number within the TV series.}
  \item{episode_number}{Episode number within the season.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/tv/\\{id\\}/season/\\{season_number\\}/episode/\\{episode_number\\}/credits} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
args(tv_episode_credits)
\dontrun{
# A live request requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
tv_episode_credits(
  id = 1399,
  season_number = 1,
  episode_number = 1
)
}
}

