# -- Constructor --------------------------------------------------------------

InsertUpdate <- function(dm, added_css = character(), added_js = character()) {
  structure(
    list(
      dm = dm,
      added_css = unique(added_css),
      added_js = unique(added_js)
    ),
    class = "insert_update"
  )
}

# -- Methods ------------------------------------------------------------------

#' @export
dm.insert_update <- function(update) update$dm

#' @export
is_empty.insert_update <- function(update) {
  length(update$added_css) == 0 && length(update$added_js) == 0
}

#' @export
insert.insert_update <- function(x, dep) {
  insert(x$dm, dep)
}

#' @export
emit_css.insert_update <- function(x, keys = NULL) {
  emit_css(x$dm, keys %||% x$added_css)
}

#' @export
emit_js.insert_update <- function(x, keys = NULL) {
  emit_js(x$dm, keys %||% x$added_js)
}

#' @export
print.insert_update <- function(x, ...) {
  n_css <- length(x$added_css)
  n_js <- length(x$added_js)
  cat("<InsertUpdate> added ", n_css, " CSS, ", n_js, " JS assets\n", sep = "")
  invisible(x)
}
