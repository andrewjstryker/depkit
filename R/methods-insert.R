
#' @rdname insert
#' @param dep   A single htmltools::htmlDependency
#' @return      A new DependencyManager with that dependency appended
#' @export
setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "htmlDependency"),
  function(dm, dep) {
    stopifnot(length(dm) == 1)
    key <- paste0(dep$name, "-", dep$version)
    if (has(dm, key)) {
      dm
    }
    DependencyManager(c(dm@registry, list(key = dep)))
  }
)

#' @rdname insert
#' @param dep   A single htmlwidget
#' @return      A new DependencyManager with the widget’s dependencies
#'   registered
#' @export
setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "htmlwidget"),
  function(dm, dep) {
    for (hd in htmltools::htmlDependencies(dep)) {
      dm <- insert(dm, hd)
    }
    dm
  }
)

#' @rdname insert
#' @param dep   A list of htmlwidget or htmlDependency objects
#' @return      A new DependencyManager with each list element registered
#' @export
setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "list"),
  function(dm, dep) {
    for (x in dep) {
      dm <- insert(dm, x)
    }
    dm
  }
)
