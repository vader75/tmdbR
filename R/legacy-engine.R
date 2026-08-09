.tmdb_validate_append <- function(value) {
  if (is.null(value) || length(value) == 0L || all(is.na(value))) return(NULL)
  values <- trimws(unlist(strsplit(paste(value, collapse = ","), ",", fixed = TRUE)))
  values <- values[nzchar(values)]
  if (length(values) > 20L) {
    stop("append_to_response accepts at most 20 endpoints", call. = FALSE)
  }
  paste(values, collapse = ",")
}

.tmdb_legacy_call <- function(name, args) {
  paginate <- args$paginate %||% FALSE
  controls <- c("paginate", "max_pages", "max_results", "max_memory_mb",
                "simplify", "deduplicate_by", "progress", "delay")
  pagination <- args[intersect(controls, names(args))]
  args[intersect(controls, names(args))] <- NULL
  if (!is.logical(paginate) || length(paginate) != 1L || is.na(paginate)) {
    stop("paginate must be TRUE or FALSE", call. = FALSE)
  }
  if (!paginate) return(.tmdb_legacy_page(name, args))

  start_page <- args$page %||% 1L
  fetch <- function(page) {
    page_args <- args
    page_args$page <- page
    .tmdb_legacy_page(name, page_args)
  }
  .tmdb_collect_pages(
    fetch = fetch,
    start_page = start_page,
    max_pages = pagination$max_pages %||% 5L,
    max_results = pagination$max_results %||% 100L,
    max_memory_mb = pagination$max_memory_mb %||% 100,
    simplify = pagination$simplify %||% TRUE,
    deduplicate_by = pagination$deduplicate_by,
    progress = pagination$progress %||% interactive(),
    delay = pagination$delay %||% 0.05
  )
}

.tmdb_legacy_page <- function(name, args) {
  spec <- .tmdb_legacy_specs[[name]]
  if (is.null(spec)) stop("Unknown compatibility function: ", name, call. = FALSE)
  api_key <- args$api_key
  args$api_key <- NULL
  dots <- args[["..."]]
  args[["..."]] <- NULL
  if (length(dots)) args <- c(args, dots)
  if (!is.null(args$append_to_response)) {
    args$append_to_response <- .tmdb_validate_append(args$append_to_response)
  }
  path <- spec$path
  for (field in spec$path_fields) {
    value <- args[[field]]
    if (is.null(value) || length(value) != 1L || is.na(value)) {
      stop(field, " is required", call. = FALSE)
    }
    path <- sub(paste0("\\{", field, "\\}"), as.character(value), path)
    args[[field]] <- NULL
  }
  if (identical(name, "keyword_movies")) {
    args$with_keywords <- args$id
    args$id <- NULL
  }
  if (identical(name, "company_movies")) {
    args$with_companies <- args$id
    args$id <- NULL
    args$append_to_response <- NULL
  }
  if (identical(name, "genres_movies")) {
    args$with_genres <- args$id
    args$id <- NULL
    args$include_all_movies <- NULL
  }
  tmdb_request(path, query = args, api_key = api_key)
}

.tmdb_make_legacy <- function(name, signature) {
  source <- sprintf(
    "function(%s) .tmdb_legacy_call('%s', .tmdb_env_args(environment()))",
    signature, name
  )
  eval(parse(text = source), envir = parent.frame())
}

.tmdb_env_args <- function(envir) {
  args <- as.list(envir, all.names = TRUE)
  args[["..."]] <- NULL
  args
}
