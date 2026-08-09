# MCU actor collaboration network using tmdbR
#
# Before running:
#   1. Run scripts/install_tmdbR.R once to install the required packages.
#   2. Set R's working directory to the tmdb_api_package folder.

# tmdbR communicates with TMDB; igraph creates and analyses the network.
library(tmdbR)
library(igraph)

# tmdb_auth() stores the long TMDB API Read Access Token as a bearer token. It
# does not store the shorter v3 API key. If a cached bearer token already exists,
# the function offers to keep or replace it.
tmdb_auth()

# -----------------------------------------------------------------------------
# 1. Find the MCU keyword, then retrieve movies tagged with it
# -----------------------------------------------------------------------------

# Step 1: Search TMDB for its MCU keyword. Keywords are subject labels attached
# to movies. This gives better results than searching only for movie titles.
keyword_results <- search_keyword(
  query = "Marvel Cinematic Universe"
)$results

# Select the MCU keyword and store its TMDB ID. Movie searches use the ID rather
# than the written keyword name.
mcu_keyword <- keyword_results[
  keyword_results$name == "marvel cinematic universe (mcu)",
]
mcu_keyword_id <- mcu_keyword$id

# Step 2: Retrieve all movies carrying that keyword. paginate = TRUE requests
# additional pages, while max_results = Inf avoids assuming a fixed result count.
mcu_movie_search <- keyword_movies(
  id = mcu_keyword_id,
  language = "en-AU",
  include_adult = FALSE,
  paginate = TRUE,
  max_pages = Inf,
  max_results = Inf,
  deduplicate_by = "id",
  progress = TRUE
)

# Extract the combined results and retain only the columns needed later.
movies <- mcu_movie_search$results[c("id", "title", "release_date")]

# Convert the release dates from text to R Date values.
movies$release_date <- as.Date(movies$release_date)

# Keep movies that have already been released.
movies <- subset(
  movies,
  !is.na(release_date) & release_date <= Sys.Date()
)

# Give the ID column a clearer name and reset the displayed row numbers.
names(movies)[names(movies) == "id"] <- "movie_id"
rownames(movies) <- NULL
print(movies)

# -----------------------------------------------------------------------------
# 2. Retrieve the actors for each movie
# -----------------------------------------------------------------------------

# Input: one TMDB movie ID.
# Output: a data frame containing that movie ID, each actor ID, and actor name.
get_movie_cast <- function(movie_id) {
  # Request the movie's credits, then select only the cast section. The credits
  # response also contains crew members, which are not needed for this network.
  credits <- movie_credits(id = movie_id)
  cast <- credits$cast

  # Some movies have no cast information. Return NULL so this movie contributes
  # no rows when the results are combined later.
  if (!is.data.frame(cast) || nrow(cast) == 0) {
    return(NULL)
  }

  # Build a simpler table containing only the fields needed for the network.
  # Actor IDs identify graph nodes reliably because two actors may share a name.
  movie_cast <- data.frame(
    movie_id = movie_id,
    actor_id = as.character(cast$id),
    actor_name = cast$name
  )

  # Remove repeated credits for the same actor in the same movie. The final line
  # returns the rows that are not duplicates.
  duplicate_actor <- duplicated(movie_cast[c("movie_id", "actor_id")])
  movie_cast[!duplicate_actor, ]
}

# Call the function once for each movie. lapply() stores the returned data
# frames in a list, and do.call(rbind, ...) combines them into one table.
cast_by_movie <- lapply(movies$movie_id, get_movie_cast)

# Stack the individual movie-cast tables into one long data frame. Resetting the
# row names gives the combined table a clean sequence of displayed row numbers.
cast_movies <- do.call(rbind, cast_by_movie)
rownames(cast_movies) <- NULL

# Stop early if none of the selected movies supplied usable cast information.
if (nrow(cast_movies) == 0) {
  stop("No cast data were returned for the selected movies.")
}

# -----------------------------------------------------------------------------
# 3. Count the movies shared by each pair of actors
# -----------------------------------------------------------------------------

# Only IDs are needed to create the edges. Leaving actor names out of this large
# join reduces memory use and keeps the resulting columns easier to understand.
movie_cast_ids <- cast_movies[c("movie_id", "actor_id")]

# Join the ID table to itself using movie_id. For each movie, every actor is
# matched with every other actor from that same movie.
actor_pairs <- merge(
  movie_cast_ids,
  movie_cast_ids,
  by = "movie_id",
  suffixes = c("_from", "_to")
)

# The self-join initially includes unwanted rows:
#   actor A -- actor A  (an actor paired with themselves)
#   actor A -- actor B  and actor B -- actor A (the same pair twice)
# The comparison below keeps a row only when actor_id_from comes before
# actor_id_to. For example, A < B keeps A--B but removes B--A. It also removes
# A--A because A is not less than itself. This leaves exactly one row for each
# actor pair in each movie. Actor IDs are used because different actors can
# have the same name.
actor_pairs <- actor_pairs[
  actor_pairs$actor_id_from < actor_pairs$actor_id_to,
  c("movie_id", "actor_id_from", "actor_id_to")
]

# Each remaining row means that two actors shared one movie. Count the rows for
# each pair. The result becomes the edge weight: weight 1 means one shared
# movie, while weight 3 means three shared movies.
edges <- aggregate(
  movie_id ~ actor_id_from + actor_id_to,
  data = actor_pairs,
  FUN = length
)

# igraph expects the edge endpoints to be named "from" and "to".
names(edges) <- c("from", "to", "weight")

