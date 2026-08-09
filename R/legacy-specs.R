.tmdb_spec <- function(path, signature = "api_key = NULL, ...", path_fields = character()) {
  list(path = path, signature = signature, path_fields = path_fields)
}

.tmdb_legacy_specs <- list(
  certification_movie_list = .tmdb_spec("certification/movie/list", "api_key = NULL"),
  certification_tv_list = .tmdb_spec("certification/tv/list", "api_key = NULL"),
  changes_movie = .tmdb_spec("movie/changes", "api_key = NULL, page = 1, start_date = NA, end_date = NA"),
  changes_person = .tmdb_spec("person/changes", "api_key = NULL, page = 1, start_date = NA, end_date = NA"),
  changes_tv = .tmdb_spec("tv/changes", "api_key = NULL, page = 1, start_date = NA, end_date = NA"),
  collection = .tmdb_spec("collection/{id}", "api_key = NULL, id, language = NA, append_to_response = NA", "id"),
  collection_images = .tmdb_spec("collection/{id}/images", "api_key = NULL, id, language = NA, append_to_response = NA, include_image_language = NA", "id"),
  company = .tmdb_spec("company/{id}", "api_key = NULL, id, append_to_response = NA", "id"),
  company_movies = .tmdb_spec("discover/movie", "api_key = NULL, id, page = 1, language = NA, append_to_response = NA, ..."),
  configuration = .tmdb_spec("configuration", "api_key = NULL"),
  credit = .tmdb_spec("credit/{credit_id}", "api_key = NULL, credit_id, language = NA", "credit_id"),
  discover_movie = .tmdb_spec("discover/movie", paste0(
    "api_key = NULL, certification_country = NA, certification = NA, certification.lte = NA, ",
    "include_adult = FALSE, include_video = TRUE, language = NA, page = 1, ",
    "primary_release_year = NA, primary_release_date.gte = NA, primary_release_date.lte = NA, ",
    "release_date.gte = NA, release_date.lte = NA, sort_by = NA, vote_count.gte = NA, ",
    "vote_count.lte = NA, vote_average.gte = NA, vote_average.lte = NA, with_cast = NA, ",
    "with_crew = NA, with_companies = NA, with_genres = NA, with_keywords = NA, ",
    "with_people = NA, year = NA, region = NA, watch_region = NA, ",
    "with_watch_providers = NA, with_watch_monetization_types = NA, ...")),
  discover_tv = .tmdb_spec("discover/tv", paste0(
    "api_key = NULL, page = 1, language = NA, sort_by = NA, first_air_date_year = NA, ",
    "vote_count.gte = NA, vote_average.gte = NA, with_genres = NA, with_networks = NA, ",
    "first_air_date.gte = NA, first_air_date.lte = NA, watch_region = NA, ",
    "with_watch_providers = NA, with_watch_monetization_types = NA, ...")),
  find_tmdb = .tmdb_spec("find/{id}", "api_key = NULL, id, external_source, language = NA", "id"),
  genres_movie_list = .tmdb_spec("genre/movie/list", "api_key = NULL, language = NA"),
  genres_movies = .tmdb_spec("discover/movie", "api_key = NULL, id, page = 1, language = NA, include_all_movies = NA, include_adult = NA, ..."),
  genres_tv_list = .tmdb_spec("genre/tv/list", "api_key = NULL, language = NA"),
  jobs = .tmdb_spec("configuration/jobs", "api_key = NULL"),
  keyword = .tmdb_spec("keyword/{id}", "api_key = NULL, id", "id"),
  keyword_movies = .tmdb_spec("discover/movie", "api_key = NULL, id, page = 1, language = NA, ..."),
  list_get = .tmdb_spec("list/{id}", "api_key = NULL, id", "id"),
  list_item_status = .tmdb_spec("list/{id}/item_status", "api_key = NULL, id, movie_id", "id"),
  movie = .tmdb_spec("movie/{id}", "api_key = NULL, id, language = NA, append_to_response = NA", "id"),
  movie_alternative_title = .tmdb_spec("movie/{id}/alternative_titles", "api_key = NULL, id, country = NA, append_to_response = NA", "id"),
  movie_changes = .tmdb_spec("movie/{id}/changes", "api_key = NULL, id, start_date = NA, end_date = NA", "id"),
  movie_credits = .tmdb_spec("movie/{id}/credits", "api_key = NULL, id, append_to_response = NA", "id"),
  movie_images = .tmdb_spec("movie/{id}/images", "api_key = NULL, id, language = NA, append_to_response = NA, include_image_language = NA", "id"),
  movie_keywords = .tmdb_spec("movie/{id}/keywords", "api_key = NULL, id, append_to_response = NA", "id"),
  movie_latest = .tmdb_spec("movie/latest", "api_key = NULL"),
  movie_lists = .tmdb_spec("movie/{id}/lists", "api_key = NULL, id, page = 1, language = NA, append_to_response = NA", "id"),
  movie_now_playing = .tmdb_spec("movie/now_playing", "api_key = NULL, page = 1, language = NA, region = NA"),
  movie_popular = .tmdb_spec("movie/popular", "api_key = NULL, page = 1, language = NA, region = NA"),
  movie_releases = .tmdb_spec("movie/{id}/release_dates", "api_key = NULL, id, append_to_response = NA", "id"),
  movie_reviews = .tmdb_spec("movie/{id}/reviews", "api_key = NULL, id, page = 1, language = NA, append_to_response = NA", "id"),
  movie_similar = .tmdb_spec("movie/{id}/similar", "api_key = NULL, id, page = 1, language = NA, append_to_response = NA", "id"),
  movie_top_rated = .tmdb_spec("movie/top_rated", "api_key = NULL, page = 1, language = NA, region = NA"),
  movie_translations = .tmdb_spec("movie/{id}/translations", "api_key = NULL, id, language = NA, append_to_response = NA", "id"),
  movie_upcoming = .tmdb_spec("movie/upcoming", "api_key = NULL, page = 1, language = NA, region = NA"),
  movie_videos = .tmdb_spec("movie/{id}/videos", "api_key = NULL, id, language = NA, append_to_response = NA", "id"),
  network = .tmdb_spec("network/{id}", "api_key = NULL, id", "id"),
  person_tmdb = .tmdb_spec("person/{id}", "api_key = NULL, id, append_to_response = NA", "id"),
  person_changes = .tmdb_spec("person/{id}/changes", "api_key = NULL, id, start_date = NA, end_date = NA", "id"),
  person_combined_credits = .tmdb_spec("person/{id}/combined_credits", "api_key = NULL, id, language = NA, append_to_response = NA", "id"),
  person_external_ids = .tmdb_spec("person/{id}/external_ids", "api_key = NULL, id", "id"),
  person_images = .tmdb_spec("person/{id}/images", "api_key = NULL, id", "id"),
  person_latest = .tmdb_spec("person/latest", "api_key = NULL, page = 1"),
  person_movie_credits = .tmdb_spec("person/{id}/movie_credits", "api_key = NULL, id, language = NA, append_to_response = NA", "id"),
  person_popular = .tmdb_spec("person/popular", "api_key = NULL, page = 1, language = NA"),
  person_tagged_images = .tmdb_spec("person/{id}/tagged_images", "api_key = NULL, id, page = 1, language = NA", "id"),
  person_tv_credits = .tmdb_spec("person/{id}/tv_credits", "api_key = NULL, id, language = NA, append_to_response = NA", "id"),
  review = .tmdb_spec("review/{id}", "api_key = NULL, id", "id"),
  search_collection = .tmdb_spec("search/collection", "api_key = NULL, query, page = 1, language = NA"),
  search_company = .tmdb_spec("search/company", "api_key = NULL, query, page = 1"),
  search_keyword = .tmdb_spec("search/keyword", "api_key = NULL, query, page = 1"),
  search_list = .tmdb_spec("search/collection", "api_key = NULL, query, page = 1, include_adult = NA"),
  search_movie = .tmdb_spec("search/movie", "api_key = NULL, query, page = 1, include_adult = NA, language = NA, year = NA, primary_release_year = NA, search_type = NA, region = NA"),
  search_multi = .tmdb_spec("search/multi", "api_key = NULL, query, page = 1, include_adult = NA, language = NA"),
  search_person = .tmdb_spec("search/person", "api_key = NULL, query, page = 1, include_adult = NA, search_type = NA, language = NA"),
  search_tv = .tmdb_spec("search/tv", "api_key = NULL, query, page = 1, language = NA, first_air_date_year = NA, search_type = NA, include_adult = NA"),
  timezone = .tmdb_spec("configuration/timezones", "api_key = NULL"),
  tv = .tmdb_spec("tv/{id}", "api_key = NULL, id, language = NA, append_to_response = NA", "id"),
  tv_airing_today = .tmdb_spec("tv/airing_today", "api_key = NULL, page = 1, language = NA, timezone = NA"),
  tv_alternative_title = .tmdb_spec("tv/{id}/alternative_titles", "api_key = NULL, id", "id"),
  tv_changes = .tmdb_spec("tv/{id}/changes", "api_key = NULL, id, start_date = NA, end_date = NA", "id"),
  tv_content_ratings = .tmdb_spec("tv/{id}/content_ratings", "api_key = NULL, id", "id"),
  tv_credits = .tmdb_spec("tv/{id}/credits", "api_key = NULL, id, append_to_response = NA", "id"),
  tv_episode = .tmdb_spec("tv/{id}/season/{season_number}/episode/{episode_number}", "api_key = NULL, id, season_number, episode_number, language = NA, append_to_response = NA", c("id", "season_number", "episode_number")),
  tv_episode_changes = .tmdb_spec("tv/episode/{id}/changes", "api_key = NULL, id, start_date = NA, end_date = NA", "id"),
  tv_episode_credits = .tmdb_spec("tv/{id}/season/{season_number}/episode/{episode_number}/credits", "api_key = NULL, id, season_number, episode_number", c("id", "season_number", "episode_number")),
  tv_episode_external_ids = .tmdb_spec("tv/{id}/season/{season_number}/episode/{episode_number}/external_ids", "api_key = NULL, id, season_number, episode_number, language = NA", c("id", "season_number", "episode_number")),
  tv_episode_images = .tmdb_spec("tv/{id}/season/{season_number}/episode/{episode_number}/images", "api_key = NULL, id, season_number, episode_number, language = NA, include_image_language = NA", c("id", "season_number", "episode_number")),
  tv_episode_videos = .tmdb_spec("tv/{id}/season/{season_number}/episode/{episode_number}/videos", "api_key = NULL, id, season_number, episode_number, language = NA", c("id", "season_number", "episode_number")),
  tv_external_ids = .tmdb_spec("tv/{id}/external_ids", "api_key = NULL, id, language = NA", "id"),
  tv_images = .tmdb_spec("tv/{id}/images", "api_key = NULL, id, language = NA, include_image_language = NA", "id"),
  tv_keywords = .tmdb_spec("tv/{id}/keywords", "api_key = NULL, id, append_to_response = NA", "id"),
  tv_latest = .tmdb_spec("tv/latest", "api_key = NULL"),
  tv_on_the_air = .tmdb_spec("tv/on_the_air", "api_key = NULL, page = 1, language = NA"),
  tv_popular = .tmdb_spec("tv/popular", "api_key = NULL, page = 1, language = NA"),
  tv_season = .tmdb_spec("tv/{id}/season/{season_number}", "api_key = NULL, id, season_number, language = NA, append_to_response = NA", c("id", "season_number")),
  tv_season_changes = .tmdb_spec("tv/season/{id}/changes", "api_key = NULL, id, start_date = NA, end_date = NA", "id"),
  tv_season_credits = .tmdb_spec("tv/{id}/season/{season_number}/credits", "api_key = NULL, id, season_number, language = NA", c("id", "season_number")),
  tv_season_external_ids = .tmdb_spec("tv/{id}/season/{season_number}/external_ids", "api_key = NULL, id, season_number, language = NA", c("id", "season_number")),
  tv_season_images = .tmdb_spec("tv/{id}/season/{season_number}/images", "api_key = NULL, id, season_number, language = NA, include_image_language = NA", c("id", "season_number")),
  tv_season_videos = .tmdb_spec("tv/{id}/season/{season_number}/videos", "api_key = NULL, id, season_number, language = NA", c("id", "season_number")),
  tv_similar = .tmdb_spec("tv/{id}/similar", "api_key = NULL, id, page = 1, language = NA, append_to_response = NA", "id"),
  tv_top_rated = .tmdb_spec("tv/top_rated", "api_key = NULL, page = 1, language = NA"),
  tv_translations = .tmdb_spec("tv/{id}/translations", "api_key = NULL, id", "id"),
  tv_videos = .tmdb_spec("tv/{id}/videos", "api_key = NULL, id, language = NA", "id")
)

