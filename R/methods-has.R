#' @include class-definition.R generics.R utils-keys.R
NULL

.has_html_dependency <- function(dm, dep) {
  has(dm, make_dep_key(dep))
}

.has_htmlwidget <- function(dm, dep) {
  all(vapply(htmltools::htmlDependencies(dep), function(d) has(dm, d), logical(1)))
}

setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "character"),
  function(dm, dep) {
    dep %in% names(dm@registry)
  }
)

setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "html_dependency"),
  function(dm, dep) {
    has(dm, make_dep_key(dep))
  }
)

setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "htmlwidget"),
  function(dm, dep) {
    all(vapply(htmltools::htmlDependencies(dep), function(d) has(dm, d), logical(1)))
  }
)

setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "list"),
  function(dm, dep) {
    vapply(dep, function(x) has(dm, x), logical(1))
  }
)

setMethod(
  "has",
  signature(dm = "DependencyManager", dep = "ANY"),
  function(dm, dep) {
    if (inherits(dep, "html_dependency")) return(.has_html_dependency(dm, dep))
    if (inherits(dep, "htmlwidget")) return(.has_htmlwidget(dm, dep))
    stop("Unsupported type for 'dep'.", call. = FALSE)
  }
)
