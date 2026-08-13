\name{movie_images}
\alias{movie_images}
\title{Movie Images from TMDB}
\usage{
movie_images(
  api_key = NULL,
  id,
  language = NA,
  append_to_response = NA,
  include_image_language = NA
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
  \item{append_to_response}{Comma-separated related endpoints to include in the same response, with a maximum of 20.}
  \item{include_image_language}{Image languages to include, for example c("en", "null").}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/movie/\\{id\\}/images} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
args(movie_images)
\dontrun{
# A live request requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
movie_images(
  id = 550,
  language = "en-AU",
  include_image_language = c("en", "null")
)
}
}

