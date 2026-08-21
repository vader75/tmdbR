\name{tmdb_auth}
\alias{tmdb_auth}
\alias{tmdb_token_path}
\alias{tmdb_forget_token}
\title{Manage a Cached TMDB Bearer Token}
\usage{
tmdb_auth(bearer_token = NULL, path = NULL, overwrite = FALSE)

tmdb_token_path(path = NULL)

tmdb_forget_token(path = NULL)
}
\arguments{
  \item{bearer_token}{TMDB API Read Access Token. If omitted, R prompts for it.}
  \item{path}{Token-cache file path. If omitted, the explicitly configured
  \code{tmdbR.token_path} option or \code{TMDB_TOKEN_FILE} environment
  variable is used.}
  \item{overwrite}{Whether to replace an existing cached token without asking.}
}
\value{
\code{tmdb_auth()} invisibly returns the token-file path.
\code{tmdb_token_path()} returns the token-file path.
\code{tmdb_forget_token()} invisibly returns whether the file is absent.
}
\description{
Save, locate, or remove the encrypted TMDB bearer-token cache.
}
\details{
No file path is selected by default. Supply \code{path}, set
\code{options(tmdbR.token_path = ...)}, or set \code{TMDB_TOKEN_FILE}. When a
token already exists, \code{tmdb_auth()} asks
whether it should be kept or replaced. Set \code{overwrite = TRUE} to replace
it without asking. Explicit credentials and environment variables take
precedence over the cached token.
}
\examples{
token_file <- file.path(tempdir(), "tmdbR-token.rds")
tmdb_token_path(token_file)
\dontrun{
tmdb_auth(path = token_file)
tmdb_forget_token(path = token_file)
}
}
