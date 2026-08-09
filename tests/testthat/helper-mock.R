mock_tmdb <- function(status = 200L, body = "{}", capture = NULL) {
  function(req) {
    if (!is.null(capture)) capture$req <- req
    httr2::response(
      status_code = status,
      url = req$url,
      headers = list(`content-type` = "application/json"),
      body = charToRaw(body)
    )
  }
}

with_tmdb_mock <- function(mock, code) {
  old <- options(tmdbR.request_performer = mock)
  on.exit(options(old), add = TRUE)
  force(code)
}

