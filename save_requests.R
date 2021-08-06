# To run this script make sure that:
# - The variable jfrog_url is set
# - The variable api_key is set
# - The variable access_token is set
#
# Note that this will upload the {jfrog} package to the JFrog CRAN.

source(here::here("tests", "testthat", "helper.R"))

library(httptest)
httptest::start_capturing(simplify = TRUE)

# source_package_archive <- pkgbuild::build(binary = FALSE)
source_package_archive <- create_empty_package("foo", "0.0.1", binary = FALSE, quiet = TRUE)
jfrog::upload_package(source_package_archive, jfrog_url, api_key = api_key)
# jfrog::upload_package(source_package_archive, jfrog_url, access_token = access_token)

# binary_package_archive <- pkgbuild::build(binary = TRUE)
binary_package_archive <- create_empty_package("foo", "0.0.1", binary = TRUE, quiet = TRUE)
jfrog::upload_package(binary_package_archive, jfrog_url, api_key = api_key)
# jfrog::upload_package(binary_package_archive, jfrog_url, access_token = access_token)

httptest::stop_capturing()


# Anonymise -----------------------------------------------------------------------------------

# Anonymize the requests by removing everything related to the particular domain.
# The function httptest::gsub_response is not suitable here because it only removes information in
# the URL and JFrog also includes part of the URL in a header

jfrog_url_parts <- httr::parse_url(jfrog_url)
jfrog_response_path_root <- fs::path(httptest::.mockPaths(), jfrog_url_parts$hostname)
jfrog_response_path <- fs::path(jfrog_response_path_root, jfrog_url_parts$path)
jfrog_response_files <- fs::dir_ls(path = jfrog_response_path, glob = "*.R")

domain <- strsplit(jfrog_url_parts$hostname, split = "\\.")[[1]][1]

jfrog_responses_as_text <- lapply(jfrog_response_files, readLines)
cleaned_responses_as_text <- jfrog_responses_as_text %>%
    purrr::map(~ gsub(jfrog_url_parts$hostname, "HOSTNAME", .)) %>%
    purrr::map(~ gsub(domain, "DOMAIN", .))

purrr::walk2(cleaned_responses_as_text, jfrog_response_files, writeLines)

new_path <- sub(jfrog_url_parts$hostname, "HOSTNAME", jfrog_response_path_root)
fs::file_move(jfrog_response_path_root, new_path)
