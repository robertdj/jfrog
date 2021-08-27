#' Retrieve JFrog API Key
#'
#' Retrieve a JFrog API Key.
#' Looks in the environment variable `JFROG_API_KEY`.
#'
#' @param quiet Whether or not to display a message if the API Key is *not* available.
#'
#' @return The API Key if available and `NA` otherwise.
#'
#' @export
jfrog_api <- function(quiet = TRUE)
{
    assertthat::assert_that(
        assertthat::is.flag(quiet)
    )

    api_key <- Sys.getenv("JFROG_API_KEY", unset = NA_character_)

    if (is.na(api_key) && isFALSE(quiet)) {
        message("JFrog API Key is not available")
    }

    return(api_key)
}
