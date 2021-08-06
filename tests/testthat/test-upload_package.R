test_that("Error trying to upload w/o authentication", {
    expect_error(
        upload_package(source_package, "jfrog_url", access_token = NA_character_),
        regexp = "No authentication credentials provided"
    )

    expect_error(
        upload_package(source_package, "jfrog_url", api_key = NA_character_),
        regexp = "No authentication credentials provided"
    )

    expect_error(
        upload_package(source_package, "jfrog_url", api_key = NA_character_, access_token = NA_character_),
        regexp = "No authentication credentials provided"
    )
})


httptest::use_mock_api()

test_that("Upload source package", {
    response <- jfrog::upload_package(source_package, jfrog_url = "https://HOSTNAME/artifactory/api/cran/cran-local", api_key = "api_key")

    expect_equal(httr::status_code(response), 201L)
})


test_that("Upload binary package", {
    response <- jfrog::upload_package(binary_package, jfrog_url = "https://HOSTNAME/artifactory/api/cran/cran-local", api_key = "api_key")

    expect_equal(httr::status_code(response), 201L)
})

httptest::stop_mocking()
