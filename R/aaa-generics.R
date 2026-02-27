#' Check whether dependencies are registered
#'
#' @param x A dependency_manager.
#' @param dep A dependency key, html_dependency, htmlwidget, or list.
#' @export
has <- function(x, dep) UseMethod("has")

#' Insert dependencies
#'
#' @param x A dependency_manager or insert_update.
#' @param dep An html_dependency, htmlwidget, or list.
#' @export
insert <- function(x, dep) UseMethod("insert")

#' Remove dependencies
#'
#' @param x A dependency_manager.
#' @param dep A dependency key, html_dependency, htmlwidget, or list.
#' @export
remove <- function(x, dep) UseMethod("remove")

#' Emit CSS link tags
#'
#' @param x A dependency_manager or insert_update.
#' @param keys Optional character vector of asset ids to filter.
#' @export
emit_css <- function(x, keys = NULL) UseMethod("emit_css")

#' Emit JS script tags
#'
#' @param x A dependency_manager or insert_update.
#' @param keys Optional character vector of asset ids to filter.
#' @export
emit_js <- function(x, keys = NULL) UseMethod("emit_js")

#' Extract the DependencyManager from an InsertUpdate
#'
#' @param update An insert_update object.
#' @export
dm <- function(update) UseMethod("dm")

#' Check if an InsertUpdate added nothing
#'
#' @param update An insert_update object.
#' @export
is_empty <- function(update) UseMethod("is_empty")
