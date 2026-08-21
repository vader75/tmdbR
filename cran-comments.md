## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Additional information

* Network-dependent tests are skipped unless explicitly enabled by the user.
* The package is a separately named, substantially modernised derivative of
  Andrea Capozio's Artistic-2.0-licensed `TMDb` 1.1 package. Original
  authorship and copyright are recorded in `DESCRIPTION` and `inst/NOTICE`.

## Resubmission

This resubmission addresses the review by Leonore Hochhauser:

* Software, package, and API names in the `Title` and `Description` fields are
  now enclosed in single quotes with their case preserved.
* Token-cache writing functions no longer select a file path by default. Users
  must supply `path` or explicitly configure one through an option or
  environment variable.
* All examples and vignette code that writes a token use `tempdir()`.
