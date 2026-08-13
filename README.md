# tmdbR

`tmdbR` is a modern R client for the TMDB v3 API and a compatibility successor
to Andrea Capozio's legacy [`TMDb` 1.1 package](https://CRAN.R-project.org/package=TMDb),
published on 16 March 2020 and licensed under the Artistic License 2.0. This
package retains and modernises its compatibility interface; it is not an
official update by the original author.

## Installation

Install the released package from CRAN:

```r
install.packages("tmdbR")
```

Alternatively, install a locally built source package from a shell:

```sh
R CMD INSTALL tmdbR_0.2.2.tar.gz
```

Or from R:

```r
install.packages("tmdbR_0.2.2.tar.gz", repos = NULL, type = "source")
```

## Authentication

Prefer caching the API Read Access Token outside scripts:

```r
library(tmdbR)
tmdb_auth() # prompts once and saves an encrypted user-cache file
movie(id = 550)
```

View or remove the cache without displaying the token:

```r
tmdb_token_path()
tmdb_forget_token()
```

A session environment variable also works:

```r
Sys.setenv(TMDB_BEARER_TOKEN = "your-token")
library(tmdbR)
movie(id = 550)
```

The v3 API key remains supported:

```r
Sys.setenv(TMDB_API_KEY = "your-key")
search_movie(query = "Spirited Away")
```

Never commit either credential. Explicit `api_key` arguments continue to work
for compatibility with `TMDb` 1.1.

Credentials are resolved in this order: explicit request credentials,
`TMDB_BEARER_TOKEN`, `TMDB_API_KEY`, then the encrypted token cache. Bearer
authentication is preferred when both explicit bearer and API-key values are
available.

## Common workflows

Search, inspect details, and append related data in one request:

```r
hits <- search_movie(query = "Spirited Away", language = "en-AU")
film <- movie(id = hits$results$id[[1]], append_to_response = "credits,videos")
```

Browse paginated results:

```r
page_two <- movie_popular(page = 2, region = "AU")
page_two$page
page_two$total_pages
page_two$results
```

Discover titles available from selected streaming providers:

```r
available <- discover_movie(
  watch_region = "AU",
  with_watch_providers = c(8, 9),
  with_watch_monetization_types = "flatrate",
  sort_by = "popularity.desc"
)
```

Query TV, people, images, and recent changes:

```r
series <- tv(id = 1399, append_to_response = "credits,videos")
actor <- person_tmdb(id = 287, append_to_response = "combined_credits")
artwork <- movie_images(id = 550, include_image_language = c("en", "null"))
changed <- changes_movie(
  start_date = as.character(Sys.Date() - 6),
  end_date = as.character(Sys.Date())
)
```

## Generic requests

Endpoints not covered by a convenience wrapper can be queried directly:

```r
tmdb_request("trending/movie/week", query = list(language = "en-AU"))
```

Use `tmdb_config()` for non-default timeouts or retry attempts:

```r
cfg <- tmdb_config(timeout = 30, max_tries = 5)
tmdb_request("movie/550", config = cfg)
```

`tmdb_request()` retries HTTP 429 and transient server failures, then reports
TMDB's status code and message as an R error.

## Automatic pagination

Single-page wrappers remain unchanged. Use `tmdb_paginate()` to collect pages
from an existing wrapper:

```r
films <- tmdb_paginate(
  search_movie,
  query = "Star Wars",
  max_pages = 5,
  max_results = 75,
  deduplicate_by = "id"
)

films$results
films$pages_fetched
films$truncated
```

Use `tmdb_request_all()` for a generic paginated endpoint:

```r
sci_fi <- tmdb_request_all(
  "discover/movie",
  query = list(with_genres = 878, sort_by = "popularity.desc"),
  max_pages = 3
)
```

Eligible result functions can paginate directly:

```r
popular <- movie_popular(
  region = "AU",
  paginate = TRUE,
  max_pages = 5,
  max_results = 100,
  progress = TRUE
)
```

Pagination is opt-in. Safe defaults limit retrieval to five pages, 100 results,
and approximately 100 MB. Set `max_pages = Inf`, `max_results = Inf`, or
`max_memory_mb = Inf` explicitly to remove a limit. Requests are sequential
with a short delay and retain retry and HTTP 429 handling. Interactive calls
report the planned work, each completed page, and whether the final result was
complete or truncated. Use `simplify = FALSE` for heterogeneous fields.

**Important:** TMDB controls page size. Standard search, discover, and list
endpoints currently return up to 20 records per full page, while global movie,
TV, and person change feeds currently return up to 100. Final pages can be
shorter, and TMDB does not document a supported page-size parameter. The
package counts actual results and follows `total_pages`; it does not hardcode a
page size.

## Migrating from TMDb 1.1

Existing calls can generally be retained; the first `api_key` argument is now
optional when an environment credential is configured. Important remappings:

- `movie_releases()` uses `/release_dates`.
- `keyword_movies()`, `company_movies()`, and `genres_movies()` use supported
  `/discover/movie` filters.
- `search_list()` uses collection search because the old list-search endpoint
  is no longer part of the current v3 reference.
- Extra supported filters can be supplied through `...` on discover-based
  compatibility functions.

See `help(package = "tmdbR")`, `help(tmdb_request)`, and the category index pages
`help(tmdb_movies)`, `help(tmdb_tv)`, `help(tmdb_people)`, and
`help(tmdb_search)`.

## Testing

```sh
Rscript -e 'testthat::test_local()'
R CMD build .
R CMD check --as-cran tmdbR_0.2.2.tar.gz
```

Live smoke tests are skipped unless `TMDB_LIVE_TESTS=true` and a credential is
available.

Report problems at the [tmdbR issue tracker](https://github.com/vader75/tmdbR/issues).

This product uses the TMDB API but is not endorsed or certified by TMDB. See
the [TMDB API documentation](https://developer.themoviedb.org/docs/getting-started)
and comply with TMDB's attribution and terms requirements in downstream apps.
