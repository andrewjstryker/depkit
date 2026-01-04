#' @include class-definition.R generics.R
NULL

#' Names method for DependencyManager
#'
#' Returns the names of the dependencies currently recorded in a
#' \code{DependencyManager}.
#'
#' @docType methods
#' @rdname DependencyManager-names
#' @aliases names,DependencyManager-method
#' @param x A \code{DependencyManager} object.
#' @return A character vector of dependency names.
#' @exportMethod names
setMethod(
  "names",
  "DependencyManager",
  function(x) {
    names(x@registry)
  }
)

#' Names<- method for DependencyManager
#'
#' Replaces the names of the dependencies in a \code{DependencyManager}.
#'
#' @docType methods
#' @rdname DependencyManager-names
#' @aliases names<-,DependencyManager-method
#' @param x A \code{DependencyManager} object.
#' @param value A character vector of the same length as the registry.
#' @return The original \code{DependencyManager}, with its names updated.
#' @exportMethod names<-
setReplaceMethod(
  "names",
  "DependencyManager",
  function(x, value) {
    if (!is.character(value) || length(value) != length(x@registry)) {
      stop(
        "replacement names must be a character vector ",
        "of the same length as the registry"
      )
    }
    if (length(x@registry) == 0L) {
      return(x)
    }

    reg <- x@registry
    names(reg) <- value

    new(
      "DependencyManager",
      registry = reg,
      css_assets = x@css_assets,
      js_assets = x@js_assets,
      config = x@config
    )
  }
)
