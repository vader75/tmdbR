page_fixture <- function(total_pages = 3L, rows = 2L) {
  function(page) {
    first <- (page - 1L) * rows + 1L
    list(
      page = page,
      results = data.frame(
        id = seq.int(first, length.out = rows),
        title = paste("Title", seq.int(first, length.out = rows))
      ),
      total_pages = total_pages,
      total_results = total_pages * rows
    )
  }
}

test_that("tmdb_paginate collects all reported pages", {
  result <- tmdb_paginate(page_fixture(), max_pages = Inf, delay = 0,
                          progress = FALSE)
  expect_s3_class(result, "tmdb_paginated")
  expect_equal(result$pages_fetched, 3L)
  expect_equal(result$result_count, 6L)
  expect_equal(result$results$id, 1:6)
  expect_false(result$truncated)
})

test_that("page and result limits mark responses as truncated", {
  pages <- tmdb_paginate(page_fixture(5), max_pages = 2, delay = 0,
                         progress = FALSE)
  expect_equal(pages$pages_fetched, 2L)
  expect_true(pages$truncated)

  rows <- tmdb_paginate(page_fixture(5), max_pages = Inf, max_results = 3,
                        delay = 0, progress = FALSE)
  expect_equal(rows$pages_fetched, 2L)
  expect_equal(rows$result_count, 3L)
  expect_true(rows$truncated)
})

test_that("pagination can deduplicate and preserve list results", {
  duplicate_pages <- function(page) list(
    page = page,
    results = data.frame(id = c(page, page + 1L), value = letters[page + 0:1]),
    total_pages = 2L,
    total_results = 4L
  )
  result <- tmdb_paginate(duplicate_pages, max_pages = Inf,
                          deduplicate_by = "id", delay = 0, progress = FALSE)
  expect_equal(result$results$id, 1:3)
  expect_equal(result$result_count, 3L)

  listed <- tmdb_paginate(duplicate_pages, max_pages = 1,
                          simplify = FALSE, delay = 0, progress = FALSE)
  expect_type(listed$results, "list")
  expect_length(listed$results, 2L)
  expect_equal(listed$results[[1]]$id, 1L)
})

test_that("function names can be used for exported wrappers", {
  capture <- new.env(parent = emptyenv())
  mock <- mock_tmdb(body = '{"page":1,"results":[],"total_pages":1,"total_results":0}',
                    capture = capture)
  result <- with_tmdb_mock(mock,
    tmdb_paginate("movie_popular", api_key = "x", delay = 0,
                  progress = FALSE))
  expect_equal(result$pages_fetched, 1L)
  expect_false(result$truncated)
})

test_that("progress callbacks receive page metadata", {
  seen <- list()
  callback <- function(info) seen[[length(seen) + 1L]] <<- info
  tmdb_paginate(page_fixture(2), max_pages = Inf, delay = 0,
                progress = callback)
  expect_equal(vapply(seen, `[[`, character(1), "event"),
               c("start", "page", "page", "finish"))
  expect_equal(seen[[3]]$page, 2L)
})

test_that("pagination validates controls and response shape", {
  expect_error(tmdb_paginate(identity, start_page = 0), "positive integer")
  expect_error(tmdb_paginate(identity, max_pages = 0), "positive integer")
  expect_error(tmdb_paginate(identity, max_results = 1.5), "positive integer")
  expect_error(tmdb_paginate(identity, max_memory_mb = 0), "positive number")
  expect_error(tmdb_paginate(function(page) list(page = page), delay = 0),
               "results field")
  expect_error(tmdb_paginate(page_fixture(), page = 2), "start_page")
  expect_error(tmdb_paginate(page_fixture(), deduplicate_by = "missing",
                             max_pages = 1, delay = 0, progress = FALSE),
               "absent")
})

test_that("memory limits stop collection and are reported", {
  result <- tmdb_paginate(page_fixture(5, rows = 20), max_pages = Inf,
                          max_results = Inf, max_memory_mb = 0.0001,
                          delay = 0, progress = FALSE)
  expect_equal(result$pages_fetched, 1L)
  expect_true(result$memory_limit_reached)
  expect_true(result$truncated)
  expect_gt(result$memory_bytes, 0)
})

test_that("unrestricted large retrievals warn after the first page", {
  expect_warning(
    tmdb_paginate(page_fixture(101), max_pages = Inf, max_results = 1,
                  delay = 0, progress = FALSE),
    "reports 101 pages"
  )
})

test_that("eligible wrappers paginate directly when requested", {
  capture <- new.env(parent = emptyenv())
  capture$urls <- character()
  mock <- function(req) {
    capture$urls <- c(capture$urls, req$url)
    page <- as.integer(sub(".*[?&]page=([0-9]+).*", "\\1", req$url))
    ids <- seq.int((page - 1L) * 20L + 1L, length.out = 20L)
    records <- paste0('{"id":', ids, ',"title":"Movie ', ids, '"}', collapse = ",")
    body <- sprintf(
      '{"page":%d,"results":[%s],"total_pages":1000,"total_results":20000}',
      page, records
    )
    httr2::response(status_code = 200L, url = req$url,
                    headers = list(`content-type` = "application/json"),
                    body = charToRaw(body))
  }
  result <- with_tmdb_mock(mock,
    movie_popular(api_key = "x", paginate = TRUE, delay = 0,
                  progress = FALSE))
  expect_s3_class(result, "tmdb_paginated")
  expect_equal(result$pages_fetched, 5L)
  expect_equal(result$result_count, 100L)
  expect_true(result$truncated)

  capture$urls <- character()
  single <- with_tmdb_mock(mock, movie_popular(api_key = "x"))
  expect_false(inherits(single, "tmdb_paginated"))
  expect_length(capture$urls, 1L)
})

test_that("tmdb_request_all paginates generic endpoints", {
  capture <- new.env(parent = emptyenv())
  capture$urls <- character()
  mock <- function(req) {
    capture$urls <- c(capture$urls, req$url)
    page <- as.integer(sub(".*[?&]page=([0-9]+).*", "\\1", req$url))
    body <- sprintf(
      '{"page":%d,"results":[{"id":%d}],"total_pages":3,"total_results":3}',
      page, page
    )
    httr2::response(status_code = 200L, url = req$url,
                    headers = list(`content-type` = "application/json"),
                    body = charToRaw(body))
  }
  result <- with_tmdb_mock(mock,
    tmdb_request_all("discover/movie", query = list(language = "en-AU"),
                     api_key = "x", max_pages = Inf, delay = 0,
                     progress = FALSE))
  expect_equal(result$results$id, 1:3)
  expect_length(capture$urls, 3L)
  expect_true(all(grepl("language=en-AU", capture$urls, fixed = TRUE)))
})

test_that("query page must be supplied through start_page", {
  expect_error(tmdb_request_all("movie/popular", query = list(page = 2),
                                api_key = "x"), "start_page")
})