.tmdb_paginated_names <- c(
  "changes_movie", "changes_person", "changes_tv", "company_movies",
  "discover_movie", "discover_tv", "genres_movies", "keyword_movies",
  "movie_changes", "movie_lists", "movie_now_playing", "movie_popular",
  "movie_reviews", "movie_similar", "movie_top_rated", "movie_upcoming",
  "person_changes", "person_popular", "person_tagged_images",
  "search_collection", "search_company", "search_keyword", "search_list",
  "search_movie", "search_multi", "search_person", "search_tv",
  "tv_airing_today", "tv_changes", "tv_episode_changes", "tv_on_the_air",
  "tv_popular", "tv_season_changes", "tv_similar", "tv_top_rated"
)

.tmdb_pagination_signature <- paste0(
  "paginate = FALSE, max_pages = 5L, max_results = 100L, ",
  "max_memory_mb = 100, simplify = TRUE, deduplicate_by = NULL, ",
  "progress = interactive(), delay = 0.05"
)

for (.tmdb_name in .tmdb_paginated_names) {
  signature <- .tmdb_legacy_specs[[.tmdb_name]]$signature
  if (!grepl("(^|, )page =", signature)) signature <- paste(signature, "page = 1", sep = ", ")
  .tmdb_legacy_specs[[.tmdb_name]]$signature <- paste(
    signature, .tmdb_pagination_signature, sep = ", "
  )
}
rm(.tmdb_name, .tmdb_pagination_signature)

for (.tmdb_name in names(.tmdb_legacy_specs)) {
  assign(
    .tmdb_name,
    .tmdb_make_legacy(.tmdb_name, .tmdb_legacy_specs[[.tmdb_name]]$signature),
    envir = environment()
  )
}
rm(.tmdb_name)
