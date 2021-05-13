test_that("Get API key when present", {
    api_key <- withr::with_envvar(
        new = c("JFROG_API_KEY" = "foo"),
        jfrog_api()
    )

    expect_equal(api_key, "foo")
})


test_that("Message when API key is not present", {
    api_key <- expect_message(
        withr::with_envvar(
            new = c("JFROG_API_KEY" = NA_character_),
            jfrog_api(quiet = FALSE)
        ),
        "JFrog API Key is not available"
    )

    expect_equal(api_key, NA_character_)
})
