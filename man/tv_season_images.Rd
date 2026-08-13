\name{tv_season_images}
\alias{tv_season_images}
\title{Tv Season Images from TMDB}
\usage{
tv_season_images(
  api_key = NULL,
  id,
  season_number,
  language = NA,
  include_image_language = NA
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{season_number}{Season number within the TV series.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
  \item{include_image_language}{Image languages to include, for example c("en", "null").}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/tv/\\{id\\}/season/\\{season_number\\}/images} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
# Live examples run only in an interactive session with a bearer token.
if (interactive() && nzchar(Sys.getenv("TMDB_BEARER_TOKEN"))) {
tv_season_images(
  id = 1399,
  season_number = 1,
  language = "en-AU",
  include_image_language = c("en", "null")
)
}
}

