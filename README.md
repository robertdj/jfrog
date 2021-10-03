jfrog
=====

<!-- badges: start -->
[![R build status](https://github.com/robertdj/jfrog/workflows/R-CMD-check/badge.svg)](https://github.com/robertdj/jfrog/actions)
[![Codecov test coverage](https://codecov.io/gh/robertdj/jfrog/branch/main/graph/badge.svg)](https://codecov.io/gh/robertdj/jfrog?branch=main)
<!-- badges: end -->

The goal of {jfrog} is to provide an interface to [JFrog's CRAN](https://www.jfrog.com/confluence/display/JFROG/CRAN+Repositories).


# Installation

{jfrog} is only on GitHub and can be installed using the [remotes package](https://remotes.r-lib.org) with the command:

``` r
remotes::install_github("robertdj/jfrog")
```


# Usage

There are a few functions in {jfrog}.
All interaction with JFrog requires authentication with either an API Key or an access token. 
If you don't want to type supply this everytime {jfrog} looks in specific environment variables by default. 
Check the documentation of `jfrog_api` and `jfrog_access_token`.


# Upload package

The function `upload_package` is used to upload packages to JFrog's CRAN.


# Access tokens

Tokens can be created with the function `create_token`:

``` r
token <- jfrog::create_token("<jfrog_url>")
```

A valid token is required to create a new token.
A token can be created with the web interface through "Edit Profile" in the top right corner -> "Identify Token".

I use a long-lived token to create short-lived tokens with `create_token`.

