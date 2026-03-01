#' @importFrom base64enc base64encode
#' @importFrom digest digest
#' @importFrom openssl sha384
#' @keywords internal
NULL

rtrim_slash <- function(x) {
  sub("/+$", "", x)
}

flatten_asset_spec <- function(spec, descriptor_extract, field_name) {
  if (is.null(spec)) return(character())
  if (is.character(spec)) return(unname(spec))

  if (is.list(spec)) {
    out <- unlist(
      lapply(spec, function(el) {
        if (is.null(el)) {
          character()
        } else if (is.character(el)) {
          el
        } else if (is.list(el)) {
          descriptor_extract(el)
        } else {
          stop("Unsupported element in ", field_name, call. = FALSE)
        }
      }),
      use.names = FALSE
    )
    return(out)
  }

  stop("Unsupported type for ", field_name, call. = FALSE)
}

dependency_source_dir <- function(dep) {
  src <- dep[["src"]]
  if (is.null(src)) {
    stop("Dependency lacks 'src'.", call. = FALSE)
  }
  if (is.list(src)) src <- unlist(src)
  if (!is.character(src) || !length(src)) {
    stop("Dependency 'src' must be character.", call. = FALSE)
  }

  root <- if (!is.null(names(src)) && "file" %in% names(src)) src[["file"]] else src[[1]]
  pkg <- dep[["package"]]
  if (!is.null(pkg) && nzchar(pkg)) {
    root <- system.file(root, package = pkg)
  }
  if (!nzchar(root) || !dir.exists(root)) {
    stop("Cannot locate dependency source directory: ", root, call. = FALSE)
  }
  normalizePath(root, winslash = "/", mustWork = TRUE)
}

append_unique_ordered <- function(existing, candidates) {
  existing <- as.character(existing %||% character())
  candidates <- as.character(candidates %||% character())
  added <- candidates[match(candidates, existing, nomatch = 0L) == 0L]
  list(
    updated = c(existing, added),
    added = added
  )
}

asset_rel_paths <- function(dep, field) {
  extractor <- switch(
    field,
    script = function(x) {
      fn <- x[["src"]]
      if (is.null(fn) || !nzchar(fn)) stop("Script descriptor missing 'src'", call. = FALSE)
      fn
    },
    stylesheet = function(x) {
      fn <- x[["href"]]
      if (is.null(fn) || !nzchar(fn)) stop("Stylesheet descriptor missing 'href'", call. = FALSE)
      fn
    }
  )
  flatten_asset_spec(dep[[field]], extractor, field)
}

collect_asset_ids <- function(dep) {
  key <- make_dep_key(dep)
  css_rel <- asset_rel_paths(dep, "stylesheet")
  js_rel <- asset_rel_paths(dep, "script")

  list(
    dep_key = key,
    css_ids = if (length(css_rel)) make_asset_id(key, css_rel) else character(),
    js_ids = if (length(js_rel)) make_asset_id(key, js_rel) else character(),
    css_rel = css_rel,
    js_rel = js_rel
  )
}

compute_sri_hash <- function(path, algo = "sha384") {
  algo <- match.arg(algo, c("sha256", "sha384", "sha512"))
  hash_raw <- switch(
    algo,
    sha384 = {
      bin <- readBin(path, "raw", n = file.info(path)$size + 1L)
      openssl::sha384(bin)
    },
    digest::digest(path, algo = algo, file = TRUE, raw = TRUE)
  )
  paste0(algo, "-", base64enc::base64encode(hash_raw))
}

dep_subdir <- function(dep) {
  paste0(dep$name, "-", dep$version)
}

build_asset_records <- function(dm, asset_ids, kind) {
  assert_config_paths(dm$config)

  lapply(asset_ids, function(id) {
    parts <- parse_asset_id(id)
    dep <- dm$registry[[parts$dep_key]]
    if (is.null(dep)) {
      stop("Unknown dependency key: ", parts$dep_key, call. = FALSE)
    }

    src_dir <- dependency_source_dir(dep)
    sub_dir <- dep_subdir(dep)
    src_path <- file.path(src_dir, parts$rel_path)
    dest_path <- join_path(dm$config$output_root, file.path(sub_dir, parts$rel_path))
    url <- paste0(rtrim_slash(dm$config$url_root), "/", sub_dir, "/", parts$rel_path)

    record <- list(
      asset_id = id,
      dep_key = parts$dep_key,
      rel_path = parts$rel_path,
      kind = kind,
      src_path = src_path,
      dest_path = dest_path,
      url = url
    )

    if (identical(kind, "js") && isTRUE(dm$config$cdn)) {
      cached <- dm$cdn_cache[[id]]
      if (!is.null(cached)) {
        record$cdn_url <- cached$cdn_url
        record$integrity <- cached$integrity
        record$fallback_url <- url
      }
    }

    record
  })
}

copy_assets_for_ids <- function(dm, asset_ids, kind) {
  records <- build_asset_records(dm, asset_ids, kind)
  vapply(records, function(rec) {
    if (!file.exists(rec$src_path)) {
      stop("Missing asset: ", rec$src_path, call. = FALSE)
    }
    ensure_dir(dirname(rec$dest_path))
    file.copy(rec$src_path, rec$dest_path, overwrite = TRUE)
    rec$dest_path
  }, character(1))
  invisible(records)
}
