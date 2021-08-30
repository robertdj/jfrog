test_that("Get API key when present", {
    api_key <- withr::with_envvar(
        new = c("JFROG_API_KEY" = "api_key"),
        jfrog_api_key()
    )

    expect_equal(api_key, "api_key")
})


test_that("Message when API key is not present", {
    api_key <- expect_message(
        withr::with_envvar(
            new = c("JFROG_API_KEY" = NA_character_),
            jfrog_api_key(quiet = FALSE)
        ),
        "JFrog API Key is not available"
    )

    expect_equal(api_key, NA_character_)
})
