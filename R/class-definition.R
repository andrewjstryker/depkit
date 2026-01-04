#' @include utils.R
NULL

.dm_config_defaults <- function(config = list()) {
  cfg <- modifyList(
    list(
      output_root = character(),
      url_root = character(),
      cdn_mode = "off"
    ),
    config
  )

  if (!is.null(cfg$output_root) && length(cfg$output_root) == 1 && is.na(cfg$output_root)) {
    cfg$output_root <- character()
  }
  if (!is.null(cfg$url_root) && length(cfg$url_root) == 1 && is.na(cfg$url_root)) {
    cfg$url_root <- character()
  }
  cfg
}

.valid_registry <- function(registry) {
  if (!is.list(registry)) {
    return("registry must be a list")
  }

  if (!length(registry)) {
    return(TRUE)
  }

  keys <- names(registry)
  if (is.null(keys) || any(!nzchar(keys))) {
    return("registry entries must be named with non-empty keys")
  }
  if (length(unique(keys)) != length(keys)) {
    return("registry keys must be unique")
  }
  if (any(!vapply(registry, function(x) inherits(x, "html_dependency"), logical(1)))) {
    return("all registry values must be html_dependency objects")
  }
  TRUE
}

.valid_asset_vector <- function(x, field) {
  if (!is.character(x)) {
    return(sprintf("%s must be a character vector", field))
  }
  if (any(is.na(x))) {
    return(sprintf("%s cannot contain NA values", field))
  }
  TRUE
}

.valid_config <- function(cfg) {
  if (!is.list(cfg)) {
    return("config must be a list")
  }
  if (is.null(cfg$cdn_mode) || length(cfg$cdn_mode) != 1) {
    return("config$cdn_mode must be length-1 character")
  }
  if (!cfg$cdn_mode %in% c("off", "verify")) {
    return("config$cdn_mode must be one of 'off' or 'verify'")
  }
  if (length(cfg$output_root) > 1 || length(cfg$url_root) > 1) {
    return("config$output_root and config$url_root must be length-1 if provided")
  }
  TRUE
}

#' DependencyManager
#'
#' S4 container for assetman state.
#'
#' @slot registry Named list of html_dependency, keyed by dep_key.
#' @slot css_assets Character vector of asset_ids (ordered unique).
#' @slot js_assets Character vector of asset_ids (ordered unique).
#' @slot config List containing output_root, url_root, cdn_mode.
#' @export
setClass(
  "DependencyManager",
  slots = c(
    registry = "list",
    css_assets = "character",
    js_assets = "character",
    config = "list"
  ),
  prototype = list(
    registry = list(),
    css_assets = character(),
    js_assets = character(),
    config = .dm_config_defaults()
  ),
  validity = function(object) {
    messages <- character()

    reg_check <- .valid_registry(object@registry)
    if (!isTRUE(reg_check)) messages <- c(messages, reg_check)

    css_check <- .valid_asset_vector(object@css_assets, "css_assets")
    if (!isTRUE(css_check)) messages <- c(messages, css_check)

    js_check <- .valid_asset_vector(object@js_assets, "js_assets")
    if (!isTRUE(js_check)) messages <- c(messages, js_check)

    cfg_check <- .valid_config(object@config)
    if (!isTRUE(cfg_check)) messages <- c(messages, cfg_check)

    if (length(messages)) messages else TRUE
  }
)

setMethod(
  "initialize",
  "DependencyManager",
  function(.Object, registry = list(), css_assets = character(), js_assets = character(), config = list(), ...) {
    cfg <- .dm_config_defaults(config)
    callNextMethod(
      .Object,
      registry = registry,
      css_assets = css_assets,
      js_assets = js_assets,
      config = cfg,
      ...
    )
  }
)

#' Construct a DependencyManager
#'
#' @param registry Optional list of html_dependency objects to pre-register.
#' @param output_root Filesystem root for copied assets.
#' @param url_root Base URL for emitted assets.
#' @param cdn_mode CDN handling mode ("off" or "verify").
#' @export
DependencyManager <- function(registry = list(),
                              output_root = NULL,
                              url_root = NULL,
                              cdn_mode = "off") {
  config <- .dm_config_defaults(
    list(
      output_root = output_root %||% character(),
      url_root = url_root %||% character(),
      cdn_mode = cdn_mode %||% "off"
    )
  )

  dm <- new(
    "DependencyManager",
    registry = list(),
    css_assets = character(),
    js_assets = character(),
    config = config
  )

  if (length(registry)) {
    dm <- insert(dm, registry)@dm
  }
  dm
}

#' InsertUpdate
#'
#' Delta + façade returned by insert().
#'
#' @slot dm DependencyManager after insertion.
#' @slot added_css Newly added CSS asset_ids.
#' @slot added_js Newly added JS asset_ids.
#' @export
setClass(
  "InsertUpdate",
  slots = c(
    dm = "DependencyManager",
    added_css = "character",
    added_js = "character"
  ),
  prototype = list(
    dm = new("DependencyManager"),
    added_css = character(),
    added_js = character()
  ),
  validity = function(object) {
    messages <- character()
    css_check <- .valid_asset_vector(object@added_css, "added_css")
    if (!isTRUE(css_check)) messages <- c(messages, css_check)
    js_check <- .valid_asset_vector(object@added_js, "added_js")
    if (!isTRUE(js_check)) messages <- c(messages, js_check)

    if (length(unique(object@added_css)) != length(object@added_css)) {
      messages <- c(messages, "added_css must be unique")
    }
    if (length(unique(object@added_js)) != length(object@added_js)) {
      messages <- c(messages, "added_js must be unique")
    }

    if (length(messages)) messages else TRUE
  }
)

InsertUpdate <- function(dm, added_css = character(), added_js = character()) {
  new("InsertUpdate", dm = dm, added_css = unique(added_css), added_js = unique(added_js))
}
