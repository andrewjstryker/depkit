#' @keywords internal
`%||%` <- function(a, b) if (!is.null(a)) a else b

ordered_unique <- function(x) {
  if (!length(x)) return(character())
  x_chr <- as.character(x)
  x_chr[!duplicated(x_chr)]
}

assert_scalar_character <- function(x, label) {
  if (length(x) != 1 || !is.character(x) || is.na(x)) {
    stop(label, " must be a non-missing character(1)", call. = FALSE)
  }
  x
}

assert_config_paths <- function(cfg) {
  if (!length(cfg$output_root) || !nzchar(cfg$output_root)) {
    stop("config$output_root must be provided", call. = FALSE)
  }
  if (!length(cfg$url_root) || !nzchar(cfg$url_root)) {
    stop("config$url_root must be provided", call. = FALSE)
  }
  invisible(cfg)
}

join_path <- function(base, rel) {
  rel <- gsub("^[/\\\\]+", "", rel)
  normalizePath(file.path(base, rel), winslash = "/", mustWork = FALSE)
}

ensure_dir <- function(path) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  path
}
