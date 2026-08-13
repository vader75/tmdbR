\name{tmdb_auth}
\alias{tmdb_auth}
\alias{tmdb_token_path}
\alias{tmdb_forget_token}
\title{Manage a Cached TMDB Bearer Token}
\usage{
tmdb_auth(bearer_token = NULL, overwrite = FALSE)

tmdb_token_path()

tmdb_forget_token()
}
\arguments{
  \item{bearer_token}{TMDB API Read Access Token. If omitted, R prompts for it.}
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
The default file is \code{token.rds} under
\code{tools::R_user_dir("tmdbR", "cache")}. Set \code{TMDB_TOKEN_FILE} to use
a different filename. When a token already exists, \code{tmdb_auth()} asks
whether it should be kept or replaced. Set \code{overwrite = TRUE} to replace
it without asking. Explicit credentials and environment variables take
precedence over the cached token.
}
\examples{
tmdb_token_path()
\dontrun{
tmdb_auth()
tmdb_forget_token()
}
}
