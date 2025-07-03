#' Check registration status of dependencies or widgets
#'
#' Determine whether one or more dependencies (by name or object), HTML
#' dependency objects, HTML widgets, or lists thereof have been recorded in
#' a \code{DependencyManager}.
#'
#' @param dm   A \code{DependencyManager} object.
#' @param dep  One of:
#'   \describe{
#'     \item{\code{character}}{One element per name in \code{dep}.}
#'     \item{\code{html_dependency}}{One element per resource in the
#'       dependency.}tion status:
#'     \item{\code{htmlwidget}}{A single logical value.}
#'     \item{\code{list}}{One element per list element.}
#'   }
#'
#' @seealso \code{\link{insert}}, \code{\link{remove}}
#' @export
setGeneric(
  "has",
  function(dm, dep) standardGeneric("has")
)

#' Insert dependencies into the manager
#'
#' Register one or more dependencies with a \code{DependencyManager}.
#'
#' @param dm           A \code{DependencyManager} object.
#' @param dep          One of:
#'   \itemize{
#'     \item A single \code{htmlwidget} object.
#'     \item A single \code{htmlDependency} object.
#'     \item A list of \code{htmlwidget} or \code{htmlDependency} objects.
#'   }
#' @return A new \code{DependencyManager} with the specified dependencies
#'   appended.
#'
#' @seealso \code{\link{remove}}
#'
#' @export
#' @docType methods
#' @rdname insert
setGeneric(
  "insert",
  signature = c("dm", "dep"),
  function(dm, dep) standardGeneric("insert")
)

#' Insert dependencies into the manager
#'
#' Register one or more dependencies with a \code{DependencyManager}.
#'
#' @param dm           A \code{DependencyManager} object.
#' @param dep          One of:
#'   \itemize{
#'     \item A single \code{htmlwidget} object.
#'     \item A single \code{htmlDependency} object.
#'     \item A list of \code{htmlwidget} or \code{htmlDependency} objects.
#'   }
#' @return A new \code{DependencyManager} with the specified dependencies
#'   appended.
#'
#' @seealso \code{\link{DependencyManager-class}}
#'
#' @export
#' @docType methods
#' @rdname remove
setGeneric(
  "remove",
  signature = c("dm", "dep"),
  function(dm, dep) standardGeneric("remove")
)

#’ Render a DependencyManager or its contents
#’
#’ Dispatches on \code{dm} + \code{dep} and then forwards rendering options
#’
#’ @param dm   A \code{DependencyManager} object
#’ @param dep  A dependency key (character), \code{html_dependency},
#'   \code{htmlwidget}, or \code{NULL}
#’ @param ...  Rendering options (see details)
#’
#’ @details
#’ You can control rendering via these options (either pass them here or
#’ set globally with \code{options()}):
#’ \describe{
#’   \item{\code{static_path}}{Directory to write local assets (default
#'     \code{"."})}
#’   \item{\code{cdn_mapping}}{Named list of pattern→URL templates (default
#'     \code{list()})}
#’   \item{\code{cdn_attempts}}{Number of HEAD attempts to locate assets
#'     (default \code{3L})}
#’   \item{\code{use_cdn}}{Logical; whether to fall back to CDN if local not
#'     found (default \code{TRUE})}
#’ }
#’
#’ @export
setGeneric("render",
  function(dm, dep = NULL, ...)
    standardGeneric("render"),
  signature = c("dm", "dep")
)