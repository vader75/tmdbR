# Install the packages required by the MCU actor-network exercise.
# Run this script once from the tmdb_api_package folder.

# igraph is published on CRAN.
if (!requireNamespace("igraph", quietly = TRUE)) {
  install.packages("igraph")
}

# tmdbR is supplied as a local source package and is not published on CRAN.
local_tmdb_package <- "tmdbR_0.2.0.tar.gz"

if (!file.exists(local_tmdb_package)) {
  stop(
    "Cannot find ", local_tmdb_package,
    ". Set the working directory to the tmdb_api_package folder."
  )
}

install.packages(
  local_tmdb_package,
  repos = NULL,
  type = "source"
)

message("tmdbR and igraph are ready to use.")
