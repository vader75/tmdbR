tmdb_paginate <- function(.f, ..., start_page = 1L, max_pages = 5L,
                          max_results = 100L, max_memory_mb = 100,
                          simplify = TRUE,
                          deduplicate_by = NULL, progress = interactive(),
                          delay = 0.05) {
  if (is.character(.f) && length(.f) == 1L) {
    .f <- match.fun(.f)
  }
  if (!is.function(.f)) stop(".f must be a function or function name", call. = FALSE)
  args <- list(...)
  if ("page" %in% names(args)) {
    stop("Use start_page instead of passing page through ...", call. = FALSE)
  }
  fetch <- function(page) do.call(.f, c(args, list(page = page)))
  .tmdb_collect_pages(
    fetch, start_page, max_pages, max_results, max_memory_mb, simplify,
    deduplicate_by, progress, delay
  )
}

tmdb_request_all <- function(path, query = list(), api_key = NULL,
                             bearer_token = NULL, version = 3L,
                             config = NULL, start_page = 1L,
                             max_pages = 5L, max_results = 100L,
                             max_memory_mb = 100, simplify = TRUE,
                             deduplicate_by = NULL,
                             progress = interactive(), delay = 0.05) {
  if (!is.list(query)) stop("query must be a named list", call. = FALSE)
  if ("page" %in% names(query)) {
    stop("Use start_page instead of query$page", call. = FALSE)
  }
  fetch <- function(page) {
    tmdb_request(
      path = path,
      query = c(query, list(page = page)),
      api_key = api_key,
      bearer_token = bearer_token,
      version = version,
      config = config
    )
  }
  .tmdb_collect_pages(
    fetch, start_page, max_pages, max_results, max_memory_mb, simplify,
    deduplicate_by, progress, delay
  )
}

.tmdb_collect_pages <- function(fetch, start_page, max_pages, max_results,
                                max_memory_mb, simplify, deduplicate_by,
                                progress, delay) {
  .tmdb_validate_pagination(start_page, max_pages, max_results, max_memory_mb,
                            simplify, deduplicate_by, progress, delay)
  pages <- list()
  page <- as.integer(start_page)
  fetched <- 0L
  observed <- 0L
  reported_pages <- NA_integer_
  reported_results <- NA_integer_
  memory_bytes <- 0
  memory_limit_reached <- FALSE

  repeat {
    response <- fetch(page)
    if (!is.list(response) || is.null(response$results)) {
      stop("TMDB pagination response must contain a results field", call. = FALSE)
    }
    if (fetched == 0L) {
      reported_pages <- as.integer(response$total_pages %||% page)
      reported_results <- as.integer(response$total_results %||% length(response$results))
      if (is.infinite(max_pages) && reported_pages > 100L) {
        warning(sprintf(
          "TMDB reports %s pages. Consider setting max_pages or max_results.",
          reported_pages
        ), call. = FALSE)
      }
      .tmdb_pagination_start(progress, page, reported_pages, reported_results,
                             max_pages, max_results)
    }
    result <- response$results
    pages[[length(pages) + 1L]] <- result
    memory_bytes <- memory_bytes + as.numeric(utils::object.size(result))
    count <- if (is.data.frame(result)) nrow(result) else length(result)
    observed <- observed + count
    fetched <- fetched + 1L
    .tmdb_pagination_progress(progress, page, reported_pages, observed,
                              reported_results)

    at_last_page <- page >= (as.integer(response$total_pages %||% page))
    empty_page <- count == 0L
    page_limit <- is.finite(max_pages) && fetched >= max_pages
    result_limit <- is.finite(max_results) && observed >= max_results
    memory_limit_reached <- is.finite(max_memory_mb) &&
      memory_bytes >= max_memory_mb * 1024^2
    if (at_last_page || empty_page || page_limit || result_limit ||
        memory_limit_reached) break
    page <- page + 1L
    if (delay > 0) Sys.sleep(delay)
  }

  results <- .tmdb_bind_results(pages, simplify)
  if (!is.null(deduplicate_by)) {
    results <- .tmdb_deduplicate(results, deduplicate_by)
  }
  if (is.finite(max_results)) {
    results <- .tmdb_head_results(results, as.integer(max_results))
  }
  result_count <- if (is.data.frame(results)) nrow(results) else length(results)
  complete <- !is.na(reported_pages) && page >= reported_pages
  if (reported_results == 0L) complete <- TRUE
  truncated <- !complete
  .tmdb_pagination_finish(progress, fetched, result_count, truncated,
                          memory_bytes, memory_limit_reached)

  structure(
    list(
      results = results,
      pages_fetched = fetched,
      start_page = as.integer(start_page),
      last_page = page,
      total_pages = reported_pages,
      total_results = reported_results,
      result_count = result_count,
      truncated = truncated,
      memory_bytes = memory_bytes,
      memory_limit_reached = memory_limit_reached
    ),
    class = c("tmdb_paginated", "list")
  )
}

