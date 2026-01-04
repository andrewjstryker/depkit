test_that("insert(html_dependency) is idempotent and returns InsertUpdate", {
  dep <- tmp_dependency(name = "lib", version = "2.0", js = "a.js")
  dm0 <- with_config_dm()
  u1 <- insert(dm0, dep)
  expect_s4_class(u1, "InsertUpdate")
  dm1 <- dm(u1)

  expect_equal(u1@added_js, assetman:::make_asset_id(assetman:::make_dep_key(dep), "a.js"))
  expect_equal(dm1@js_assets, u1@added_js)

  u2 <- insert(dm1, dep)
  expect_true(is_empty(u2))
  expect_identical(dm(u2)@js_assets, dm1@js_assets)
})

test_that("insert(htmlwidget) registers dependencies and copies only new assets", {
  dm0 <- with_config_dm()
  dep1 <- tmp_dependency(name = "lib", version = "1.0", js = c("a.js", "b.js"))
  w <- htmlwidgets::createWidget("test", list(), package = "htmltools")
  attr(w, "html_dependencies") <- list(dep1)

  u <- insert(dm0, w)
  dm1 <- dm(u)

  expect_setequal(dm1@js_assets, assetman:::make_asset_id(assetman:::make_dep_key(dep1), c("a.js", "b.js")))
  expect_true(all(file.exists(file.path(dm1@config$output_root, c("a.js", "b.js")))))
})

test_that("insert normalizes list input", {
  dm0 <- with_config_dm()
  dep1 <- tmp_dependency(name = "one", version = "1.0", css = "a.css")
  dep2 <- tmp_dependency(name = "two", version = "1.0", js = "b.js")

  u <- insert(dm0, list(dep1, dep2))
  dm1 <- dm(u)
  expect_length(dm1@registry, 2)
  expect_length(dm1@css_assets, 1)
  expect_length(dm1@js_assets, 1)
})
