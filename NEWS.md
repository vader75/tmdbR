# tmdbR 0.2.2

- Added explicit authorship and provenance metadata.
- Documented that tmdbR is a modernised derivative of Andrea Capozio's
  Artistic-2.0-licensed `TMDb` 1.1 package, published on CRAN in March 2020.
- Prepared CRAN-safe package contents, executable examples, copyright
  metadata, repository links, and submission comments.

# tmdbR 0.2.1

- Added a prominent pagination note to package, pagination, and all eligible
  function help pages.
- Confirmed live that standard search, discover, and list endpoints normally
  return 20 records per full page, while global change feeds return 100.
- Documented that TMDB controls page size, final pages can be shorter, and no
  supported `page_size` or `limit` query parameter is available.
- Redesigned the package overview around quick start, authentication,
  task-oriented navigation, pagination safety, return values, and options.

# tmdbR 0.2.0

- Added opt-in automatic pagination directly to eligible result functions.
- Added safe defaults of five pages, 100 results, and 100 MB.
- Added start, per-page, and completion progress events.
- Added large-job warnings, memory-limit reporting, and truncation metadata.
- Added categorised help-index pages and individual function documentation.

# tmdbR 0.1.0

- Initial modern compatibility release for the TMDB v3 API.
