#' Create new access token
#'
#' Get a token from the endpoint "access/api/v1/tokens" per [JFrog's documentation](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#ArtifactoryRESTAPI-AccessTokens).
#' Note that the documentation for "expiry" parameter is *wrong* at the time of writing.
#'
#' @details A token can only be created using already existing tokens.
#' A usecase is to have a long-lived token to generate more transient token used for authentication as part of e.g. test pipelines.
#'
#' @param jfrog_url Base URL of the JFrog domain.
#' @param expires_in The life span of the token in seconds. Defaults to 2 minutes.
#' @param access_token A valid token.
#'
#' @return A parsed response from the token endpoint, which is a list with entries "token_id", "access_token", "expires_in", "scope", "token_type".
#'
#' @export
create_token <- function(jfrog_url, expires_in = 2 * 60, access_token = jfrog_access_token())
{
    response <- download_token(jfrog_url, expires_in, access_token)
    httr::stop_for_status(response)

    httr::content(response, as = "parsed")
}


download_token <- function(jfrog_url, expires_in, access_token)
{
    assertthat::assert_that(
        assertthat::is.count(expires_in),
        expires_in > 0,
        assertthat::is.string(access_token)
    )

    httr::POST(
        url = paste0(jfrog_url, "/access/api/v1/tokens"),
        httr::add_headers("Authorization" = paste("Bearer", access_token)),
        httr::content_type("application/x-www-form-urlencoded"),
        httr::accept_json(),
        body = list(
            expires_in = expires_in
        ),
        encode = "form"
    )
}
