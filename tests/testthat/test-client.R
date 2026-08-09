test_that("bearer authentication is preferred and secrets are not in URLs", {
  capture <- new.env(parent = emptyenv())
  result <- with_tmdb_mock(mock_tmdb(body = '{"id":550}', capture = capture),
    tmdb_request("movie/550", bearer_token = "secret-token",
                 api_key = "secret-key", query = list(language = "en AU")))

  expect_equal(result$id, 550)
  expect_match(capture$req$url, "https://api.themoviedb.org/3/movie/550", fixed = TRUE)
  expect_false(grepl("secret", capture$req$url, fixed = TRUE))
  expect_match(capture$req$url, "language=en%20AU", fixed = TRUE)
  printed <- paste(capture.output(print(capture$req)), collapse = "\n")
  expect_match(printed, "Authorization: <REDACTED>", fixed = TRUE)
})

test_that("API key fallback is query encoded", {
  capture <- new.env(parent = emptyenv())
  with_tmdb_mock(mock_tmdb(capture = capture),
    tmdb_request("search/movie", api_key = "key + value",
                 query = list(query = "A/B & C")))

  expect_match(capture$req$url, "api_key=key%20%2B%20value", fixed = TRUE)
  expect_match(capture$req$url, "query=A%2FB%20%26%20C", fixed = TRUE)
})

test_that("missing credentials produce actionable errors", {
  cache <- tempfile(fileext = ".rds")
  old_options <- options(tmdbR.token_path = cache)
  on.exit(options(old_options), add = TRUE)
  old <- Sys.getenv(c("TMDB_BEARER_TOKEN", "TMDB_API_KEY"), unset = NA_character_)
  on.exit({
    for (name in names(old)) {
      if (is.na(old[[name]])) Sys.unsetenv(name) else do.call(Sys.setenv, setNames(list(old[[name]]), name))
    }
  }, add = TRUE)
  Sys.unsetenv(c("TMDB_BEARER_TOKEN", "TMDB_API_KEY"))
  expect_error(tmdb_request("movie/550"), "credentials are missing")
})

test_that("TMDB error payloads are surfaced without credentials", {
  mock <- mock_tmdb(401L, '{"status_code":7,"status_message":"Invalid API key"}')
  expect_error(
    with_tmdb_mock(mock, tmdb_request("movie/550", api_key = "redacted")),
    "401, code 7.*Invalid API key"
  )
})

test_that("not found and server errors are surfaced", {
  expect_error(
    with_tmdb_mock(mock_tmdb(404L, '{"status_code":34,"status_message":"Not found"}'),
      tmdb_request("movie/0", api_key = "x")),
    "404, code 34"
  )
  expect_error(
    with_tmdb_mock(mock_tmdb(503L, '{"status_message":"Unavailable"}'),
      tmdb_request("movie/550", api_key = "x")),
    "503.*Unavailable"
  )
})

test_that("empty JSON and malformed JSON are distinguished", {
  empty <- with_tmdb_mock(mock_tmdb(body = "{}"), tmdb_request("configuration", api_key = "x"))
  expect_true(is.list(empty))
  expect_length(empty, 0L)
  expect_error(
    with_tmdb_mock(mock_tmdb(body = "not-json"), tmdb_request("configuration", api_key = "x")),
    "malformed JSON"
  )
})

test_that("configuration validates timeout and retries", {
  expect_error(tmdb_config(timeout = 0), "positive")
  expect_error(tmdb_config(max_tries = 1.5), "integer")
  expect_equal(tmdb_config(max_tries = 4)$max_tries, 4L)
})
