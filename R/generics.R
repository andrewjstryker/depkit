#' @export
setGeneric(
  "has",
  function(dm, dep) standardGeneric("has")
)

#' @export
setGeneric(
  "insert",
  signature = c("dm", "dep"),
  function(dm, dep) standardGeneric("insert")
)

#' @export
setGeneric(
  "remove",
  signature = c("dm", "dep"),
  function(dm, dep) standardGeneric("remove")
)

#' @export
setGeneric(
  "emit_css",
  signature = c("dm", "keys"),
  function(dm, keys = NULL) standardGeneric("emit_css")
)

#' @export
setGeneric(
  "emit_js",
  signature = c("dm", "keys"),
  function(dm, keys = NULL) standardGeneric("emit_js")
)

#' @export
setGeneric(
  "dm",
  function(update) standardGeneric("dm")
)

#' @export
setGeneric(
  "is_empty",
  function(update) standardGeneric("is_empty")
)
