.tmdb_token_key <- I("nL4tEGxOEB1k_fPO7ECt_g")

tmdb_token_path <- function(path = NULL) {
  if (!is.null(path)) return(path.expand(path))

  custom_path <- getOption("tmdbR.token_path")
  if (!is.null(custom_path)) return(path.expand(custom_path))

  env_path <- Sys.getenv("TMDB_TOKEN_FILE", unset = "")
  if (nzchar(env_path)) return(path.expand(env_path))

  NULL
}

tmdb_auth <- function(bearer_token = NULL, path = NULL, overwrite = FALSE) {
  if (!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) {
    stop("overwrite must be TRUE or FALSE", call. = FALSE)
  }

  path <- tmdb_token_path(path)
  if (is.null(path)) {
    stop(
      "Supply path, set options(tmdbR.token_path = ...), or set TMDB_TOKEN_FILE.",
      call. = FALSE
    )
  }
  if (file.exists(path) && !overwrite) {
    replace_token <- utils::askYesNo(
      "A cached TMDB token already exists. Do you want to replace it?",
      default = FALSE
    )
    if (!isTRUE(replace_token)) {
      message("The existing cached TMDB token was kept at ", path)
      return(invisible(path))
    }
  }

  if (is.null(bearer_token)) {
    bearer_token <- readline("Paste your TMDB API Read Access Token: ")
  }
  bearer_token <- trimws(bearer_token)
  if (length(bearer_token) != 1L || !nzchar(bearer_token)) {
    stop("bearer_token must be one non-empty string", call. = FALSE)
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  httr2::secret_write_rds(
    list(bearer_token = bearer_token),
    path = path,
    key = .tmdb_token_key
  )
  message("TMDB token saved to ", path)
  invisible(path)
}

.tmdb_read_cached_token <- function(path = tmdb_token_path()) {
  if (is.null(path)) return(NULL)
  if (!file.exists(path)) return(NULL)
  stored <- tryCatch(
    httr2::secret_read_rds(path, key = .tmdb_token_key),
    error = function(e) {
      stop("The cached TMDB token could not be read. Run tmdb_auth(path = ..., overwrite = TRUE).",
           call. = FALSE)
    }
  )
  token <- trimws(stored$bearer_token %||% "")
  if (!nzchar(token)) {
    stop("The cached TMDB token is empty. Run tmdb_auth(path = ..., overwrite = TRUE).",
         call. = FALSE)
  }
  token
}

tmdb_forget_token <- function(path = NULL) {
  path <- tmdb_token_path(path)
  if (is.null(path)) {
    stop(
      "Supply path, set options(tmdbR.token_path = ...), or set TMDB_TOKEN_FILE.",
      call. = FALSE
    )
  }
  if (file.exists(path)) unlink(path)
  invisible(!file.exists(path))
}
