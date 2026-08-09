root <- normalizePath(if (file.exists("DESCRIPTION")) "." else "..")
env <- new.env(parent = globalenv())
for (file in c("R/client.R", "R/legacy-engine.R", "R/legacy-specs.R")) {
  sys.source(file.path(root, file), envir = env)
}

argument_docs <- c(
  api_key = "Optional TMDB v3 API key. If omitted, the package uses TMDB_BEARER_TOKEN or TMDB_API_KEY from the environment.",
  id = "TMDB identifier for the requested resource.",
  credit_id = "TMDB credit identifier.",
  movie_id = "TMDB movie identifier.",
  season_number = "Season number within the TV series.",
  episode_number = "Episode number within the season.",
  query = "Text to search for.",
  page = "Result page, starting at 1. Use tmdb_paginate() to collect multiple pages.",
  language = "Language code, optionally including a region, such as en-AU.",
  region = "ISO 3166-1 region code, such as AU.",
  country = "ISO 3166-1 country code.",
  timezone = "Timezone used to determine the broadcast date.",
  append_to_response = "Comma-separated related endpoints to include in the same response, with a maximum of 20.",
  include_image_language = "Image languages to include, for example c(\"en\", \"null\").",
  include_adult = "Whether adult content may be included.",
  include_video = "Whether video records may be included.",
  include_all_movies = "Deprecated legacy option retained for call compatibility.",
  start_date = "Start of the change window in YYYY-MM-DD format.",
  end_date = "End of the change window in YYYY-MM-DD format.",
  external_source = "External identifier source, such as imdb_id.",
  certification_country = "Country whose certification system should be used.",
  certification = "Exact certification filter.",
  certification.lte = "Maximum certification filter.",
  primary_release_year = "Four-digit primary release year.",
  primary_release_date.gte = "Earliest primary release date in YYYY-MM-DD format.",
  primary_release_date.lte = "Latest primary release date in YYYY-MM-DD format.",
  release_date.gte = "Earliest release date in YYYY-MM-DD format.",
  release_date.lte = "Latest release date in YYYY-MM-DD format.",
  first_air_date_year = "Four-digit first-air year.",
  first_air_date.gte = "Earliest first-air date in YYYY-MM-DD format.",
  first_air_date.lte = "Latest first-air date in YYYY-MM-DD format.",
  year = "Four-digit release year.",
  sort_by = "TMDB sort expression, such as popularity.desc.",
  vote_count.gte = "Minimum vote count.",
  vote_count.lte = "Maximum vote count.",
  vote_average.gte = "Minimum average vote.",
  vote_average.lte = "Maximum average vote.",
  with_cast = "Cast IDs used to filter results.",
  with_crew = "Crew IDs used to filter results.",
  with_companies = "Company IDs used to filter results.",
  with_genres = "Genre IDs used to filter results.",
  with_keywords = "Keyword IDs used to filter results.",
  with_people = "Person IDs used to filter results.",
  with_networks = "Network IDs used to filter results.",
  watch_region = "ISO 3166-1 region used for watch-provider availability.",
  with_watch_providers = "Watch-provider IDs, supplied as a vector or TMDB filter expression.",
  with_watch_monetization_types = "Monetisation filters such as flatrate, free, ads, rent, or buy.",
  search_type = "Legacy search-type option retained for call compatibility.",
  paginate = "Whether to retrieve and combine sequential result pages. Defaults to FALSE for backward compatibility.",
  max_pages = "Maximum pages when paginate is TRUE. Defaults to 5; use Inf explicitly to remove this limit.",
  max_results = "Maximum combined results when paginate is TRUE. Defaults to 100.",
  max_memory_mb = "Approximate memory limit in megabytes for collected page results. Defaults to 100.",
  simplify = "Whether compatible result pages should be combined into a data frame.",
  deduplicate_by = "Optional field, normally id, used to remove duplicate records across pages.",
  progress = "TRUE for progress messages, FALSE for silence, or a callback function receiving progress events.",
  delay = "Non-negative delay in seconds between successful page requests.",
  ... = "Additional current TMDB query parameters supported by this endpoint."
)

title_for <- function(name) {
  words <- gsub("_", " ", name, fixed = TRUE)
  paste0(tools::toTitleCase(words), " from TMDB")
}

description_for <- function(name, spec) {
  action <- if (grepl("^search_", name)) "Search TMDB using" else if (grepl("^discover_", name)) "Discover TMDB records using" else "Request"
  path <- gsub("}", "\\\\}", gsub("{", "\\\\{", spec$path, fixed = TRUE), fixed = TRUE)
  paste(action, sprintf("the \\code{/%s} endpoint.", path))
}

