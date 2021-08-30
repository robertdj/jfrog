httptest::use_mock_api()

# Calls should match those in "save_requests.R" with HOSTNAME instead of the actual URL

test_that("Error trying to create token w/o authentication", {
    expect_error(
        create_token(jfrog_url = "https://HOSTNAME", expires_in = 61, access_token = "access_token"),
        class = "http_401"
    )
})


test_that("Get new token", {
    token <- create_token(jfrog_url = "https://HOSTNAME", expires_in = 60)

    expect_named(
        token,
        c("token_id", "access_token", "expires_in", "scope", "token_type")
    )
})

httptest::stop_mocking()
