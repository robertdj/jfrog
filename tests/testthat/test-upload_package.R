test_that("Error trying to upload w/o authentication", {
    source_package <- create_empty_package("foo", "0.0.1", binary = FALSE, quiet = TRUE)
    withr::defer(unlink(source_package))

    expect_error(
        upload_package(source_package, "jfrog_url", api_key = NA_character_),
        regexp = "No authentication credentials provided"
    )
})
