#' Construct a dependency registry key
#'
#' Internal helper function that generates a unique key for a dependency
#' by concatenating its name and version.
#'
#' @param dep A list-like dependency object with elements \code{name}
#'   (character) and \code{version} (character), for example an
#'   \code{htmltools::htmlDependency} object.
#' @return A single-element character vector in the format
#'   \code{"<name>@<version>"}.
#' @keywords internal
#' @rdname key-utils
#'
dep_key <- function(dep) {
  paste0(dep$name, "@", dep$version)
}

#' Parse components from a dependency registry key
#'
#' Internal helper that splits a registry key string into its name and version
#'   parts.
#'
#' @param key A single-element character string in the format
#'   \code{"<name>@<version>"}.
#' @return A named list with two elements:
#'   \item{name}{Character string before the '@'.}
#'   \item{version}{Character string after the '@'.}
#' @keywords internal
#' @rdname key-utils
#' @details
#' If \code{key} does not contain exactly one '@' separator, the function will
#' terminate with an error message \code{"Invalid key format. Expected
#' 'name@version'"}.
#'
key_components <- function(key) {
  parts <- strsplit(key, "@")[[1]]
  if (length(parts) != 2) {
    stop("Invalid key format. Expected 'name@version'.")
  }
  list(name = parts[1], version = parts[2])
}