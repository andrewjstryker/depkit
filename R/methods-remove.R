#' Removed htmlwidget dependencies (helper)
#'
#' This is an internal function that does the real work for
#' \code{\link{remove,DependencyManager,htmlwidget-method}}.
#'
#' @param dm   A \code{DependencyManager} object.
#' @param dep  An \code{htmlwidget} object.
#' @return     A \code{DependencyManager} with the widget’s
#'             dependencies registered.
#' @keywords internal
.remove_htmlwidget <-
  function(dm, dep) {
    Reduce(
      function(acc, item) remove(acc, item),
      htmltools::htmlDependencies(dep),
      init = dm
    )
  }

#' @describeIn remove Method for removing a character vector of dependencies
#' @exportMethod remove
setMethod(
  "remove",
  signature(dm = "DependencyManager", dep = "character"),
  function(dm, dep) {
    if (!all(dep %in% names(dm@registry))) {
      stop(
        "Cannot remove dependencies that are not registered: ",
        paste(dep[! dep %in% names(dm@registry)], collapse = ", ")
      )
    } else if (length(dep) == 0) {
      warning("No dependencies to remove")
    } else {
      DependencyManager(
        dm@registry[! names(dm@registry) %in% dep]
      )
    }
  }
)

#' @describeIn remove Method for removing a single html_dependency
#' @exportMethod remove
setMethod(
  "remove",
  signature(dm = "DependencyManager", dep = "html_dependency"),
  function(dm, dep) {
    remove(dm, dep_key(dep))
  }
)

#' @describeIn remove Method for removing a single htmlwidget
#' @exportMethod remove
setMethod(
  "remove",
  signature(dm = "DependencyManager", dep = "htmlwidget"),
  .remove_htmlwidget
)

#' @describeIn remove Method for removing a list of dependencies
#' @exportMethod remove
setMethod(
  "remove",
  signature(dm = "DependencyManager", dep = "list"),
  function(dm, dep) {
    Reduce(
      function(acc, item) remove(acc, item),
      dep,
      init = dm
    )
  }
)

#' @describeIn remove  catch-all for any dep
#' @exportMethod remove
setMethod(
  "remove",
  signature(dm = "DependencyManager", dep = "ANY"),
  function(dm, dep) {
    if (inherits(dep, "htmlwidget")) {
      .remove_htmlwidget(dm, dep)
    } else if (inherits(dep, "html_dependency")) {
      remove(dm, dep_key(dep))
    } else {
      stop("No remove() method for objects of class “", class(dep)[1], "”")
    }
  }
)