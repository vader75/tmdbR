\name{timezone}
\alias{timezone}
\title{Timezone from TMDB}
\usage{
timezone(api_key = NULL) 
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/configuration/timezones} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
\dontrun{
# Requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
timezone()
}
}

