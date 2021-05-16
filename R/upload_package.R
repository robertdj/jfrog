#' Upload package archive to JFrog
#'
#' JFrog allows different ways of authentication as noted in [JFrog's documentation](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API).
#' Here we rely on an [API Key](https://www.jfrog.com/confluence/display/JFROG/User+Profile#UserProfile-APIKey) for a dedicated header or an [access token](https://www.jfrog.com/confluence/display/JFROG/Access+Tokens) in an authorization header.
#'
#' If both `api_key` and `access_token` are supplied then `access_token` is used.
#' The rationale is that this is the desired behavior in CI pipelines.
#'
#' @param package_archive Path to `tar.gz`, `zip` or `tgz` archive.
#' @param jfrog_url Base URL of the JFrog CRAN.
#' @param api_key JFrog API Key.
#' @param access_token JFrog access token.
#'
#' @return Response from [httr::POST()].
#'
#' @export
upload_package <- function(package_archive, jfrog_url, api_key = jfrog_api(), access_token = NULL)
{
    if (is.character(access_token) && !is.na(api_key) && nzchar(access_token, keepNA = FALSE)) {
        auth_header <- httr::add_headers("Authorization" = paste("Bearer", access_token))
    } else if (is.character(api_key) && !is.na(api_key) && nzchar(api_key, keepNA = FALSE)) {
        auth_header <- httr::add_headers("X-JFrog-Art-Api" = api_key)
    } else {
        stop("No authentication credentials provided")
    }

    cran_suffix <- make_cran_suffix(package_archive)

    httr::POST(
        url = paste0(jfrog_url, "/", cran_suffix),
        config = auth_header,
        body = httr::upload_file(package_archive)
    )
}


make_cran_suffix <- function(package_archive)
{
    if (pkg.peek::package_ext(package_archive) == "tar.gz") {
        cran_suffix <- "sources"
    } else {
        r_version <- pkg.peek::get_r_version(package_archive)
        version_for_cran <- paste0(r_version$major, ".", r_version$minor)

        if (pkg.peek::package_ext(package_archive) == "zip") {
            os <- "windows"
        } else if (pkg.peek::package_ext(package_archive) == "tgz") {
            os <- "macosx"
        }

        cran_suffix <- paste0("binaries?distribution=", os, "&rVersion=", version_for_cran)
    }

    return(cran_suffix)
}
