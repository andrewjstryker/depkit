#' Insert htmlwidget dependencies (helper)
#'
#' This is an internal function that does the real work for
#' \code{\link{insert,DependencyManager,htmlwidget-method}}.
#'
#' @param dm   A \code{DependencyManager} object.
#' @param dep  An \code{htmlwidget} object.
#' @return     A \code{DependencyManager} with the widget’s
#'             dependencies registered.
#' @keywords internal
.insert_htmlwidget <-
  function(dm, dep) {
    Reduce(
      function(acc, item) insert(acc, item),
      htmltools::htmlDependencies(dep),
      init = dm
    )
  }

#' Insert htmldependency dependencies (helper)
#'
#' This is an internal function that does the real work for
#' \code{\link{insert,DependencyManager,htmldependency-method}}.
#'
#' @param dm   A \code{DependencyManager} object.
#' @param w    An \code{htmldependency} object.
#' @return     A \code{DependencyManager} with the
#'             dependencies registered.
#' @keywords internal
.insert_html_dependency <-
  function(dm, dep) {
    key <- dep_key(dep)
    if (has(dm, key)) {
      dm
    } else {
      # do not use the constructor as the constructor uses insert() which will
      # call this function again, leading to infinite recursion
      new(
        "DependencyManager",
        registry = c(dm@registry, stats::setNames(list(dep), key))
      )
    }
  }

#' @describeIn insert Method for inserting a character vector of dependencies
#' @exportMethod insert
setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "html_dependency"),
  .insert_html_dependency
)

#' @describeIn insert Method for inserting a widget with one or more
#'   dependencies
#' @exportMethod insert
setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "htmlwidget"),
  .insert_htmlwidget
)

#' @describeIn insert Method for inserting a list of html_dependency objects
#' @exportMethod insert
setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "list"),
  function(dm, dep) {
    Reduce(
      function(acc, item) insert(acc, item),
      dep,
      init = dm
    )
  }
)

#' @describeIn insert  catch-all for any dep
#' @exportMethod insert
setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "ANY"),
  function(dm, dep) {
    if (inherits(dep, "htmlwidget")) {
      .insert_htmlwidget(dm, dep)
    } else if (inherits(dep, "html_dependency")) {
      .insert_html_dependency(dm, dep)
    } else {
      stop("No insert() method for objects of class “", class(dep)[1], "”")
    }
  }
)