suppressPackageStartupMessages(library(tmdbR))

out_dir <- "tmp/pdfs/student_guide_v2/assets"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

response <- movie_popular(
  region = "AU",
  language = "en-AU",
  paginate = TRUE,
  max_pages = 5,
  max_results = 100,
  deduplicate_by = "id",
  progress = FALSE
)

movies <- response$results
movies$release_date <- as.Date(movies$release_date)
movies$release_year <- as.integer(format(movies$release_date, "%Y"))
movies <- movies[
  is.finite(movies$vote_average) &
    is.finite(movies$vote_count) & movies$vote_count > 0,
]

stats <- data.frame(
  metric = c(
    "Movies analysed", "Mean rating", "Median rating", "Rating SD",
    "Rating IQR", "Minimum rating", "Maximum rating",
    "Correlation: rating and log10(vote count)", "Pages fetched"
  ),
  value = c(
    nrow(movies),
    round(mean(movies$vote_average), 2),
    round(median(movies$vote_average), 2),
    round(sd(movies$vote_average), 2),
    round(IQR(movies$vote_average), 2),
    round(min(movies$vote_average), 2),
    round(max(movies$vote_average), 2),
    round(cor(movies$vote_average, log10(movies$vote_count)), 2),
    response$pages_fetched
  )
)
write.csv(stats, file.path(out_dir, "stats_summary.csv"), row.names = FALSE)

png(file.path(out_dir, "rating_histogram.png"), width = 1500, height = 850, res = 160)
par(mar = c(4.5, 4.8, 1.5, 1), family = "sans", bg = "white")
h <- hist(
  movies$vote_average,
  breaks = seq(floor(min(movies$vote_average)), ceiling(max(movies$vote_average)), by = 0.5),
  col = "#2FC7C9", border = "white",
  xlab = "TMDB vote average", ylab = "Number of movies",
  main = "", axes = FALSE
)
axis(1, col.axis = "#173042", col = "#8AA0AA")
axis(2, las = 1, col.axis = "#173042", col = "#8AA0AA")
abline(v = mean(movies$vote_average), col = "#EF8354", lwd = 3)
abline(v = median(movies$vote_average), col = "#173042", lwd = 3, lty = 2)
legend(
  "topleft", bty = "n", horiz = TRUE,
  legend = c("Mean", "Median"), col = c("#EF8354", "#173042"),
  lwd = 3, lty = c(1, 2), cex = 0.9
)
box(bty = "l", col = "#8AA0AA")
dev.off()

png(file.path(out_dir, "rating_votes_scatter.png"), width = 1500, height = 850, res = 160)
par(mar = c(4.5, 4.8, 1.5, 1), family = "sans", bg = "white")
x <- log10(movies$vote_count)
y <- movies$vote_average
plot(
  x, y, pch = 21, bg = "#2FC7C9AA", col = "white", cex = 1.35,
  xlab = "log10(number of TMDB votes)", ylab = "TMDB vote average",
  main = "", axes = FALSE
)
axis(1, col.axis = "#173042", col = "#8AA0AA")
axis(2, las = 1, col.axis = "#173042", col = "#8AA0AA")
abline(lm(y ~ x), col = "#EF8354", lwd = 3)
box(bty = "l", col = "#8AA0AA")
dev.off()

write.csv(
  movies[c("id", "title", "release_date", "release_year", "vote_average", "vote_count", "popularity")],
  file.path(out_dir, "popular_movies_sample.csv"),
  row.names = FALSE
)

# A compact first-year chi-square example. Three historically interpretable
# release eras and the 7.5 rating threshold are declared before testing. A
# minimum of 50 votes avoids classifying movies from only a handful of ratings.
chi_movies <- movies[
  movies$vote_count >= 50 & !is.na(movies$release_year),
]
chi_movies$release_period <- cut(
  chi_movies$release_year,
  breaks = c(-Inf, 2009, 2019, Inf),
  labels = c("Before 2010", "2010-2019", "2020 or later")
)
chi_movies$rating_category <- ifelse(
  chi_movies$vote_average >= 7.5,
  "7.5 or higher",
  "Below 7.5"
)

chi_table <- table(chi_movies$release_period, chi_movies$rating_category)
chi_test <- chisq.test(chi_table)

chi_summary <- data.frame(
  metric = c("Movies analysed", "Chi-square", "Degrees of freedom", "p-value", "Minimum expected count"),
  value = c(
    nrow(chi_movies), round(unname(chi_test$statistic), 3),
    unname(chi_test$parameter), round(chi_test$p.value, 4),
    round(min(chi_test$expected), 2)
  )
)
write.csv(chi_summary, file.path(out_dir, "chi_square_summary.csv"), row.names = FALSE)

chi_cells <- expand.grid(
  release_period = rownames(chi_table),
  rating_category = colnames(chi_table),
  stringsAsFactors = FALSE
)
chi_cells$observed <- as.vector(chi_table)
chi_cells$expected <- as.vector(chi_test$expected)
write.csv(chi_cells, file.path(out_dir, "chi_square_cells.csv"), row.names = FALSE)

png(file.path(out_dir, "chi_square_bars.png"), width = 1500, height = 850, res = 160)
par(mar = c(4.2, 4.8, 1.2, 1), family = "sans", bg = "white")
proportions <- prop.table(chi_table, margin = 1)
barplot(
  t(proportions),
  col = c("#2FC7C9", "#173042"), border = NA,
  ylab = "Proportion within release era", xlab = "Release era",
  ylim = c(0, 1), axes = FALSE, axisnames = TRUE,
  names.arg = rownames(chi_table), main = ""
)
axis(2, at = seq(0, 1, 0.2), labels = paste0(seq(0, 100, 20), "%"),
     las = 1, col.axis = "#173042", col = "#8AA0AA")
legend(
  "topright", inset = 0.02, bty = "o", bg = "white",
  box.col = "#8AA0AA", text.col = "#173042",
  legend = colnames(chi_table),
  fill = c("#2FC7C9", "#173042"), cex = 1.15
)
box(bty = "l", col = "#8AA0AA")
dev.off()

message("Created first-year statistics assets from ", nrow(movies), " popular movies.")
