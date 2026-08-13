\name{network}
\alias{network}
\title{Network from TMDB}
\usage{
network(
  api_key = NULL,
  id
)
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/network/\\{id\\}} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
args(network)
\dontrun{
# A live request requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
network(
  id = 213
)
}
}

