tmp_dependency <- function(name = "dep", version = "1.0", css = NULL, js = NULL) {
  src_dir <- tempfile("dep-src")
  dir.create(src_dir, recursive = TRUE)

  if (length(css)) {
    for (path in css) {
      dest <- file.path(src_dir, path)
      dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      writeLines("body {}", dest)
    }
  }

  if (length(js)) {
    for (path in js) {
      dest <- file.path(src_dir, path)
      dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      writeLines("console.log('hi');", dest)
    }
  }

  htmltools::htmlDependency(
    name = name,
    version = version,
    src = c(file = src_dir),
    stylesheet = css,
    script = js
  )
}

with_config_dm <- function(...) {
  DependencyManager(
    output_root = tempfile("assets-out"),
    url_root = "/assets",
    ...
  )
}
