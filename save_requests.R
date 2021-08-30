# To run this script make sure that:
# - The variables jfrog_url and jfrog_cran_url are set
# - The variable api_key is set, e.g. with
# api_key <- jfrog::jfrog_api()
# - The variable access_token is set, e.g. with
# access_token <- jfrog::jfrog_access_token()
#
# Note that this will upload the generated package to the JFrog CRAN.

source(here::here("tests", "testthat", "helper.R"))

library(httptest)
httptest::start_capturing(simplify = TRUE)

source_package_archive <- create_empty_package("foo", "0.0.1", binary = FALSE, quiet = TRUE)
jfrog::upload_package(source_package_archive, jfrog_cran_url, api_key = api_key)

binary_package_archive <- create_empty_package("foo", "0.0.1", binary = TRUE, quiet = TRUE)
jfrog::upload_package(binary_package_archive, jfrog_cran_url, api_key = api_key)

# Different "expires_in" to distinguish between the saved requests
jfrog::create_token(jfrog_url, expires_in = 60, access_token = access_token)
jfrog::create_token(jfrog_url, expires_in = 61, access_token = "access_token")

httptest::stop_capturing()


# Anonymise -----------------------------------------------------------------------------------

# Anonymize the requests by removing everything related to the particular domain.
# The function httptest::gsub_response is not suitable here because it only removes information in
# the URL and JFrog also includes part of the URL in a header

jfrog_url_parts <- httr::parse_url(jfrog_url)
jfrog_response_path_root <- fs::path(httptest::.mockPaths(), jfrog_url_parts$hostname)
jfrog_response_path <- fs::path(jfrog_response_path_root, jfrog_url_parts$path)
jfrog_response_files <- fs::dir_ls(path = jfrog_response_path, glob = "*.R", recurse = TRUE)

domain <- strsplit(jfrog_url_parts$hostname, split = "\\.")[[1]][1]

jfrog_responses_as_text <- lapply(jfrog_response_files, readLines)
cleaned_responses_as_text <- jfrog_responses_as_text %>%
    purrr::map(~ gsub(jfrog_url_parts$hostname, "HOSTNAME", .)) %>%
    purrr::map(~ gsub(domain, "DOMAIN", .))

purrr::walk2(cleaned_responses_as_text, jfrog_response_files, writeLines)

new_path <- sub(jfrog_url_parts$hostname, "HOSTNAME", jfrog_response_files)
fs::dir_create(unique(dirname(new_path)))
fs::file_copy(jfrog_response_files, new_path, overwrite = TRUE)


# Move JSON files

json_response_files <- fs::dir_ls(path = jfrog_response_path, glob = "*.json", recurse = TRUE)

new_path_json_path <- sub(jfrog_url_parts$hostname, "HOSTNAME", json_response_files)
fs::dir_create(unique(dirname(new_path_json_path)))
fs::file_copy(json_response_files, new_path_json_path, overwrite = TRUE)


# Remove relevant values from token

token_file <- fs::dir_ls(path = fs::path("tests", "testthat", "HOSTNAME"), regexp = "tokens.*\\.json", recurse = TRUE)
token <- jsonlite::fromJSON(token_file)

token$token_id <- "<token id>"
token$access_token <- "<access token>"

jsonlite::toJSON(token, auto_unbox = TRUE, pretty = TRUE) %>%
    writeLines(con = token_file)

# fs::dir_delete(jfrog_response_path)
