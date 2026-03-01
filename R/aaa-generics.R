#' Check whether dependencies are registered
#'
#' Tests whether one or more dependencies have already been registered in a
#' dependency manager.
#'
#' @param x A dependency_manager.
#' @param dep A dependency key, html_dependency, htmlwidget, or list.
#'
#' @return Logical. A scalar `TRUE`/`FALSE` when `dep` is a single key,
#'   html_dependency, or htmlwidget; a logical vector when `dep` is a list.
#'
#' @seealso [insert()], [remove()], [DependencyManager()]
#' @export
has <- function(x, dep) UseMethod("has")

#' Insert dependencies
#'
#' Registers new dependencies in the manager, copies their asset files to the
#' output directory, and records CSS/JS asset ids for later emission.
#' Dependencies that are already registered are silently skipped.
#'
#' @param x A dependency_manager or insert_update.
#' @param dep An html_dependency, htmlwidget, or list.
#'
#' @return An `insert_update` object containing the updated dependency manager
#'   and vectors of newly added CSS and JS asset ids.
#'
#' @seealso [dm()], [is_empty()], [remove()], [DependencyManager()]
#' @export
insert <- function(x, dep) UseMethod("insert")

#' Remove dependencies
#'
#' Removes one or more previously registered dependencies and their associated
#' asset ids from the manager. Does not delete copied files from disk.
#'
#' @param x A dependency_manager.
#' @param dep A dependency key, html_dependency, htmlwidget, or list.
#'
#' @return An updated `dependency_manager` with the specified dependencies
#'   removed.
#'
#' @seealso [has()], [insert()], [DependencyManager()]
#' @export
remove <- function(x, dep) UseMethod("remove")

#' Emit CSS link tags
#'
#' Generates `<link>` HTML tags for registered CSS assets.
#'
#' @param x A dependency_manager or insert_update.
#' @param keys Optional character vector of asset ids to filter.
#'
#' @return Character vector of HTML `<link rel="stylesheet">` tags, one per
#'   CSS asset.
#'
#' @seealso [emit_js()], [insert()], [DependencyManager()]
#' @export
emit_css <- function(x, keys = NULL) UseMethod("emit_css")

#' Emit JS script tags
#'
#' Generates `<script>` HTML tags for registered JavaScript assets. When
#' CDN is enabled (`cdn = TRUE`), tags include `integrity` and `crossorigin`
#' attributes with a local fallback.
#'
#' @param x A dependency_manager or insert_update.
#' @param keys Optional character vector of asset ids to filter.
#'
#' @return Character vector of HTML `<script>` tags, one per JS asset.
#'
#' @seealso [emit_css()], [insert()], [DependencyManager()]
#' @export
emit_js <- function(x, keys = NULL) UseMethod("emit_js")

#' Extract the DependencyManager from an InsertUpdate
#'
#' Retrieves the updated `dependency_manager` stored inside an `insert_update`
#' object, allowing continued use after an [insert()] call.
#'
#' @param update An insert_update object.
#'
#' @return A `dependency_manager` object.
#'
#' @seealso [insert()], [is_empty()]
#' @export
dm <- function(update) UseMethod("dm")

#' Check if an InsertUpdate added nothing
#'
#' Tests whether an [insert()] operation resulted in any new assets being
#' added. Useful for skipping downstream work when nothing changed.
#'
#' @param update An insert_update object.
#'
#' @return Scalar logical. `TRUE` if no CSS or JS assets were added, `FALSE`
#'   otherwise.
#'
#' @seealso [insert()], [dm()]
#' @export
is_empty <- function(update) UseMethod("is_empty")
