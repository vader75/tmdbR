\name{tv_external_ids}
\alias{tv_external_ids}
\title{Tv External Ids from TMDB}
\usage{
tv_external_ids(api_key = NULL, id, language = NA) 
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{language}{Language code, optionally including a region, such as en-AU.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/tv/\\{id\\}/external_ids} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
\dontrun{
# Requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
tv_external_ids(id = 1399, language = "en-AU")
}
}

