
#' Remove trailing slashes from a URL
#' @param x Character vector of URLs
#' @return Character vector with no trailing slash
rtrim_slash <- function(x) {
  sub("/+$", "", x)
}

# Utility: coalesce NULL
`%||%` <- function(a, b) if (!is.null(a)) a else b

#' Compute Subresource Integrity (SRI) hash for a local file
#'
#' @param path Path to local asset file
#' @param algo Hash algorithm ("sha256", "sha384", "sha512")
#' @return SRI string (e.g. "sha384-<base64hash>")
#' @importFrom digest digest
#' @importFrom base64enc base64encode
compute_sri_hash <-
  function(path, algo = c("sha256", "sha512")) {
    algo <- match.arg(algo, c("sha256", "sha512"))
    raw_hash <- digest::digest(path, algo = algo, file = TRUE, raw = TRUE)
    b64 <- base64enc::base64encode(raw_hash)
    paste0(algo, "-", b64)
  }


#' Copy dependency asset to a local directory
#'
#' @param dep htmlDependency-like object with fields 'src' and 'script' or 'stylesheet'
#' @param output_dir Directory to copy asset into
#' @return File path to the copied asset
copy_dependency_asset <-
  function(dep, output_dir) {
    if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
    fname <- dep$script %||% dep$stylesheet
    src_path <- file.path(dep$src, fname)
    dest_path <- file.path(output_dir, fname)
    file.copy(src_path, dest_path, overwrite = TRUE)
    normalizePath(dest_path, winslash = "/", mustWork = TRUE)
  }

#' Build-time: locate and verify CDN asset, compute SRI, prepare metadata
#'
#' Fetches CDN HEAD and GET (via injectable functions) to verify content matches local asset.
#' Warns on mismatch and falls back to local only.
#'
#' @param dep htmlDependency-like object
#' @param cdn_bases Character vector of CDN base URLs
#' @param output_dir Local directory for fallback assets
#' @param integrity_algo Hash algorithm for SRI
#' @param head_fun Function(url, timeout) performing HEAD request (default uses httr::HEAD)
#' @param fetch_fun Function(url, timeout) performing GET request (default uses httr::GET)
#' @param head_timeout Timeout in seconds for HEAD requests
#' @param fetch_timeout Timeout in seconds for GET requests
#' @return List with elements:
#'   * cdn_url   - first valid CDN URL (NULL if none or mismatch)
#'   * local_url - local asset URL/path
#'   * integrity - SRI string for use in HTML tags
#' @importFrom httr timeout
prepare_dependency_metadata <-
  function(
    dep,
    cdn_bases = character(),
    output_dir,
    integrity_algo = "sha384",
    head_fun = function(url, timeout) httr::HEAD(url, httr::timeout(timeout)),
    fetch_fun = function(url, timeout) httr::GET(url, httr::timeout(timeout)),
    head_timeout = 2,
    fetch_timeout = 5
  ) {
    # Copy local asset and compute its hash
    local_url <- copy_dependency_asset(dep, output_dir)
    integrity <- compute_sri_hash(local_url, integrity_algo)

    # Attempt to locate and verify CDN asset
    cdn_url <- NULL
    fname <- dep$script %||% dep$stylesheet
    for (base in cdn_bases) {
      candidate <- paste0(rtrim_slash(base), "/", fname)
      head_res <- try(head_fun(candidate, head_timeout), silent = TRUE)
      if (inherits(head_res, "response") && head_res$status_code < 400) {
        get_res <- try(fetch_fun(candidate, fetch_timeout), silent = TRUE)
        if (inherits(get_res, "response") && get_res$status_code < 400) {
          cdn_bytes <- httr::content(get_res, "raw")
          cdn_hash  <- digest::digest(cdn_bytes, algo = integrity_algo, raw = TRUE)
          local_hash <- base64enc::base64decode(sub("^.*-", "", integrity))
          if (identical(cdn_hash, local_hash)) {
            cdn_url <- candidate
            break
          } else {
            warning("Integrity mismatch for CDN asset; falling back to local only: ", candidate)
          }
        }
      }
    }

    list(
      cdn_url   = cdn_url,
      local_url = local_url,
      integrity = integrity
    )
  }

#' Format JavaScript <script> tags at run-time using prepared metadata
#'
#' @param meta List from prepare_dependency_metadata()
#' @param timeout_ms Milliseconds before inline fallback (0 to disable)
#' @param fallback_check JS expression to detect load failure
#' @param cors CORS mode ("anonymous" or "use-credentials", NULL to omit)
#' @return Character vector of HTML <script> tags
format_js_tags <-
  function(
    meta,
    timeout_ms = 0,
    fallback_check = NULL,
    cors = "anonymous"
  ) {
    tags <- character()
    if (!is.null(meta$cdn_url)) {
      attrs <- c(
        sprintf('src="%s"', meta$cdn_url),
        sprintf('integrity="%s"', meta$integrity),
        if (!is.null(cors)) sprintf('crossorigin="%s"', cors),
        sprintf('onerror="this.onerror=null;this.src=\'%s\';"', meta$local_url)
      )
      tags <- c(tags, sprintf('<script %s></script>', paste(attrs, collapse = " ")))

      if (timeout_ms > 0 && !is.null(fallback_check)) {
        js <- sprintf(
          'setTimeout(function(){if(typeof %s === "undefined"){var s=document.createElement("script");s.src="%s";document.head.appendChild(s);}}, %d);',
          fallback_check, meta$local_url, timeout_ms
        )
        tags <- c(tags, sprintf('<script>%s</script>', js))
      }
    } else {
      tags <- sprintf('<script src="%s"></script>', meta$local_url)
    }
    tags
  }

#' Format CSS <link> tags at run-time using prepared metadata
#'
#' @param meta List from prepare_dependency_metadata()
#' @return Character vector of HTML <link> tags
format_css_tags <-
  function(meta) {
    attrs <- c(
      'rel="stylesheet"',
      sprintf('href="%s"', meta$local_url),
      sprintf('integrity="%s"', meta$integrity)
    )
    sprintf('<link %s/>', paste(attrs, collapse = " "))
  }
