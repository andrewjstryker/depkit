#' Check if a widget's dependencies are registered
#'
#' This is an internal function that does the real work for
#' \code{\link{has,DependencyManager,htmlwidget-method}}.
#'
#' @param dm   A \code{DependencyManager} object.
#' @param dep  A \code{htmlwidget} object.
#' @return TRUE if all dependencies are registered; otherwise FALSE.
#' @keywords internal
.has_htmlwidget <-
  function(dm, dep) {
    Reduce(
      function(acc, d) acc && has(dm, d),
      htmltools::htmlDependencies(dep),
      init = TRUE
    )
  }

#' Check if a dependency is registered
#'
#' This is an internal function that does the real work for
#' \code{\link{has,DependencyManager,html_dependency-method}}.
#'
#' @param dm   A \code{DependencyManager} object.
#' @param dep  A \code{html_dependency} object.
#' @return A logical vector, one element per dependency in \code{dep}.
#' @keywords internal
.has_html_dependency <-
  function(dm, dep) {
    has(dm, dep_key(dep))
  }

#' @describeIn has Check for a dependencies by name
#' @exportMethod has
setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "character"),
  function(dm, dep) {
    dep %in% names(dm@registry)
  }
)

#' @describeIn has Check for a single htmlDependency
#' @exportMethod has
setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "html_dependency"),
  .has_html_dependency
)

#' @describeIn has Check for a single htmlwidget
#' @exportMethod has
setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "htmlwidget"),
  .has_htmlwidget
)

#' @describeIn has Check for a list of htmlwidget and/or html_dependency objects
#' objects
#' @exportMethod has
setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "list"),
  function(dm, dep) {
    vapply(dep, function(x) has(dm, x), logical(1))
  }
)

#' @describeIn has Check for a single htmlwidget or html_dependency
#' @exportMethod has
setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "ANY"),
  function(dm, dep) {
    if (inherits(dep, "htmlwidget")) {
      .has_htmlwidget(dm, dep)
    } else if (inherits(dep, "html_dependency")) {
      .has_html_dependency(dm, dep)
    } else {
      stop("Unsupported type for 'dep'.")
    }
  }
)