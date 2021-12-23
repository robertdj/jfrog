source_package <- create_empty_package("foo", "0.0.1", binary = FALSE, quiet = TRUE)
withr::defer(unlink(source_package))

test_that("Error trying to upload w/o authentication", {
    expect_error(
        upload_package(source_package, "jfrog_url", api_key = NA_character_, access_token = NA_character_),
        regexp = "No authentication credentials provided"
    )
})


test_that("Error with malformed URL", {
    expect_error(
        upload_package(source_package, "jfrog_url", api_key = "api_key"),
        regexp = "JFrog CRAN URL must contain scheme, hostname and path"
    )
})


test_that("Error with URL with wrong path", {
    expect_error(
        upload_package(source_package, "https://HOSTNAME.jfrog.io/foo", api_key = "api_key"),
        regexp = "CRAN URL does not contain 'artifactory' path"
    )
})


httptest::use_mock_api()

test_that("Upload source package", {
    response <- upload_package(source_package, jfrog_url = "https://HOSTNAME/artifactory/api/cran/cran-local", api_key = "api_key")

    expect_equal(httr::status_code(response), 201L)
})


test_that("Upload binary package", {
    binary_package <- create_empty_package("foo", "0.0.1", binary = TRUE, quiet = TRUE)
    withr::defer(unlink(binary_package))

    response <- upload_package(binary_package, jfrog_url = "https://HOSTNAME/artifactory/api/cran/cran-local", api_key = "api_key")

    expect_equal(httr::status_code(response), 201L)
})

httptest::stop_mocking()
