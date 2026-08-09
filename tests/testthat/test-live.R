test_that("representative live endpoint smoke tests", {
  skip_if(Sys.getenv("TMDB_LIVE_TESTS") != "true")
  skip_if(!nzchar(Sys.getenv("TMDB_BEARER_TOKEN")) && !nzchar(Sys.getenv("TMDB_API_KEY")))

  expect_equal(movie(id = 550)$id, 550)
  expect_true(length(search_movie(query = "Spirited Away")$results) > 0)
  expect_true(length(tv(id = 1399)$name) == 1)
  expect_true(length(person_tmdb(id = 287)$name) == 1)
  expect_true(length(configuration()$images) > 0)
  expect_true(length(discover_movie(page = 1)$results) > 0)
  expect_true(is.list(movie_images(id = 550)))
  expect_true(length(changes_movie(page = 1)$results) >= 0)
})

test_that("both configured authentication modes work live", {
  skip_if(Sys.getenv("TMDB_LIVE_TESTS") != "true")
  bearer <- Sys.getenv("TMDB_BEARER_TOKEN")
  api_key <- Sys.getenv("TMDB_API_KEY")
  if (nzchar(bearer)) expect_equal(tmdb_request("movie/550", bearer_token = bearer)$id, 550)
  if (nzchar(api_key)) expect_equal(tmdb_request("movie/550", api_key = api_key)$id, 550)
  skip_if(!nzchar(bearer) && !nzchar(api_key))
})

test_that("live automatic pagination combines sequential pages", {
  skip_if(Sys.getenv("TMDB_LIVE_TESTS") != "true")
  skip_if(!nzchar(Sys.getenv("TMDB_BEARER_TOKEN")) && !nzchar(Sys.getenv("TMDB_API_KEY")))

  popular <- tmdb_paginate(
    movie_popular,
    max_pages = 2,
    max_results = 25,
    deduplicate_by = "id",
    progress = FALSE,
    delay = 0
  )
  expect_equal(popular$pages_fetched, 2L)
  expect_equal(popular$result_count, 25L)
  expect_true(popular$truncated)
  expect_false(anyDuplicated(popular$results$id) > 0)

  discovered <- tmdb_request_all(
    "discover/movie",
    query = list(with_genres = 878, sort_by = "popularity.desc"),
    max_pages = 2,
    progress = FALSE,
    delay = 0
  )
  expect_equal(discovered$pages_fetched, 2L)
  expect_true(discovered$result_count > 20L)

  events <- character()
  direct <- movie_popular(
    paginate = TRUE,
    max_pages = 2,
    max_results = 25,
    deduplicate_by = "id",
    progress = function(info) events <<- c(events, info$event),
    delay = 0
  )
  expect_equal(direct$pages_fetched, 2L)
  expect_equal(direct$result_count, 25L)
  expect_equal(events, c("start", "page", "page", "finish"))
})
