# Migrating from TMDb 1.1

The package name is now `tmdbR`, but the 88 legacy read-only function names are
retained. Calls that passed an API key as the first argument continue to work.

Prefer setting `TMDB_BEARER_TOKEN` and omitting the first argument:

```r
# Before
movie(api_key, 550)

# Now
Sys.setenv(TMDB_BEARER_TOKEN = "your-token")
movie(id = 550)
```

## Endpoint changes

| Legacy function | Current implementation |
|---|---|
| `movie_releases()` | `/movie/{id}/release_dates` |
| `keyword_movies()` | `/discover/movie?with_keywords=...` |
| `company_movies()` | `/discover/movie?with_companies=...` |
| `genres_movies()` | `/discover/movie?with_genres=...` |
| `search_list()` | `/search/collection` |

`discover_movie()` and `discover_tv()` now expose watch-region, provider, and
monetisation filters. Additional current query parameters can be passed through
`...` where present.

The return value remains parsed JSON represented as R lists, data frames, and
atomic vectors. HTTP failures now raise errors containing TMDB's status code and
message instead of silently attempting to parse an error URL.
