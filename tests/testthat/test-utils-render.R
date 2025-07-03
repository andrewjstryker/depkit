  library(testthat)
library(digest)
library(base64enc)
# assume your functions are in R/dep_utils.R or similar:
# source("R/dep_utils.R")

test_that("rtrim_slash removes one or many trailing slashes", {
  expect_equal(rtrim_slash("foo/"),  "foo")
  expect_equal(rtrim_slash("foo//"), "foo")
  expect_equal(rtrim_slash("foo"),   "foo")
  expect_equal(rtrim_slash(c("a/","b//","c")), c("a","b","c"))
})

test_that("%||% returns left if not NULL, otherwise right", {
  expect_equal(NULL %||% "b",  "b")
  expect_equal("a"  %||% "b",  "a")
  expect_equal(0    %||% 42,   0)
})

test_that("compute_sri_hash returns the correct base64-encoded prefix", {
  # Create a tiny temp file
  tmp <- tempfile()
  writeLines("hello world", tmp)
  # manually compute expected
  raw_hash <- digest(tmp, algo = "sha256", file = TRUE, raw = TRUE)
  expected <- paste0("sha256-", base64encode(raw_hash))
  expect_equal(compute_sri_hash(tmp, algo = "sha256"), expected)
  # default algo is sha256 and prefix is correct
  sri <- compute_sri_hash(tmp)
  expect_true(startsWith(sri, "sha256-"))
})

test_that("copy_dependency_asset creates output dir, copies file, returns normalized path", {
  src_dir <- tempfile()
  dir.create(src_dir)
  fname <- "foo.txt"
  writeLines("xyz", file.path(src_dir, fname))
  dep <- list(src = src_dir, script = fname)
  out_dir <- tempfile()
  meta_path <- copy_dependency_asset(dep, out_dir)
  expect_true(dir.exists(out_dir))
  expect_true(file.exists(meta_path))
  # on all platforms uses forward slash
  expect_match(meta_path, "/foo.txt$")
})

test_that("prepare_dependency_metadata with no CDN just falls back to local", {
  src_dir <- tempfile()
  dir.create(src_dir)
  fname <- "bar.js"
  writeLines("console.log(1);", file.path(src_dir, fname))
  dep <- list(src = src_dir, script = fname)
  out_dir <- tempfile()
  meta <- prepare_dependency_metadata(
    dep,
    cdn_bases    = character(0),
    output_dir   = out_dir,
    integrity_algo = "sha256"
  )
  expect_null(meta$cdn_url)
  expect_true(file.exists(meta$local_url))
  expect_true(startsWith(meta$integrity, "sha256-"))
})

test_that("format_js_tags outputs correct tags when no CDN", {
  meta <- list(cdn_url = NULL, local_url = "local.js", integrity = "sha256-AAA")
  tag <- format_js_tags(meta)
  expect_length(tag, 1)
  expect_equal(tag, '<script src="local.js"></script>')
})

test_that("format_js_tags outputs CDN tag with integrity, crossorigin, onerror", {
  meta <- list(
    cdn_url   = "https://cdn/foo.js",
    local_url = "local/foo.js",
    integrity = "sha384-BBB"
  )
  tag <- format_js_tags(meta)
  expect_length(tag, 1)
  expect_match(tag,
               '<script .*src="https://cdn/foo.js".*integrity="sha384-BBB".*crossorigin="anonymous".*onerror="this\\.onerror=null;this\\.src=\\\'local/foo\\.js\\\';".*></script>')
})

test_that("format_js_tags with timeout_ms and fallback_check adds second inline script", {
  meta <- list(
    cdn_url   = "https://cdn/lib.js",
    local_url = "local/lib.js",
    integrity = "sha384-CCC"
  )
  tags <- format_js_tags(meta, timeout_ms = 100, fallback_check = "MyLib")
  expect_length(tags, 2)
  # second tag is inline JS
  expect_match(tags[2], "<script>setTimeout\\(")
  expect_match(tags[2], "MyLib")
  expect_match(tags[2], "local/lib.js")
})

test_that("format_css_tags returns a single <link> with rel, href, integrity", {
  meta <- list(local_url = "styles.css", integrity = "sha256-DDD")
  tag <- format_css_tags(meta)
  expect_equal(tag,
               '<link rel="stylesheet" href="styles.css" integrity="sha256-DDD"/>')
})

test_that("locate_dependency_cdn returns NA when no CDN bases supplied", {
  files <- c("foo.js", "bar.css")
  expect_equal(
    locate_dependency_cdn(files, cdn_bases = character()),
    rep(NA_character_, length(files))
  )
})

test_that("locate_dependency_cdn builds URLs from first CDN base", {
  files <- c("/path/to/a.js", "subdir/b.css")
  base1 <- "https://cdn.example.org/assets"
  base2 <- "https://other.cdn/"
  out <- locate_dependency_cdn(files, cdn_bases = c(base1, base2))

  expect_equal(
    out,
    c(
      "https://cdn.example.org/assets/a.js",
      "https://cdn.example.org/assets/b.css"
    )
  )
})

test_that("locate_dependency_cdn trims trailing slash on CDN base", {
  file <- "script.min.js"
  base_with_slash <- "https://cdn.example.org/lib/"
  expect_equal(
    locate_dependency_cdn(file, cdn_bases = base_with_slash),
    "https://cdn.example.org/lib/script.min.js"
  )
})

