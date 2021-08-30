test_that("Get access token when present", {
    token <- withr::with_envvar(
        new = c("JFROG_ACCESS_TOKEN" = "token"),
        jfrog_access_token()
    )

    expect_equal(token, "token")
})


test_that("Message when access token is not present", {
    token <- expect_message(
        withr::with_envvar(
            new = c("JFROG_ACCESS_TOKEN" = NA_character_),
            jfrog_access_token(quiet = FALSE)
        ),
        "JFrog access token is not available"
    )

    expect_equal(token, NA_character_)
})

