#' @include class-definition.R generics.R
NULL

#' Length method for DependencyManager
#'
#' Returns the number of dependencies currently recorded in a
#' \code{DependencyManager}.
#'
#' @docType methods
#' @rdname DependencyManager-length
#' @aliases length,DependencyManager-method
#' @param x A \code{DependencyManager} object.
#' @return Integer scalar giving the count of registered dependencies.
#' @exportMethod length
setMethod(
  "length",
  "DependencyManager",
  function(x) length(x@registry)
)
