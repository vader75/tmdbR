\name{person_tv_credits}
\alias{person_tv_credits}
\title{Person Tv Credits from TMDB}
\usage{
person_tv_credits(
  api_key = NULL,
  id,
  language = NA,
  append_to_response = NA
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
  \item{append_to_response}{Comma-separated related endpoints to include in the same response, with a maximum of 20.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/person/\\{id\\}/tv_credits} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
args(person_tv_credits)
\dontrun{
# A live request requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
person_tv_credits(
  id = 287,
  language = "en-AU"
)
}
}

