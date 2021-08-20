#' Retrieve JFrog access token
#'
#' Retrieve a JFrog access token
#' Looks in the environment variable `JFROG_ACCESS_TOKEN`.
#'
#' @param quiet Whether or not to display a message if the access token is *not* available.
#'
#' @return The access token if available and `NA` otherwise.
#'
#' @export
jfrog_access_token <- function(quiet = TRUE)
{
    access_token <- Sys.getenv("JFROG_ACCESS_TOKEN", unset = NA_character_)

    if (is.na(access_token) && isFALSE(quiet)) {
        message("JFrog access token is not available")
    }

    return(access_token)
}
