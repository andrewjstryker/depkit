test_that("DependencyManager defaults are valid and empty", {
  dm <- DependencyManager()
  expect_s3_class(dm, "dependency_manager")
  expect_equal(length(dm$registry), 0)
  expect_equal(dm$css_assets, character())
  expect_equal(dm$js_assets, character())
  expect_equal(dm$config$cdn_mode, "off")
})

test_that("DependencyManager validates registry names and types", {
  dep <- htmltools::htmlDependency("foo", "1.0", src = tempfile())
  bad_names <- stats::setNames(list(dep), "")
  expect_error(depkit:::new_dependency_manager(registry = bad_names), "named with non-empty")

  dup_key <- make_dep_key(dep)
  dup_reg <- stats::setNames(list(dep, dep), c(dup_key, dup_key))
  expect_error(depkit:::new_dependency_manager(registry = dup_reg), "unique")

  non_dep <- list(not = "a_dep")
  expect_error(depkit:::new_dependency_manager(registry = non_dep), "html_dependency")
})

test_that("DependencyManager rejects invalid cdn_mode", {
  expect_error(
    DependencyManager(cdn_mode = "bogus"),
    "cdn_mode"
  )
})

test_that("DependencyManager rejects vector-length config paths", {
  expect_error(
    depkit:::new_dependency_manager(config = list(
      output_root = c("/a", "/b"), url_root = "/x", cdn_mode = "off"
    )),
    "length-1"
  )
})

test_that("InsertUpdate deduplicates silently", {
  dm <- DependencyManager()
  iu <- depkit:::InsertUpdate(dm = dm, added_css = c("a", "a"), added_js = character())
  expect_equal(iu$added_css, "a")

  iu2 <- depkit:::InsertUpdate(dm = dm, added_css = character(), added_js = c("b", "b"))
  expect_equal(iu2$added_js, "b")
})
