#' Upload package archive to JFrog
#'
#' JFrog allows different ways of authentication as noted in [JFrog's documentation](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API).
#' Here we rely on an [API Key](https://www.jfrog.com/confluence/display/JFROG/User+Profile#UserProfile-APIKey) for a dedicated header or an [access token](https://www.jfrog.com/confluence/display/JFROG/Access+Tokens) in an authorization header.
#'
#' If both `api_key` and `access_token` are supplied then `access_token` is used.
#' The rationale is that this is the desired behavior in CI pipelines.
#'
#' @param package_archive Path to `tar.gz`, `zip` or `tgz` archive.
#' @param jfrog_url URL
#' @param api_key JFrog API Key.
#' @param access_token JFrog access token.
#'
#' @return Response from [httr::POST()].
#'
#' @export
upload_package <- function(package_archive, jfrog_url, api_key = jfrog_pat(), access_token = NULL) {
    cran_suffix <- make_cran_suffix(package_archive)

    full_url <- paste0(jfrog_url, "/", cran_suffix)

    at_available <- FALSE
    if (is.character(access_token) && nzchar(access_token, keepNA = FALSE)) {
        at_available <- TRUE
        auth_header <- httr::add_headers("Authorization" = paste("Bearer", access_token))
    }

    if (isFALSE(at_available) && is.character(api_key) && nzchar(api_key, keepNA = FALSE))
        auth_header <- httr::add_headers("X-JFrog-Art-Api" = api_key)

    response <- httr::POST(
        url = full_url,
        config = auth_header,
        body = httr::upload_file(package_archive)
    )

    return(response)
}


make_cran_suffix <- function(package_archive) {
    if (package_ext(package_archive) == "tar.gz") {
        cran_suffix <- "sources"
    } else {
        r_version <- pkg.peek::get_r_version(package_archive)
        version_for_cran <- paste0(r_version$major, ".", r_version$minor)

        if (package_ext(package_archive) == "zip") {
            os <- "windows"
        } else if (package_ext(package_archive) == "tgz") {
            os <- "macosx"
        }

        cran_suffix <- paste0("binaries?distribution=", os, "&rVersion=", version_for_cran)
    }

    return(cran_suffix)
}
