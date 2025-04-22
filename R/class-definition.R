#' Dependency Manager for htmlwidget
#'
#' This S4 class handles build‐time concerns for managing htmlwidget
#' dependencies when generating static webpages (e.g., for Hugo-based sites).
#' It is designed to ensure that dependencies (typically JavaScript and CSS
#' assets) are included only once in the final webpage. The manager attempts
#' to load assets from Content Delivery Networks (CDNs) and always extracts
#' a local copy from R packages as a fallback for both build time (when
#' generating the page) and run time (when the page is rendered by a browser).
#'
#' Dependencies are identified by a unique name-version string (e.g.,
#' `"jquery-2.1.2"`) as this conforms to common JavaScript package naming
#' conventions and Semantic Versioning.  Although it is possible to register
#' multiple versions (e.g., `"jquery-2.1.2"` versus `"jquery-2.1.3"`), typical
#' usage expects only one version per dependency in a webpage.
#'
#' The core use cases of this class include:
#' \enumerate{
#'   \item \strong{Caching:} Preventing redundant inclusion of dependency
#'     definitions.
#'
#'   \item \strong{CDN Loading with Local Fallback:} Inserting the appropriate
#'     HTML into the final static page that loads assets from a CDN—with
#'     a fallback to a locally extracted asset if the CDN is unreachable
#'     either at build time or at run time.
#'
#'   \item \strong{Build-Time Asset Extraction:} Extracting assets to
#'     a designated directory (e.g., a page bundle directory) to serve as
#'     a fallback mechanism.
#' }
#'
#' @slot registry A list storing recorded dependency objects, where each entry
#'   is keyed by a unique dependency identifier (combination of name and
#'   version, e.g., `"jquery-2.1.2"`).
#'
#' @docType class
#' @keywords htmlwidgets, static page, dependency management
#' @export
setClass(
  "DependencyManager",
  slots = c(
    registry = "list"
  ),
  validity = function(object) {
    reg <- object@registry

    nm <- names(reg)
    if (is.null(nm) || any(nm == "")) {
      return("All registry entries must be named and non-empty.")
    }

    if (length(unique(nm)) != length(nm)) {
      return("Registry names must be unique.")
    }

    not_html <-
      !vapply(reg, function(x) inherits(x, "htmlDependency"), logical(1))
    if (any(not_html)) {
      return(sprintf(
        "Registry contains non-htmlDependency values: %s",
        paste(nm[not_html], collapse = ", ")
      ))
    }
    TRUE
  }
)

#' Construct a DependencyManager Instance
#'
#' Initializes a new DependencyManager. Additional details on the behavior,
#' purpose, and structure of the DependencyManager class can be found in the
#' class documentation.
#'
#' @param registry A list that acts as a registry for dependency metadata.
#'   Defaults to an empty list.
#'
#' @return An object of class \code{DependencyManager}.
#'
#' @describedIn DependencyManager Dependency Manager for htmlwidget - see the
#'   class documentation for a full description.
#'
#' @export
DependencyManager <- # nolint
  function(registry = list()) {
    new("DependencyManager",
      registry = registry
    )
  }