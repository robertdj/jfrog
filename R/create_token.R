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
#' @return A parsed response from the token endpoint.
#'
#' @export
create_token <- function(jfrog_url, expires_in = 2 * 60, access_token = jfrog_access_token())
{
    assertthat::assert_that(
        assertthat::is.count(expires_in)
    )

    response <- httr::POST(
        url = paste0(jfrog_url, "/access/api/v1/tokens"),
        httr::add_headers("Authorization" = paste("Bearer", access_token)),
        httr::content_type_json(),
        query = list(
            expires_in = expires_in
        )
    )

    httr::stop_for_status(response)

    httr::content(response, as = "parsed")
}
