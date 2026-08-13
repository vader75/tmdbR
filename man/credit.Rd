\name{credit}
\alias{credit}
\title{Credit from TMDB}
\usage{
credit(
  api_key = NULL,
  credit_id,
  language = NA
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{credit_id}{TMDB credit identifier.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/credit/\\{credit_id\\}} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
args(credit)
\dontrun{
# A live request requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
credit(
  credit_id = "replace-with-credit-id",
  language = "en-AU"
)
}
}

