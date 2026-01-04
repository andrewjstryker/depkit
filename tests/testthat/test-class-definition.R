test_that("DependencyManager defaults are valid and empty", {
  dm <- DependencyManager()
  expect_s4_class(dm, "DependencyManager")
  expect_equal(length(dm@registry), 0)
  expect_equal(dm@css_assets, character())
  expect_equal(dm@js_assets, character())
  expect_equal(dm@config$cdn_mode, "off")
})

test_that("DependencyManager validates registry names and types", {
  dep <- htmltools::htmlDependency("foo", "1.0", src = tempfile())
  bad_names <- stats::setNames(list(dep), "")
  expect_error(new("DependencyManager", registry = bad_names), "named with non-empty")

  dup_key <- make_dep_key(dep)
  dup_reg <- stats::setNames(list(dep, dep), c(dup_key, dup_key))
  expect_error(new("DependencyManager", registry = dup_reg), "unique")

  non_dep <- list(not = "a_dep")
  expect_error(new("DependencyManager", registry = non_dep), "html_dependency")
})

test_that("InsertUpdate enforces uniqueness", {
  dm <- DependencyManager()
  expect_error(new("InsertUpdate", dm = dm, added_css = c("a", "a"), added_js = character()), "added_css must be unique")
  expect_error(new("InsertUpdate", dm = dm, added_css = character(), added_js = c("b", "b")), "added_js must be unique")
})
