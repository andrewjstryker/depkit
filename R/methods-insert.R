#' @include class-definition.R generics.R utils-assets.R
NULL

normalize_insert_input <- function(x) {
  if (inherits(x, "html_dependency")) {
    return(list(x))
  }
  if (inherits(x, "htmlwidget")) {
    return(htmltools::htmlDependencies(x))
  }
  if (is.list(x)) {
    out <- list()
    for (item in x) {
      out <- c(out, normalize_insert_input(item))
    }
    return(out)
  }
  stop("Unsupported dependency type: ", class(x)[1], call. = FALSE)
}

append_assets <- function(dm, css_ids, js_ids, registry) {
  css_res <- append_unique_ordered(dm@css_assets, css_ids)
  js_res <- append_unique_ordered(dm@js_assets, js_ids)

  new_dm <- new(
    "DependencyManager",
    registry = registry,
    css_assets = css_res$updated,
    js_assets = js_res$updated,
    config = dm@config
  )

  list(
    dm = new_dm,
    added_css = css_res$added,
    added_js = js_res$added
  )
}

insert_dependency <- function(dm, dep) {
  info <- collect_asset_ids(dep)
  registry <- dm@registry
  if (!has(dm, info$dep_key)) {
    registry[[info$dep_key]] <- dep
  }
  append_assets(dm, info$css_ids, info$js_ids, registry)
}

insert_many <- function(dm, deps) {
  css_candidates <- character()
  js_candidates <- character()
  registry <- dm@registry

  for (dep in deps) {
    info <- collect_asset_ids(dep)
    css_candidates <- c(css_candidates, info$css_ids)
    js_candidates <- c(js_candidates, info$js_ids)
    if (!(info$dep_key %in% names(registry))) {
      registry[[info$dep_key]] <- dep
    }
  }

  css_candidates <- ordered_unique(css_candidates)
  js_candidates <- ordered_unique(js_candidates)

  append_assets(dm, css_candidates, js_candidates, registry)
}

insert_impl <- function(dm, dep) {
  assert_config_paths(dm@config)
  deps <- normalize_insert_input(dep)
  res <- insert_many(dm, deps)

  if (length(res$added_css)) {
    copy_assets_for_ids(res$dm, res$added_css, "css")
  }
  if (length(res$added_js)) {
    copy_assets_for_ids(res$dm, res$added_js, "js")
  }

  InsertUpdate(res$dm, added_css = res$added_css, added_js = res$added_js)
}

setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "html_dependency"),
  insert_impl
)

setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "htmlwidget"),
  insert_impl
)

setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "list"),
  insert_impl
)

setMethod(
  "insert",
  signature(dm = "DependencyManager", dep = "ANY"),
  function(dm, dep) insert_impl(dm, dep)
)
