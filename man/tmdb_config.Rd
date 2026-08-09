\name{tmdb_config}
\alias{tmdb_config}
\title{Configure TMDB requests}
\usage{
tmdb_config(bearer_token = NULL, api_key = NULL,
  timeout = 15, max_tries = 3)
}
\arguments{
  \item{bearer_token}{Optional API Read Access Token.}
  \item{api_key}{Optional TMDB v3 API key.}
  \item{timeout}{Positive request timeout in seconds.}
  \item{max_tries}{Positive integer number of attempts for transient failures.}
}
\value{A configuration list accepted by \code{tmdb_request()} and \code{tmdb_request_all()}.}
\description{Create reusable authentication, timeout, and retry settings.}
\details{Bearer authentication is preferred if both credential types are supplied.}
\seealso{\code{tmdb_request}, \code{tmdb_credentials}}
\examples{
cfg <- tmdb_config(timeout = 30, max_tries = 5)
\dontrun{
# Requires credentials in cfg or the environment.
tmdb_request("movie/550", config = cfg)
}
}