.tmdb_validate_pagination <- function(start_page, max_pages, max_results,
                                      max_memory_mb, simplify, deduplicate_by,
                                      progress, delay) {
  whole <- function(x) is.numeric(x) && length(x) == 1L && !is.na(x) &&
    is.finite(x) && x >= 1 && x %% 1 == 0
  if (!whole(start_page)) stop("start_page must be a positive integer", call. = FALSE)
  if (!(identical(max_pages, Inf) || whole(max_pages))) {
    stop("max_pages must be a positive integer or Inf", call. = FALSE)
  }
  if (!(identical(max_results, Inf) || whole(max_results))) {
    stop("max_results must be a positive integer or Inf", call. = FALSE)
  }
  if (!(identical(max_memory_mb, Inf) ||
        (is.numeric(max_memory_mb) && length(max_memory_mb) == 1L &&
         !is.na(max_memory_mb) && is.finite(max_memory_mb) && max_memory_mb > 0))) {
    stop("max_memory_mb must be one positive number or Inf", call. = FALSE)
  }
  if (!is.logical(simplify) || length(simplify) != 1L || is.na(simplify)) {
    stop("simplify must be TRUE or FALSE", call. = FALSE)
  }
  if (!is.null(deduplicate_by) &&
      (!is.character(deduplicate_by) || length(deduplicate_by) != 1L || !nzchar(deduplicate_by))) {
    stop("deduplicate_by must be NULL or one field name", call. = FALSE)
  }
  if (!(is.function(progress) ||
        (is.logical(progress) && length(progress) == 1L && !is.na(progress)))) {
    stop("progress must be TRUE, FALSE, or a function", call. = FALSE)
  }
  if (!is.numeric(delay) || length(delay) != 1L || is.na(delay) || delay < 0) {
    stop("delay must be one non-negative number", call. = FALSE)
  }
}

.tmdb_pagination_start <- function(progress, page, total_pages, total_results,
                                   max_pages, max_results) {
  planned_pages <- if (is.finite(max_pages)) min(total_pages, max_pages) else total_pages
  planned_results <- if (is.finite(max_results)) min(total_results, max_results) else total_results
  info <- list(event = "start", page = page, total_pages = total_pages,
               total_results = total_results, planned_pages = planned_pages,
               planned_results = planned_results)
  if (is.function(progress)) {
    progress(info)
  } else if (isTRUE(progress)) {
    message(sprintf(
      "TMDB retrieval started: up to %s page%s and %s result%s (API reports %s pages, %s results).",
      planned_pages, if (planned_pages == 1L) "" else "s",
      planned_results, if (planned_results == 1L) "" else "s",
      total_pages, total_results
    ))
  }
  invisible(info)
}

.tmdb_bind_results <- function(pages, simplify) {
  if (!simplify) {
    records <- lapply(pages, .tmdb_page_records)
    return(unlist(records, recursive = FALSE, use.names = FALSE))
  }
  nonempty <- Filter(function(x) length(x) > 0L, pages)
  if (!length(nonempty)) return(data.frame())
  if (!all(vapply(nonempty, is.data.frame, logical(1)))) {
    return(unlist(pages, recursive = FALSE, use.names = FALSE))
  }
  columns <- unique(unlist(lapply(nonempty, names), use.names = FALSE))
  aligned <- lapply(nonempty, function(x) {
    missing <- setdiff(columns, names(x))
    for (name in missing) x[[name]] <- NA
    x[columns]
  })
  result <- do.call(rbind, aligned)
  rownames(result) <- NULL
  result
}

.tmdb_page_records <- function(x) {
  if (!is.data.frame(x)) return(as.list(x))
  lapply(seq_len(nrow(x)), function(i) {
    lapply(x[i, , drop = FALSE], function(value) {
      if (is.list(value) && length(value) == 1L) value[[1L]] else value[[1L]]
    })
  })
}

.tmdb_deduplicate <- function(results, field) {
  if (is.data.frame(results)) {
    if (!field %in% names(results)) stop("deduplicate field is absent from results", call. = FALSE)
    return(results[!duplicated(results[[field]]), , drop = FALSE])
  }
  values <- vapply(results, function(x) {
    value <- if (is.list(x)) x[[field]] else NULL
    if (is.null(value) || length(value) != 1L) NA_character_ else as.character(value)
  }, character(1))
  if (all(is.na(values))) stop("deduplicate field is absent from results", call. = FALSE)
  results[!duplicated(values)]
}

.tmdb_head_results <- function(results, n) {
  if (is.data.frame(results)) return(utils::head(results, n))
  utils::head(results, n)
}

.tmdb_pagination_progress <- function(progress, page, total_pages, results,
                                      total_results) {
  info <- list(event = "page", page = page, total_pages = total_pages, results = results,
               total_results = total_results)
  if (is.function(progress)) {
    progress(info)
  } else if (isTRUE(progress)) {
    message(sprintf("TMDB page %s/%s; %s/%s results", page, total_pages,
                    results, total_results))
  }
  invisible(info)
}

.tmdb_pagination_finish <- function(progress, pages, results, truncated,
                                    memory_bytes, memory_limit_reached) {
  info <- list(event = "finish", pages_fetched = pages, results = results,
               truncated = truncated, memory_bytes = memory_bytes,
               memory_limit_reached = memory_limit_reached)
  if (is.function(progress)) {
    progress(info)
  } else if (isTRUE(progress)) {
    reason <- if (memory_limit_reached) "; memory limit reached" else ""
    message(sprintf(
      "TMDB retrieval finished: %s page%s, %s result%s%s%s.",
      pages, if (pages == 1L) "" else "s",
      results, if (results == 1L) "" else "s",
      if (truncated) "; truncated" else "; complete", reason
    ))
  }
  invisible(info)
}
