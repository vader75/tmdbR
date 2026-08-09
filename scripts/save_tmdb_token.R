# Save the long TMDB API Read Access Token as a bearer token in tmdbR's
# encrypted user cache. This is not the shorter TMDB v3 API key.
# Run this script once after installing the package.

library(tmdbR)

# tmdb_auth() creates a cached bearer token when needed and offers to keep or
# replace an existing one.
tmdb_auth()
