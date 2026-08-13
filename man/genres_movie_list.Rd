\name{genres_movie_list}
\alias{genres_movie_list}
\title{Genres Movie List from TMDB}
\usage{
genres_movie_list(
  api_key = NULL,
  language = NA
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/genre/movie/list} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
args(genres_movie_list)
\dontrun{
# A live request requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
genres_movie_list(
  language = "en-AU"
)
}
}