# Create one vertex record per unique TMDB actor ID. The ID remains the graph's
# unique identifier because two different actors could have the same name.
actors <- cast_movies[!duplicated(cast_movies$actor_id),
                      c("actor_id", "actor_name")]

# igraph requires its unique vertex identifier to be stored in a column named
# "name". Here, that identifier is the TMDB actor ID.
vertices <- data.frame(
  name = actors$actor_id
)

# This is the COMPLETE graph. It contains every actor and every edge with at
# least one shared movie. Use this object for centrality calculations.
complete_actor_network <- graph_from_data_frame(
  d = edges,
  directed = FALSE,
  vertices = vertices
)

# Retrofit readable names onto the graph nodes. match() finds where each graph
# vertex ID occurs in the actors table, then uses that row's actor name.
actor_name_position <- match(
  V(complete_actor_network)$name,
  actors$actor_id
)

# Add the matched readable actor names as an attribute on the graph vertices.
V(complete_actor_network)$actor_name <- actors$actor_name[actor_name_position]

# -----------------------------------------------------------------------------
# 4. Inspect and plot the network
# -----------------------------------------------------------------------------

# Report the size of the complete graph before applying plotting filters.
message("Complete graph nodes: ", vcount(complete_actor_network))
message("Complete graph edges: ", ecount(complete_actor_network))

# Fix the random seed so the graph layout is repeatable between runs.
set.seed(3020)

# Plotting rules affect only the filtered view. The complete graph remains
# unchanged and available for centrality analysis.
minimum_common_movies <- 4L
maximum_actors_to_plot <- 30L

# Keep only edges that meet the shared-movie threshold. delete.vertices = TRUE
# also removes actors who have no remaining edges. The complete graph is not
# changed because the result is stored in the separate plot_network object.
qualifying_edges <- E(complete_actor_network)[weight >= minimum_common_movies]
plot_network <- subgraph_from_edges(
  complete_actor_network,
  eids = qualifying_edges,
  delete.vertices = TRUE
)

# A very high threshold could remove every edge and vertex.
if (vcount(plot_network) == 0) {
  stop("No links meet minimum_common_movies = ", minimum_common_movies)
}

# Weighted strength is the sum of an actor's shared-movie edge weights. Sort
# these values and keep only the requested number of strongest actors.
actor_strength <- strength(plot_network, weights = E(plot_network)$weight)
strength_ranking <- sort(actor_strength, decreasing = TRUE)
top_actor_ids <- head(names(strength_ranking), maximum_actors_to_plot)

# Build the final plotted graph using only the selected actor IDs.
plot_network <- induced_subgraph(plot_network, vids = top_actor_ids)

# Draw a simple version of the filtered graph. Students can later customise
# properties such as layout, colours, node sizes, labels, and edge widths.
# Make each rectangle wide enough for its actor-name label.
actor_label_width <- 4 + (2.5 * nchar(V(plot_network)$actor_name))

# The Kamada-Kawai layout spreads connected vertices across the plotting area.
# Edge width remains proportional to the number of shared movies.
plot(
  plot_network,
  layout = layout_with_kk(plot_network),
  vertex.label = V(plot_network)$actor_name,
  vertex.shape = "rectangle",
  vertex.size = actor_label_width,
  vertex.size2 = 10,
  vertex.color = "steelblue4",
  vertex.label.color = "white",
  vertex.label.cex = 0.55,
  edge.color = "grey70",
  edge.width = E(plot_network)$weight / minimum_common_movies,
  main = "Filtered MCU actor network"
)

# -----------------------------------------------------------------------------
# 5. Calculate centrality measures using the complete graph
# -----------------------------------------------------------------------------

# Degree counts direct neighbours. Betweenness counts shortest paths that pass
# through an actor. Closeness measures how near an actor is to all other actors.
# weights = NA treats every edge as one connection because the edge weights in
# this graph describe connection strength rather than path distance.
centrality_measures <- data.frame(
  actor_id = V(complete_actor_network)$name,
  actor_name = V(complete_actor_network)$actor_name,
  degree = degree(complete_actor_network),
  betweenness = betweenness(
    complete_actor_network,
    directed = FALSE,
    weights = NA
  ),
  closeness = closeness(
    complete_actor_network,
    weights = NA,
    normalized = TRUE
  )
)

# Sort by degree and print the 20 actors with the most direct neighbours.
top_degree <- head(
  centrality_measures[order(-centrality_measures$degree), ],
  20
)
message("Top 20 actors by degree centrality:")
print(top_degree, row.names = FALSE)

# Sort by betweenness and print the 20 strongest network bridges.
top_betweenness <- head(
  centrality_measures[order(-centrality_measures$betweenness), ],
  20
)
message("Top 20 actors by betweenness centrality:")
print(top_betweenness, row.names = FALSE)

# Sort by closeness and print the 20 actors nearest to the rest of the network.
top_closeness <- head(
  centrality_measures[order(-centrality_measures$closeness), ],
  20
)
message("Top 20 actors by closeness centrality:")
print(top_closeness, row.names = FALSE)

# Optional: save the complete graph so it can be loaded in another R session.
# saveRDS(complete_actor_network, "complete_actor_network.rds")

# Optional: save the tables for later analysis.
# write.csv(movies, "mcu_movies.csv", row.names = FALSE)
# write.csv(cast_movies, "mcu_movie_cast.csv", row.names = FALSE)
# write.csv(edges, "mcu_actor_edges.csv", row.names = FALSE)
