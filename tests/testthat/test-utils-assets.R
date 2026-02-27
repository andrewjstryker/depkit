test_that("rtrim_slash trims single and multiple trailing slashes", {
  expect_equal(depkit:::rtrim_slash("http://a/"), "http://a")
  expect_equal(depkit:::rtrim_slash("http://a//"), "http://a")
  expect_equal(depkit:::rtrim_slash("http://a"), "http://a")
})

test_that("ordered_unique preserves first occurrence", {
  expect_equal(depkit:::ordered_unique(c("a", "b", "a", "c")), c("a", "b", "c"))
  expect_equal(depkit:::ordered_unique(character()), character())
})

test_that("append_unique_ordered appends only new elements", {
  res <- depkit:::append_unique_ordered(c("a", "b"), c("b", "c"))
  expect_equal(res$updated, c("a", "b", "c"))
  expect_equal(res$added, "c")
})

test_that("compute_sri_hash returns prefix", {
  tmp <- tempfile(fileext = ".js")
  writeLines("console.log(1);", tmp)
  sri <- depkit:::compute_sri_hash(tmp, "sha256")
  expect_true(startsWith(sri, "sha256-"))
})

test_that("compute_sri_hash sha384 default uses openssl path", {
  tmp <- tempfile(fileext = ".js")
  writeLines("console.log(1);", tmp)
  sri <- depkit:::compute_sri_hash(tmp)
  expect_true(startsWith(sri, "sha384-"))
  expect_true(nchar(sri) > 10)
})

test_that("dep_subdir returns name-version format", {
  dep <- htmltools::htmlDependency("foo", "2.3", src = tempfile())
  expect_equal(depkit:::dep_subdir(dep), "foo-2.3")
})

test_that("assets from different deps do not collide on disk", {
  out <- tempfile("collision-test")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets")
  dep1 <- tmp_dependency(name = "alpha", version = "1.0", js = "lib.js")
  dep2 <- tmp_dependency(name = "beta", version = "2.0", js = "lib.js")

  u1 <- insert(dm0, dep1)
  u2 <- insert(dm(u1), dep2)
  dm2 <- dm(u2)

  expect_true(file.exists(file.path(out, "alpha-1.0", "lib.js")))
  expect_true(file.exists(file.path(out, "beta-2.0", "lib.js")))

  recs1 <- depkit:::build_asset_records(dm2, dm2$js_assets[1], "js")
  recs2 <- depkit:::build_asset_records(dm2, dm2$js_assets[2], "js")
  expect_false(recs1[[1]]$dest_path == recs2[[1]]$dest_path)
  expect_false(recs1[[1]]$url == recs2[[1]]$url)
})

test_that("build_asset_records derives paths and urls", {
  out <- tempfile("asset-out")
  dm0 <- DependencyManager(output_root = out, url_root = "/public")
  dep <- tmp_dependency(name = "rec", version = "1.0", js = "a.js", css = "b.css")
  dm1 <- dm(insert(dm0, dep))

  recs_css <- depkit:::build_asset_records(dm1, dm1$css_assets, "css")
  recs_js <- depkit:::build_asset_records(dm1, dm1$js_assets, "js")

  expect_equal(recs_css[[1]]$url, "/public/rec-1.0/b.css")
  expect_equal(recs_js[[1]]$url, "/public/rec-1.0/a.js")
  expect_equal(basename(recs_js[[1]]$dest_path), "a.js")
})

# -- dependency_source_dir with package field ---------------------------------

test_that("dependency_source_dir resolves path via package field", {
  dep <- list(
    src = "fill",
    package = "htmltools"
  )
  result <- depkit:::dependency_source_dir(dep)
  expect_true(dir.exists(result))
  expect_match(result, "htmltools/fill", fixed = TRUE)
})

test_that("dependency_source_dir errors for bad package path", {
  dep <- list(
    src = "nonexistent_dir",
    package = "htmltools"
  )
  expect_error(
    depkit:::dependency_source_dir(dep),
    "Cannot locate dependency source directory"
  )
})

# -- flatten_asset_spec with list-of-descriptor inputs ------------------------

test_that("flatten_asset_spec handles script descriptors in a list", {
  extractor <- function(x) {
    fn <- x[["src"]]
    if (is.null(fn) || !nzchar(fn)) stop("Script descriptor missing 'src'", call. = FALSE)
    fn
  }
  spec <- list(list(src = "lib.js"), "app.js")
  result <- depkit:::flatten_asset_spec(spec, extractor, "script")
  expect_equal(result, c("lib.js", "app.js"))
})

test_that("flatten_asset_spec handles stylesheet descriptors in a list", {
  extractor <- function(x) {
    fn <- x[["href"]]
    if (is.null(fn) || !nzchar(fn)) stop("Stylesheet descriptor missing 'href'", call. = FALSE)
    fn
  }
  spec <- list(list(href = "style.css"), "base.css")
  result <- depkit:::flatten_asset_spec(spec, extractor, "stylesheet")
  expect_equal(result, c("style.css", "base.css"))
})

test_that("flatten_asset_spec handles NULL elements in a list", {
  extractor <- function(x) x[["src"]]
  spec <- list(NULL, list(src = "x.js"), "y.js")
  result <- depkit:::flatten_asset_spec(spec, extractor, "script")
  expect_equal(result, c("x.js", "y.js"))
})

test_that("flatten_asset_spec errors on descriptor missing required key", {
  extractor <- function(x) {
    fn <- x[["src"]]
    if (is.null(fn) || !nzchar(fn)) stop("Script descriptor missing 'src'", call. = FALSE)
    fn
  }
  spec <- list(list(href = "wrong_key.js"))
  expect_error(
    depkit:::flatten_asset_spec(spec, extractor, "script"),
    "Script descriptor missing 'src'"
  )
})
