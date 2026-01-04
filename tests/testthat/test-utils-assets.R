test_that("rtrim_slash trims single and multiple trailing slashes", {
  expect_equal(assetman:::rtrim_slash("http://a/"), "http://a")
  expect_equal(assetman:::rtrim_slash("http://a//"), "http://a")
  expect_equal(assetman:::rtrim_slash("http://a"), "http://a")
})

test_that("ordered_unique preserves first occurrence", {
  expect_equal(assetman:::ordered_unique(c("a", "b", "a", "c")), c("a", "b", "c"))
  expect_equal(assetman:::ordered_unique(character()), character())
})

test_that("append_unique_ordered appends only new elements", {
  res <- assetman:::append_unique_ordered(c("a", "b"), c("b", "c"))
  expect_equal(res$updated, c("a", "b", "c"))
  expect_equal(res$added, "c")
})

test_that("compute_sri_hash returns prefix", {
  tmp <- tempfile(fileext = ".js")
  writeLines("console.log(1);", tmp)
  sri <- assetman:::compute_sri_hash(tmp, "sha256")
  expect_true(startsWith(sri, "sha256-"))
})

test_that("build_asset_records derives paths and urls", {
  out <- tempfile("asset-out")
  dm0 <- DependencyManager(output_root = out, url_root = "/public")
  dep <- tmp_dependency(name = "rec", version = "1.0", js = "a.js", css = "b.css")
  dm1 <- dm(insert(dm0, dep))

  recs_css <- assetman:::build_asset_records(dm1, dm1@css_assets, "css")
  recs_js <- assetman:::build_asset_records(dm1, dm1@js_assets, "js")

  expect_equal(recs_css[[1]]$url, "/public/b.css")
  expect_equal(recs_js[[1]]$url, "/public/a.js")
  expect_equal(basename(recs_js[[1]]$dest_path), "a.js")
})
