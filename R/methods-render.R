


#' Render a single html_dependency
#'
#' Locate JS (CDN vs local), copy assets, and format the HTML tag.
#' @rdname render-methods
setMethod(
  "render",
  signature(dm = "DependencyManager", dep = "html_dependency"),
  .render_html_dependency
)

#' Render by dependency key (character)
#'
#' Lookup the dependency in the registry and delegate to html_dependency method.
#' @rdname render-methods
setMethod(
  "render",
  signature(dm = "DependencyManager", dep = "character"),
  function(dm, dep, ...) {
    if (any(!has(dm, dep))) {
      stop("Unknown dependency key: ", dep)
    }
    render(dm, dm@registry[dep], ...)
  }
)

#' Render all registered dependencies
#'
#' When dep is NULL, render every dependency in registration order.
#' @rdname render-methods
setMethod(
  "render",
  signature(dm = "DependencyManager", dep = "NULL"),
  function(dm, dep, ...) {
    render(dm, dm@registry, ...)
  }
)

#' Render dependencies from an htmlwidget
#'
#' Extract dependencies via htmlDependencies() and render each.
#' @rdname render-methods
setMethod(
  "render",
  signature(dm = "DependencyManager", dep = "htmlwidget"),
  function(dm, dep, ...) {
    render(dm, htmltools::htmlDependencies(dep), ...)
  }
)

setMethod(
  "render",
  signature(dm = "DependencyManager", dep = "list"),
  function(dm, dep, ...) {
    Reduce(
      function(acc, d) c(acc, render(dm, d, ...)),
      dep,
      init = character(0),
    )
  }
)

setMethod(
  "render",
  signature(dm = "DependencyManager", dep = "ANY"),
  function(dm, dep, ...) {
    if (inherits(dep, "html_dependency")) {
      .render_html_dependency(dm, dep, ...)
    } else if (inherits(dep, "htmlwidget")) {
      render(dm, htmltools::htmlDependencies(dep), ...)
    } else {
      stop("Unsupported dependency type: ", class(dep)[[1]])
    }
  }
)
