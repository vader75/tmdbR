test_that("all compatibility functions satisfy their live TMDB contracts", {
  skip_if(Sys.getenv("TMDB_LIVE_TESTS") != "true")
  skip_if(!nzchar(Sys.getenv("TMDB_BEARER_TOKEN")) &&
          !nzchar(Sys.getenv("TMDB_API_KEY")))

  legacy <- names(get(".tmdb_legacy_specs", asNamespace("tmdbR")))

  credits <- movie_credits(id = 550)$cast
  expect_gt(nrow(credits), 0L)
  credit_id <- credits$credit_id[[1L]]

  review_id <- NA_character_
  list_id <- NA
  for (movie_id in c(550, 11, 155)) {
    if (is.na(review_id)) {
      reviews <- movie_reviews(id = movie_id)$results
      if (nrow(reviews)) review_id <- reviews$id[[1L]]
    }
    if (is.na(list_id)) {
      lists <- movie_lists(id = movie_id)$results
      if (nrow(lists)) list_id <- lists$id[[1L]]
    }
  }
  expect_false(is.na(review_id))
  expect_false(is.na(list_id))

  required_values <- list(
    id = 1, credit_id = credit_id, movie_id = 550,
    season_number = 1, episode_number = 1,
    query = "Spirited Away", external_source = "imdb_id"
  )

  arguments_for <- function(name, fn) {
    formal_names <- names(formals(fn))
    required <- formal_names[vapply(
      formals(fn), identical, logical(1), quote(expr = )
    )]
    args <- lapply(required, function(argument) required_values[[argument]])
    names(args) <- required

    if ("id" %in% formal_names) {
      args$id <- if (grepl("^movie", name)) {
        550
      } else if (name == "tv_episode_changes") {
        63056
      } else if (name == "tv_season_changes") {
        3624
      } else if (grepl("^tv", name)) {
        1399
      } else if (grepl("^person", name)) {
        287
      } else if (grepl("collection", name)) {
        10
      } else if (grepl("company", name)) {
        4
      } else if (grepl("keyword", name)) {
        1721
      } else if (grepl("network", name)) {
        213
      } else if (name == "genres_movies") {
        28
      } else if (grepl("^list_", name)) {
        list_id
      } else if (name == "review") {
        review_id
      } else {
        1
      }
    }
    if (name == "find_tmdb") {
      args$id <- "tt0137523"
      args$external_source <- "imdb_id"
    }
    if (name == "credit") args$credit_id <- credit_id
    if ("movie_id" %in% formal_names) args$movie_id <- 550
    if ("query" %in% formal_names) {
      args$query <- if (name == "search_person") {
        "Tom Hanks"
      } else if (name == "search_tv") {
        "The Last of Us"
      } else {
        "Spirited Away"
      }
    }
    args
  }

  failures <- character()
  for (name in legacy) {
    fn <- getExportedValue("tmdbR", name)
    outcome <- tryCatch(
      do.call(fn, arguments_for(name, fn)),
      error = identity
    )
    if (inherits(outcome, "error")) {
      failures <- c(failures, sprintf("%s: %s", name, conditionMessage(outcome)))
    }
    Sys.sleep(0.05)
  }
  if (length(failures)) {
    stop("Live TMDB contract failures:\n", paste(failures, collapse = "\n"),
         call. = FALSE)
  }
  expect_equal(length(failures), 0L)
})
