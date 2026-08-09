\name{list_item_status}
\alias{list_item_status}
\title{List Item Status from TMDB}
\usage{
list_item_status(api_key = NULL, id, movie_id) 
}
\arguments{
  \item{api_key}{Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.}
  \item{id}{TMDB identifier for the requested resource.}
  \item{movie_id}{TMDB movie identifier.}
}
\value{The parsed TMDB response as R lists, data frames, and vectors.}
\description{Request the \code{/list/\\{id\\}/item_status} endpoint.}
\details{The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message. Authentication can use an explicit API key or package environment variables.}
\seealso{\code{tmdb_request}}
\examples{
\dontrun{
# Requires TMDB_BEARER_TOKEN or TMDB_API_KEY.
list_item_status(id = "replace-with-list-id", movie_id = 550)
}
}

