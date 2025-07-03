

.render_html_dependency <-
  function(dm, dep, ...) {
    opts <-
      modifyList(
        list(
          cdns = getOption("widgetman.cdns"),
          local_js_path = getOption("widgetman.local_js_path"),
          local_css_path = getOption("widgetman.local_css_path"),
          timeout = getOption("widgetman.timeout")
        ),
        list(...),
      )

    # 1) arrange local assets
    css_local <- copy_dependency_asset(dep$stylesheet, opts$local_css_path)
    js_local <- copy_dependency_asset(dep$script, opts$local_js_path)

    # 2) locate CDN assets
    js_cdn <- locate_dependency_cdn(dep$script, opts$cdns)

    # 3) format HTML tags
    tags <-
      c(
        format_css_tags(dep$stylesheet, opts$local_css_path),
        format_js_tags(
          dep$script,
          opts$local_js_path,
          js_cdn,
          opts$timeout
        )
      )

    # 4) return HTML tags
    cat(tags, sep = "\n")
    invisible(tags)
  }

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
