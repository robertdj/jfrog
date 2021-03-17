package_ext <- function(package_file) {
    if (endsWith(package_file, ".tar.gz")) {
        file_ext <- "tar.gz"
    } else {
        file_ext <- tools::file_ext(package_file)
    }

    match.arg(file_ext, c("tar.gz", "tgz", "zip"))
}
