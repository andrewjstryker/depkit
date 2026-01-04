test_that("insert registers assets and copies newly added files", {
  out <- tempfile("asset-out")
  dm <- DependencyManager(output_root = out, url_root = "/assets")

  dep <- tmp_dependency(css = c("styles/a.css", "styles/b.css"), js = c("js/a.js"))
  update <- insert(dm, dep)

  expect_s4_class(update, "InsertUpdate")
  expect_false(is_empty(update))
  expect_true(all(file.exists(file.path(out, c("styles/a.css", "styles/b.css", "js/a.js")))))

  dep_key <- assetman:::make_dep_key(dep)
  expect_equal(update@added_css, assetman:::make_asset_id(dep_key, c("styles/a.css", "styles/b.css")))
  expect_equal(update@added_js, assetman:::make_asset_id(dep_key, "js/a.js"))

  dm1 <- dm(update)
  expect_equal(dm1@css_assets, update@added_css)
  expect_equal(dm1@js_assets, update@added_js)

  css_tags <- emit_css(update)
  js_tags <- emit_js(update)
  expect_length(css_tags, 2)
  expect_length(js_tags, 1)
  expect_true(all(grepl("^<link", css_tags)))
  expect_true(all(grepl("^<script", js_tags)))
})

test_that("insert fails without config paths", {
  dm <- DependencyManager()
  dep <- tmp_dependency(js = "a.js")
  expect_error(insert(dm, dep), "config\\$output_root")
})

test_that("emit filters by keys in canonical order", {
  out <- tempfile("asset-out")
  dm <- DependencyManager(output_root = out, url_root = "/assets")

  dep1 <- tmp_dependency(name = "one", version = "1.0", css = "a.css", js = "a.js")
  dep2 <- tmp_dependency(name = "two", version = "1.0", css = c("b.css", "c.css"), js = c("b.js", "c.js"))

  u1 <- insert(dm, dep1)
  dm1 <- dm(u1)
  u2 <- insert(dm1, dep2)
  dm2 <- dm(u2)

  expect_equal(dm2@css_assets, c(assetman:::make_asset_id(assetman:::make_dep_key(dep1), "a.css"),
                                 assetman:::make_asset_id(assetman:::make_dep_key(dep2), c("b.css", "c.css"))))

  subset_keys <- dm2@css_assets[c(3, 1)]
  tags <- emit_css(dm2, keys = subset_keys)
  expect_length(tags, 2)
  expect_match(tags[[1]], "a.css")
  expect_match(tags[[2]], "c.css")

  expect_error(emit_js(dm2, keys = c("missing::file.js")), "Unknown asset ids")
})
