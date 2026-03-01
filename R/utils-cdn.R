#' @importFrom httr2 request req_perform resp_body_json resp_status req_error
#' @keywords internal
NULL

jsdelivr_cdn_url <- function(pkg_name, version, npm_path) {
  paste0("https://cdn.jsdelivr.net/npm/", pkg_name, "@", version, npm_path)
}

flatten_jsdelivr_files <- function(files, prefix = "") {
  out <- list()
  for (f in files) {
    path <- paste0(prefix, "/", f$name)
    if (identical(f$type, "directory")) {
      out <- c(out, flatten_jsdelivr_files(f$files, path))
    } else {
      out <- c(out, list(list(name = path, hash = f$hash)))
    }
  }
  out
}

compute_jsdelivr_hash <- function(path) {
  bin <- readBin(path, "raw", n = file.info(path)$size + 1L)
  hash_raw <- openssl::sha256(bin)
  base64enc::base64encode(hash_raw)
}

match_by_hash <- function(local_hash, jsdelivr_files) {
  for (f in jsdelivr_files) {
    if (identical(f$hash, local_hash)) {
      return(f$name)
    }
  }
  NULL
}

resolve_cdn <- function(dep, rel_paths) {
  tryCatch(
    resolve_cdn_impl(dep, rel_paths),
    error = function(e) NULL
  )
}

resolve_cdn_impl <- function(dep, rel_paths) {
  api_url <- paste0(
    "https://data.jsdelivr.com/v1/packages/npm/",
    dep$name, "@", dep$version
  )

  resp <- httr2::request(api_url) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  if (httr2::resp_status(resp) != 200L) {
    return(NULL)
  }

  body <- httr2::resp_body_json(resp)
  files <- body$files
  if (!is.list(files) || !length(files)) {
    return(NULL)
  }

  flat_files <- flatten_jsdelivr_files(files)
  src_dir <- dependency_source_dir(dep)

  results <- stats::setNames(
    vector("list", length(rel_paths)),
    rel_paths
  )

  for (rel_path in rel_paths) {
    local_path <- file.path(src_dir, rel_path)
    if (!file.exists(local_path)) next

    local_hash <- compute_jsdelivr_hash(local_path)
    npm_path <- match_by_hash(local_hash, flat_files)
    if (!is.null(npm_path)) {
      sri_hash <- compute_sri_hash(local_path)
      results[[rel_path]] <- list(
        cdn_url = jsdelivr_cdn_url(dep$name, dep$version, npm_path),
        integrity = sri_hash
      )
    }
  }

  results
}

resolve_and_annotate <- function(dm, deps) {
  cache <- dm$cdn_cache

  for (dep in deps) {
    info <- collect_asset_ids(dep)
    if (!length(info$js_rel)) next

    cdn_results <- resolve_cdn(dep, info$js_rel)
    if (is.null(cdn_results)) next

    for (i in seq_along(info$js_rel)) {
      rel_path <- info$js_rel[[i]]
      asset_id <- info$js_ids[[i]]
      entry <- cdn_results[[rel_path]]
      if (!is.null(entry)) {
        cache[[asset_id]] <- entry
      }
    }
  }

  dm$cdn_cache <- cache
  dm
}
