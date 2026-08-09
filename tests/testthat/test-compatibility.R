test_that("all legacy functions are exported", {
  expected <- names(get(".tmdb_legacy_specs", asNamespace("tmdbR")))
  expect_length(expected, 88L)
  expect_true(all(expected %in% getNamespaceExports("tmdbR")))
})

test_that("every compatibility wrapper builds a valid HTTPS request", {
  specs <- get(".tmdb_legacy_specs", asNamespace("tmdbR"))
  capture <- new.env(parent = emptyenv())
  values <- list(
    api_key = "x", id = 1, credit_id = "credit-1", query = "test",
    external_source = "imdb_id", movie_id = 1,
    season_number = 1, episode_number = 1
  )
  for (name in names(specs)) {
    fn <- getExportedValue("tmdbR", name)
    required <- names(formals(fn))[vapply(formals(fn), identical, logical(1), quote(expr = ))]
    args <- lapply(required, function(arg) values[[arg]])
    names(args) <- required
    args$api_key <- "x"
    expect_no_error(with_tmdb_mock(mock_tmdb(capture = capture), do.call(fn, args)))
    expect_match(capture$req$url, "https://api.themoviedb.org/3/", fixed = TRUE, info = name)
    expect_false(grepl("\\{", capture$req$url), info = name)
  }
})

test_that("legacy wrappers build representative endpoint contracts", {
  capture <- new.env(parent = emptyenv())
  with_tmdb_mock(mock_tmdb(body = '{"ok":true}', capture = capture),
    movie(api_key = "x", id = 550, language = "en-US", append_to_response = "credits, videos"))
  expect_match(capture$req$url, "/3/movie/550", fixed = TRUE)
  expect_match(capture$req$url, "append_to_response=credits%2Cvideos", fixed = TRUE)

  with_tmdb_mock(mock_tmdb(capture = capture),
    tv_episode(api_key = "x", id = 1399, season_number = 1, episode_number = 1))
  expect_match(capture$req$url, "/3/tv/1399/season/1/episode/1", fixed = TRUE)
})

test_that("deprecated mappings use supported endpoints", {
  capture <- new.env(parent = emptyenv())
  with_tmdb_mock(mock_tmdb(capture = capture), movie_releases("x", 550))
  expect_match(capture$req$url, "/movie/550/release_dates", fixed = TRUE)

  with_tmdb_mock(mock_tmdb(capture = capture), keyword_movies("x", 123))
  expect_match(capture$req$url, "/discover/movie", fixed = TRUE)
  expect_match(capture$req$url, "with_keywords=123", fixed = TRUE)

  with_tmdb_mock(mock_tmdb(capture = capture), company_movies("x", 4))
  expect_match(capture$req$url, "with_companies=4", fixed = TRUE)
})

test_that("discover supports current watch-provider filters", {
  capture <- new.env(parent = emptyenv())
  with_tmdb_mock(mock_tmdb(capture = capture),
    discover_movie("x", watch_region = "AU", with_watch_providers = c(8, 9),
                   with_watch_monetization_types = "flatrate"))
  expect_match(capture$req$url, "watch_region=AU", fixed = TRUE)
  expect_match(capture$req$url, "with_watch_providers=8%2C9", fixed = TRUE)
})

test_that("append_to_response is limited to twenty items", {
  values <- paste(seq_len(21), collapse = ",")
  expect_error(movie("x", 550, append_to_response = values), "at most 20")
})
