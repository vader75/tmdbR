test_that("cached tokens can be saved, read, overwritten, and forgotten", {
  path <- tempfile(fileext = ".rds")
  old <- options(tmdbR.token_path = path)
  on.exit(options(old), add = TRUE)

  expect_equal(tmdb_auth("cached-token"), path)
  expect_true(file.exists(path))
  expect_equal(tmdb_credentials(bearer_token = "", api_key = "")$bearer_token,
               "cached-token")
  expect_equal(tmdb_auth("replacement", overwrite = TRUE), path)
  expect_equal(tmdb_credentials(bearer_token = "", api_key = "")$bearer_token,
               "replacement")
  expect_true(tmdb_forget_token())
  expect_false(file.exists(path))
})

test_that("environment credentials take precedence over cached tokens", {
  path <- tempfile(fileext = ".rds")
  old <- options(tmdbR.token_path = path)
  on.exit(options(old), add = TRUE)
  tmdb_auth("cached-token")

  expect_equal(
    tmdb_credentials(bearer_token = "environment-token", api_key = "")$bearer_token,
    "environment-token"
  )
  expect_equal(
    tmdb_credentials(bearer_token = "", api_key = "environment-key")$api_key,
    "environment-key"
  )
})
