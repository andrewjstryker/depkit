#' @include class-definition.R generics.R utils-assets.R
NULL

filter_keys <- function(dm, keys, kind) {
  known <- if (kind == "css") dm@css_assets else dm@js_assets
  if (is.null(keys)) return(known)
  missing <- keys[match(keys, known, nomatch = 0L) == 0L]
  if (length(missing)) {
    stop("Unknown asset ids for ", kind, ": ", paste(missing, collapse = ", "), call. = FALSE)
  }
  known[known %in% keys]
}

css_tag <- function(rec) {
  sprintf("<link rel=\"stylesheet\" href=\"%s\">", rec$url)
}

js_tag <- function(rec) {
  if (!is.null(rec$cdn_url)) {
    fb <- rec$fallback_url %||% rec$url
    integrity <- rec$integrity %||% ""
    sprintf(
      "<script src=\"%s\" integrity=\"%s\" crossorigin=\"anonymous\" onerror=\"this.onerror=null;this.src='%s';\"></script>",
      rec$cdn_url,
      integrity,
      fb
    )
  } else {
    sprintf("<script src=\"%s\"></script>", rec$url)
  }
}

setMethod(
  "emit_css",
  signature(dm = "DependencyManager", keys = "ANY"),
  function(dm, keys = NULL) {
    asset_ids <- filter_keys(dm, keys, "css")
    records <- build_asset_records(dm, asset_ids, "css")
    vapply(records, css_tag, character(1))
  }
)

setMethod(
  "emit_js",
  signature(dm = "DependencyManager", keys = "ANY"),
  function(dm, keys = NULL) {
    asset_ids <- filter_keys(dm, keys, "js")
    records <- build_asset_records(dm, asset_ids, "js")
    vapply(records, js_tag, character(1))
  }
)

setMethod(
  "dm",
  signature(update = "InsertUpdate"),
  function(update) update@dm
)

setMethod(
  "is_empty",
  signature(update = "InsertUpdate"),
  function(update) {
    length(update@added_css) == 0 && length(update@added_js) == 0
  }
)

setMethod(
  "insert",
  signature(dm = "InsertUpdate", dep = "ANY"),
  function(dm, dep) {
    insert(dm@dm, dep)
  }
)

setMethod(
  "emit_css",
  signature(dm = "InsertUpdate", keys = "ANY"),
  function(dm, keys = NULL) {
    emit_css(dm@dm, keys %||% dm@added_css)
  }
)

setMethod(
  "emit_js",
  signature(dm = "InsertUpdate", keys = "ANY"),
  function(dm, keys = NULL) {
    emit_js(dm@dm, keys %||% dm@added_js)
  }
)
