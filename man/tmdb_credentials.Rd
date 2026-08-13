\name{tmdb_credentials}
\alias{tmdb_credentials}
\title{Resolve TMDB credentials}
\usage{
tmdb_credentials(bearer_token = Sys.getenv("TMDB_BEARER_TOKEN"),
  api_key = Sys.getenv("TMDB_API_KEY"))
}
\arguments{
  \item{bearer_token}{Bearer token, defaulting to \code{TMDB_BEARER_TOKEN}.}
  \item{api_key}{API key, defaulting to \code{TMDB_API_KEY}.}
}
\value{A list containing the available bearer token and API key.}
\description{Resolve and validate credentials without making a request.}
\details{When neither argument nor environment variable provides a credential,
the encrypted token cache created by \code{tmdb_auth()} is checked. An error is
raised when no credential is available. Do not print, log, or commit the
returned values.}
\seealso{\code{tmdb_auth}, \code{tmdb_config}, \code{tmdb_request}}
\examples{
credentials <- tmdb_credentials(bearer_token = "example-token")
names(credentials)
\dontrun{
# Requires an environment credential or a cached token.
credentials <- tmdb_credentials()
}
}
