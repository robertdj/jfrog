#' Upload package archive to JFrog
#'
#' JFrog allows different ways of authentication as noted in [JFrog's documentation](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API).
#' Here we rely on an [API Key](https://www.jfrog.com/confluence/display/JFROG/User+Profile#UserProfile-APIKey) for a dedicated header or an [access token](https://www.jfrog.com/confluence/display/JFROG/Access+Tokens) in an authorization header.
#'
#' If both `api_key` and `access_token` are supplied then `access_token` is used.
#' The rationale is that this is the desired behavior in CI pipelines.
#'
#' @param package_archive Path to `tar.gz`, `zip` or `tgz` archive.
#' @param jfrog_url Base URL of the JFrog CRAN API. Note that if the URL of the CRAN is `https://HOSTNAME.jfrog.io/artifactory/cran-local` the URL of the API is `https://HOSTNAME.jfrog.io/artifactory/api/cran/cran-local`.
#' @param api_key JFrog API Key.
#' @param access_token JFrog access token.
#'
#' @return Response from [httr::POST()].
#'
#' @export
upload_package <- function(package_archive, jfrog_url, api_key = jfrog_api_key(), access_token = jfrog_access_token())
{
    assertthat::assert_that(
        assertthat::is.readable(package_archive)
    )

    if (is_valid_key(access_token)) {
        auth_header <- httr::add_headers("Authorization" = paste("Bearer", access_token))
    } else if (is_valid_key(api_key)) {
        auth_header <- httr::add_headers("X-JFrog-Art-Api" = api_key)
    } else {
        stop("No authentication credentials provided")
    }

    upload_url <- make_upload_url(package_archive, jfrog_url)

    response <- httr::POST(
        url = upload_url,
        config = auth_header,
        body = httr::upload_file(package_archive)
    )

    httr::stop_for_status(response)

    return(response)
}


is_valid_key <- function(x)
{
    is.character(x) && !is.na(x) && nzchar(x, keepNA = FALSE)
}


make_upload_url <- function(package_archive, jfrog_url)
{
    parsed_jfrog_url <- httr::parse_url(jfrog_url)

    empty_url_parts <- names(parsed_jfrog_url)[vapply(parsed_jfrog_url, is.null, logical(1))]
    if (any(c("scheme", "hostname", "path") %in% empty_url_parts))
        stop("JFrog CRAN URL must contain scheme, hostname and path")

    if (!grepl("artifactory/api/", parsed_jfrog_url$path, fixed = TRUE))
        stop("CRAN URL does not contain 'artifactory' path")

    path_sans_trailing_slash <- sub("/+$", "", parsed_jfrog_url$path)
    parsed_jfrog_url$path <- path_sans_trailing_slash

    package_ext <- pkg.peek::package_ext(package_archive)

    if (package_ext == "tar.gz") {
        parsed_jfrog_url$path <- paste0(parsed_jfrog_url$path, "/sources")
        return(httr::build_url(parsed_jfrog_url))
    }

    if (!pkg.peek::is_package_built(package_archive))
        stop("Packages for Windows and macOS must be compiled")

    r_version <- pkg.peek::get_r_version(package_archive)
    version_for_cran <- paste0(r_version$major, ".", r_version$minor)

    if (package_ext == "zip") {
        os <- "windows"
    } else if (package_ext == "tgz") {
        os <- "macosx"
    }

    parsed_jfrog_url$path <- paste0(parsed_jfrog_url$path, "/binaries")
    parsed_jfrog_url$query <- list(distribution = os, rVersion = version_for_cran)

    return(httr::build_url(parsed_jfrog_url))
}
