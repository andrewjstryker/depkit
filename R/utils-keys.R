make_dep_key <- function(dep) {
  if (!inherits(dep, "html_dependency")) {
    stop("Expected html_dependency", call. = FALSE)
  }
  if (is.null(dep$name) || is.null(dep$version)) {
    stop("Dependency must have name and version", call. = FALSE)
  }
  assert_scalar_character(dep$name, "dep$name")
  assert_scalar_character(dep$version, "dep$version")
  paste0(dep$name, "@", dep$version)
}

make_asset_id <- function(dep_key, rel_path) {
  assert_scalar_character(dep_key, "dep_key")
  if (!is.character(rel_path) || any(is.na(rel_path))) {
    stop("rel_path must be a non-missing character vector", call. = FALSE)
  }
  paste0(dep_key, "::", rel_path)
}

parse_asset_id <- function(asset_id) {
  assert_scalar_character(asset_id, "asset_id")
  parts <- strsplit(asset_id, "::", fixed = TRUE)[[1]]
  if (length(parts) != 2 || !nzchar(parts[1]) || !nzchar(parts[2])) {
    stop("Invalid asset_id format; expected '<dep_key>::<rel_path>'", call. = FALSE)
  }
  list(dep_key = parts[1], rel_path = parts[2])
}
