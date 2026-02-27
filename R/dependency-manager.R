#' @importFrom htmltools htmlDependencies
#' @keywords internal
NULL

# -- Validation helpers -------------------------------------------------------

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

validate_dependency_manager <- function(x) {
  messages <- character()

  reg_check <- .valid_registry(x$registry)
  if (!isTRUE(reg_check)) messages <- c(messages, reg_check)

  css_check <- .valid_asset_vector(x$css_assets, "css_assets")
  if (!isTRUE(css_check)) messages <- c(messages, css_check)

  js_check <- .valid_asset_vector(x$js_assets, "js_assets")
  if (!isTRUE(js_check)) messages <- c(messages, js_check)

  cfg_check <- .valid_config(x$config)
  if (!isTRUE(cfg_check)) messages <- c(messages, cfg_check)

  if (length(messages)) stop(paste(messages, collapse = "; "), call. = FALSE)
  invisible(x)
}

# -- Constructors -------------------------------------------------------------

new_dependency_manager <- function(registry = list(),
                                   css_assets = character(),
                                   js_assets = character(),
                                   config = list()) {
  cfg <- .dm_config_defaults(config)
  obj <- structure(
    list(
      registry = registry,
      css_assets = css_assets,
      js_assets = js_assets,
      config = cfg
    ),
    class = "dependency_manager"
  )
  validate_dependency_manager(obj)
  obj
}

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

  dm <- new_dependency_manager(
    registry = list(),
    css_assets = character(),
    js_assets = character(),
    config = config
  )

  if (length(registry)) {
    dm <- insert(dm, registry)$dm
  }
  dm
}

# -- has ----------------------------------------------------------------------

#' @export
has.dependency_manager <- function(x, dep) {
  if (is.character(dep)) {
    return(dep %in% names(x$registry))
  }
  if (inherits(dep, "html_dependency")) {
    return(has(x, make_dep_key(dep)))
  }
  if (inherits(dep, "htmlwidget")) {
    return(all(vapply(htmltools::htmlDependencies(dep), function(d) has(x, d), logical(1))))
  }
  if (is.list(dep)) {
    return(vapply(dep, function(d) has(x, d), logical(1)))
  }
  stop("Unsupported type for 'dep'.", call. = FALSE)
}

# -- insert -------------------------------------------------------------------

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
  css_res <- append_unique_ordered(dm$css_assets, css_ids)
  js_res <- append_unique_ordered(dm$js_assets, js_ids)

  new_dm <- new_dependency_manager(
    registry = registry,
    css_assets = css_res$updated,
    js_assets = js_res$updated,
    config = dm$config
  )

  list(
    dm = new_dm,
    added_css = css_res$added,
    added_js = js_res$added
  )
}

insert_dependency <- function(dm, dep) {
  info <- collect_asset_ids(dep)
  registry <- dm$registry
  if (!has(dm, info$dep_key)) {
    registry[[info$dep_key]] <- dep
  }
  append_assets(dm, info$css_ids, info$js_ids, registry)
}

insert_many <- function(dm, deps) {
  css_candidates <- character()
  js_candidates <- character()
  registry <- dm$registry

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
  assert_config_paths(dm$config)
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

#' @export
insert.dependency_manager <- function(x, dep) {
  insert_impl(x, dep)
}

# -- remove -------------------------------------------------------------------

#' @export
remove.dependency_manager <- function(x, dep) {
  if (is.character(dep)) {
    if (!all(dep %in% names(x$registry))) {
      stop(
        "Cannot remove dependencies that are not registered: ",
        paste(dep[!dep %in% names(x$registry)], collapse = ", "),
        call. = FALSE
      )
    }
    if (!length(dep)) {
      return(x)
    }

    deps_objects <- x$registry[dep]
    css_drop <- ordered_unique(unlist(lapply(deps_objects, function(d) collect_asset_ids(d)$css_ids), use.names = FALSE))
    js_drop  <- ordered_unique(unlist(lapply(deps_objects, function(d) collect_asset_ids(d)$js_ids), use.names = FALSE))

    return(new_dependency_manager(
      registry = x$registry[!names(x$registry) %in% dep],
      css_assets = x$css_assets[!x$css_assets %in% css_drop],
      js_assets = x$js_assets[!x$js_assets %in% js_drop],
      config = x$config
    ))
  }
  if (inherits(dep, "html_dependency")) {
    return(remove(x, make_dep_key(dep)))
  }
  if (inherits(dep, "htmlwidget")) {
    return(Reduce(
      function(acc, item) {
        if (has(acc, item)) remove(acc, item) else acc
      },
      htmltools::htmlDependencies(dep),
      init = x
    ))
  }
  if (is.list(dep)) {
    return(Reduce(
      function(acc, item) remove(acc, item),
      dep,
      init = x
    ))
  }
  stop("No remove() method for objects of class \u201c", class(dep)[1], "\u201d", call. = FALSE)
}

# -- emit ---------------------------------------------------------------------

filter_keys <- function(dm, keys, kind) {
  known <- if (kind == "css") dm$css_assets else dm$js_assets
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

#' @export
emit_css.dependency_manager <- function(x, keys = NULL) {
  asset_ids <- filter_keys(x, keys, "css")
  records <- build_asset_records(x, asset_ids, "css")
  vapply(records, css_tag, character(1))
}

#' @export
emit_js.dependency_manager <- function(x, keys = NULL) {
  asset_ids <- filter_keys(x, keys, "js")
  records <- build_asset_records(x, asset_ids, "js")
  vapply(records, js_tag, character(1))
}

# -- print / names / length ---------------------------------------------------

#' @export
print.dependency_manager <- function(x, ...) {
  n <- length(x)
  cat("<DependencyManager> with ", n, " registered ",
      if (n == 1L) "dependency:\n" else "dependencies:\n", sep = "")
  if (n > 0L) {
    nm <- names(x)
    cat("  ", paste(nm, collapse = ", "), "\n", sep = "")
  }
  invisible(x)
}

#' @export
names.dependency_manager <- function(x) {
  names(x$registry)
}

#' @export
`names<-.dependency_manager` <- function(x, value) {
  if (!is.character(value) || length(value) != length(x$registry)) {
    stop(
      "replacement names must be a character vector ",
      "of the same length as the registry"
    )
  }
  if (length(x$registry) == 0L) {
    return(x)
  }

  reg <- x$registry
  names(reg) <- value

  new_dependency_manager(
    registry = reg,
    css_assets = x$css_assets,
    js_assets = x$js_assets,
    config = x$config
  )
}

#' @export
length.dependency_manager <- function(x) {
  length(x$registry)
}