example_args <- function(name, fn) {
  f <- names(formals(fn))
  args <- character()
  add <- function(key, value) if (key %in% f) args <<- c(args, paste0(key, " = ", value))
  if ("query" %in% f) add("query", if (name == "search_person") '"Tom Hanks"' else if (name == "search_tv") '"The Last of Us"' else '"Spirited Away"')
  if ("credit_id" %in% f) add("credit_id", '"replace-with-credit-id"')
  if ("external_source" %in% f) {
    add("id", '"tt0137523"')
    add("external_source", '"imdb_id"')
  } else if ("id" %in% f) {
    value <- if (grepl("^movie", name)) "550" else if (grepl("^tv", name)) "1399" else if (grepl("^person", name)) "287" else if (grepl("collection", name)) "10" else if (grepl("company", name)) "4" else if (grepl("keyword", name)) "1721" else if (grepl("network", name)) "213" else if (grepl("list", name)) '"replace-with-list-id"' else if (name == "review") '"replace-with-review-id"' else "1"
    add("id", value)
  }
  add("movie_id", "550")
  add("season_number", "1")
  add("episode_number", "1")
  add("language", '"en-AU"')
  if (name %in% c("movie", "tv")) add("append_to_response", '"credits,videos"')
  if (name == "person_tmdb") add("append_to_response", '"combined_credits"')
  add("region", '"AU"')
  add("watch_region", '"AU"')
  add("with_watch_providers", "c(8, 9)")
  add("with_watch_monetization_types", '"flatrate"')
  add("include_image_language", 'c("en", "null")')
  if ("start_date" %in% f) {
    add("start_date", "as.character(Sys.Date() - 6)")
    add("end_date", "as.character(Sys.Date())")
  }
  if (!length(args) && "page" %in% f) add("page", "1")
  if ("paginate" %in% f) {
    add("paginate", "TRUE")
    add("max_pages", "2")
    add("max_results", "40")
    add("progress", "TRUE")
  }
  paste(args, collapse = ", ")
}

details_for <- function(name) {
  special <- c(
    movie_releases = "This compatibility function uses the current /release_dates endpoint.",
    keyword_movies = "The legacy keyword-movies endpoint is deprecated; this function uses /discover/movie with with_keywords.",
    company_movies = "The legacy company-movies endpoint is replaced by /discover/movie with with_companies.",
    genres_movies = "The legacy genre-movies endpoint is replaced by /discover/movie with with_genres.",
    search_list = "The removed list-search endpoint is mapped to current collection search."
  )
  text <- unname(special[name])
  if (!length(text) || is.na(text)) text <- "The response is parsed from JSON into ordinary R lists, data frames, and vectors. HTTP failures raise an error containing TMDB's status and message."
  text
}

for (name in names(env$.tmdb_legacy_specs)) {
  spec <- env$.tmdb_legacy_specs[[name]]
  fn <- env[[name]]
  formals_names <- names(formals(fn))
  signature <- paste(capture.output(print(args(fn))), collapse = "\n")
  signature <- sub("^function ", "", signature)
  signature <- sub("\nNULL$", "", signature)
  usage <- paste0(name, signature)
  items <- vapply(formals_names, function(arg) {
    doc <- argument_docs[[arg]]
    if (is.null(doc)) doc <- paste("Value for", arg, "as accepted by TMDB.")
    sprintf("  \\item{%s}{%s}", arg, doc)
  }, character(1))
  example <- sprintf("%s(%s)", name, example_args(name, fn))
  paginated <- "page" %in% formals_names || grepl("^(search_|discover_|changes_)", name)
  seealso <- if (paginated) "\\code{tmdb_paginate}, \\code{tmdb_request}" else "\\code{tmdb_request}"
  value <- if (paginated) "A parsed response containing page metadata and a results data frame or list." else "The parsed TMDB response as R lists, data frames, and vectors."
  pagination_note <- if ("paginate" %in% formals_names) c(
    "\\section{Important pagination note}{",
    "\\strong{Important:} TMDB controls page size and does not document a supported page-size parameter. Standard search, discover, and list endpoints currently return up to 20 records per full page; global movie, TV, and person change feeds currently return up to 100. A final page can contain fewer records. These values are observed behavior, not a contractual guarantee. This function counts the actual results in each response and uses TMDB's total_pages metadata rather than assuming a fixed page size.",
    "}"
  ) else character()
  rd <- c(
    sprintf("\\name{%s}", name),
    sprintf("\\alias{%s}", name),
    sprintf("\\title{%s}", title_for(name)),
    "\\usage{", usage, "}",
    "\\arguments{", items, "}",
    sprintf("\\value{%s}", value),
    sprintf("\\description{%s}", description_for(name, spec)),
    sprintf("\\details{%s Authentication can use an explicit API key or package environment variables.}", details_for(name)),
    pagination_note,
    sprintf("\\seealso{%s}", seealso),
    "\\examples{", "\\dontrun{",
    "# Requires TMDB_BEARER_TOKEN or TMDB_API_KEY.", example,
    "}", "}", ""
  )
  writeLines(rd, file.path(root, "man", paste0(name, ".Rd")))
}
