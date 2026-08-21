.tmdb_base_url <- "https://api.themoviedb.org"

tmdb_credentials <- function(bearer_token = Sys.getenv("TMDB_BEARER_TOKEN"),
                             api_key = Sys.getenv("TMDB_API_KEY")) {
  bearer_token <- trimws(bearer_token %||% "")
  api_key <- trimws(api_key %||% "")
  if (!nzchar(bearer_token) && !nzchar(api_key)) {
    bearer_token <- .tmdb_read_cached_token() %||% ""
  }
  if (!nzchar(bearer_token) && !nzchar(api_key)) {
    stop(
      "TMDB credentials are missing. Run tmdb_auth(path = ...), set TMDB_BEARER_TOKEN, or set TMDB_API_KEY.",
      call. = FALSE
    )
  }
  list(
    bearer_token = if (nzchar(bearer_token)) bearer_token else NULL,
    api_key = if (nzchar(api_key)) api_key else NULL
  )
}

tmdb_config <- function(bearer_token = NULL, api_key = NULL,
                        timeout = 15, max_tries = 3) {
  if (!is.numeric(timeout) || length(timeout) != 1L || timeout <= 0) {
    stop("timeout must be one positive number", call. = FALSE)
  }
  if (!is.numeric(max_tries) || length(max_tries) != 1L ||
      max_tries < 1 || max_tries %% 1 != 0) {
    stop("max_tries must be a positive integer", call. = FALSE)
  }
  list(
    bearer_token = bearer_token,
    api_key = api_key,
    timeout = timeout,
    max_tries = as.integer(max_tries)
  )
}

tmdb_request <- function(path, query = list(), api_key = NULL,
                         bearer_token = NULL, version = 3L,
                         config = NULL) {
  if (!is.character(path) || length(path) != 1L || !nzchar(path)) {
    stop("path must be one non-empty string", call. = FALSE)
  }
  if (!is.list(query)) stop("query must be a named list", call. = FALSE)
  if (!is.null(config)) {
    bearer_token <- bearer_token %||% config$bearer_token
    api_key <- api_key %||% config$api_key
  }
  supplied <- list(bearer_token = bearer_token, api_key = api_key)
  env <- NULL
  if (!nzchar(supplied$bearer_token %||% "") &&
      !nzchar(supplied$api_key %||% "")) {
    env <- tmdb_credentials()
  }
  bearer_token <- supplied$bearer_token %||% env$bearer_token
  api_key <- supplied$api_key %||% env$api_key
  timeout <- config$timeout %||% 15
  max_tries <- config$max_tries %||% 3L

  path <- sub("^/+", "", path)
  if (!grepl(paste0("^", version, "/"), path)) {
    path <- paste0(version, "/", path)
  }
  req <- httr2::request(paste0(.tmdb_base_url, "/", path))
  req <- httr2::req_headers(req, Accept = "application/json")
  if (nzchar(bearer_token %||% "")) {
    req <- httr2::req_headers(req, Authorization = paste("Bearer", bearer_token))
  } else {
    query$api_key <- api_key
  }
  query <- .tmdb_clean_query(query)
  if (length(query)) req <- do.call(httr2::req_url_query, c(list(req), query))
  req <- httr2::req_timeout(req, timeout)
  req <- httr2::req_retry(
    req,
    max_tries = max_tries,
    retry_on_failure = TRUE,
    is_transient = function(resp) httr2::resp_status(resp) %in% c(429L, 500L, 502L, 503L, 504L)
  )
  # Parse TMDB's JSON error envelope ourselves after retries are exhausted.
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  performer <- getOption("tmdbR.request_performer", httr2::req_perform)
  resp <- tryCatch(
    performer(req),
    error = function(e) stop("TMDB request failed: ", conditionMessage(e), call. = FALSE)
  )
  status <- httr2::resp_status(resp)
  body <- httr2::resp_body_string(resp)
  parsed <- tryCatch(
    jsonlite::fromJSON(body, simplifyVector = TRUE),
    error = function(e) NULL
  )
  if (status < 200L || status >= 300L) {
    message <- parsed$status_message %||% paste("HTTP", status)
    code <- parsed$status_code %||% NA_integer_
    stop(sprintf("TMDB request failed (%s, code %s): %s", status, code, message), call. = FALSE)
  }
  if (is.null(parsed)) stop("TMDB returned malformed JSON", call. = FALSE)
  parsed
}

.tmdb_clean_query <- function(query) {
  if (!length(query)) return(list())
  if (is.null(names(query)) || any(!nzchar(names(query)))) {
    stop("query must be a named list", call. = FALSE)
  }
  keep <- !vapply(query, function(x) {
    is.null(x) || length(x) == 0L || (length(x) == 1L && is.na(x))
  }, logical(1))
  query <- query[keep]
  lapply(query, function(x) {
    if (is.logical(x)) return(tolower(as.character(x)))
    if (length(x) > 1L) return(paste(x, collapse = ","))
    x
  })
}

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x
