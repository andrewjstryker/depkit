test_that("make_dep_key concatenates name and version with @", {
  dep <- htmltools::htmlDependency("abc", "2.3.4", src = tempfile())
  expect_equal(assetman:::make_dep_key(dep), "abc@2.3.4")
})

test_that("make_asset_id builds vectorized ids", {
  ids <- assetman:::make_asset_id("x@1.0", c("a.js", "b.css"))
  expect_equal(ids, c("x@1.0::a.js", "x@1.0::b.css"))
})

test_that("make_asset_id errors on NA rel_path", {
  expect_error(assetman:::make_asset_id("x@1.0", NA_character_), "non-missing character vector")
})

test_that("parse_asset_id returns components and validates format", {
  parts <- assetman:::parse_asset_id("lib@1.0::path/file.js")
  expect_equal(parts$dep_key, "lib@1.0")
  expect_equal(parts$rel_path, "path/file.js")
  expect_error(assetman:::parse_asset_id("badformat"), "Invalid asset_id format")
})
