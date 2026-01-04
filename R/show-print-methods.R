#' @include class-definition.R generics.R
NULL

#' Show a summary of the DependencyManager
#' 
#' @description
#' \code{show()} displays a concise, human-readable summary of the
#' \code{DependencyManager}, including the total count of dependencies and their
#' names.
#'
#' @param object A \code{DependencyManager} object.
#' @return Invisibly returns \code{NULL}.
#' @export
#' @aliases show,DependencyManager-method
setMethod(
  "show",
  "DependencyManager",
  function(object) {
    n <- length(object)
    cat("<DependencyManager> with ", n, " registered ",
        if (n == 1L) "dependency:\n" else "dependencies:\n", sep = "")
    if (n > 0L) {
      nm <- names(object)
      cat("  ", paste(nm, collapse = ", "), "\n", sep = "")
    }
    invisible(NULL)
  }
)

#' Print a DependencyManager
#'
#' @description
#' \code{print()} is an alias for \code{show()} and will display the same summary.
#'
#' @inheritParams methods::show
#' @param ... Additional arguments (ignored).
#' @return Invisibly returns the original \code{DependencyManager} object.
#' @export
#' @aliases print,DependencyManager-method
setMethod(
  "print",
  "DependencyManager",
  function(x, ...) {
    show(x)
    invisible(x)
  }
)
