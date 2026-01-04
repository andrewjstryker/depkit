#' @include class-definition.R generics.R utils-assets.R utils-keys.R
NULL

.remove_htmlwidget <- function(dm, dep) {
  Reduce(
    function(acc, item) {
      if (has(acc, item)) remove(acc, item) else acc
    },
    htmltools::htmlDependencies(dep),
    init = dm
  )
}

setMethod(
  "remove",
  signature(dm = "DependencyManager", dep = "character"),
  function(dm, dep) {
    if (!all(dep %in% names(dm@registry))) {
      stop(
        "Cannot remove dependencies that are not registered: ",
        paste(dep[! dep %in% names(dm@registry)], collapse = ", "),
        call. = FALSE
      )
    }
    if (!length(dep)) {
      return(dm)
    }

    deps_objects <- dm@registry[dep]
    css_drop <- ordered_unique(unlist(lapply(deps_objects, function(d) collect_asset_ids(d)$css_ids), use.names = FALSE))
    js_drop  <- ordered_unique(unlist(lapply(deps_objects, function(d) collect_asset_ids(d)$js_ids), use.names = FALSE))

    new(
      "DependencyManager",
      registry = dm@registry[! names(dm@registry) %in% dep],
      css_assets = dm@css_assets[!dm@css_assets %in% css_drop],
      js_assets = dm@js_assets[!dm@js_assets %in% js_drop],
      config = dm@config
    )
  }
)

setMethod(
  "remove",
  signature(dm = "DependencyManager", dep = "html_dependency"),
  function(dm, dep) {
    remove(dm, make_dep_key(dep))
  }
)

setMethod(
  "remove",
  signature(dm = "DependencyManager", dep = "htmlwidget"),
  .remove_htmlwidget
)

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

setMethod(
  "remove",
  signature(dm = "DependencyManager", dep = "ANY"),
  function(dm, dep) {
    if (inherits(dep, "htmlwidget")) {
      .remove_htmlwidget(dm, dep)
    } else if (inherits(dep, "html_dependency")) {
      remove(dm, make_dep_key(dep))
    } else {
      stop("No remove() method for objects of class “", class(dep)[1], "”", call. = FALSE)
    }
  }
)
