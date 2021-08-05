# To run this script make sure that:
# - The variable jfrog_url is set
# - The variable api_key is set
# - The variable access_token is set
#
# Note that this will upload the {jfrog} package to the JFrog CRAN.

library(httptest)
httptest::start_capturing(simplify = TRUE)

source_package_archive <- pkgbuild::build(binary = FALSE)
upload_package(source_package_archive, jfrog_url, api_key = api_key)
upload_package(source_package_archive, jfrog_url, access_token = access_token)

binary_package_archive <- pkgbuild::build(binary = TRUE)
upload_package(binary_package_archive, jfrog_url, api_key = api_key)
upload_package(binary_package_archive, jfrog_url, access_token = access_token)

upload_package(source_package_archive, jfrog_url, api_key = "")

httptest::stop_capturing()
