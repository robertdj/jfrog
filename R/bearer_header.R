#' Construct bearer header
#'
#' Construct bearer header for authorization with with an access token.
#'
#' @param access_token A valid token.
#'
#' @return A vector that can be used in a header.
#'
#' @examples
#' \dontrun{
#' install.packages("<package>", headers = bearer_header())
#' }
#'
#' @export
bearer_header <- function(access_token = jfrog_access_token())
{
    c("Authorization" = paste("Bearer", access_token))
}
