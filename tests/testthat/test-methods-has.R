test_that("character signature is vectorized", {
  dm <- with_config_dm()
  expect_equal(has(dm, character()), logical(0))

  keys <- c("foo@1.0", "bar@2.0")
  expect_equal(has(dm, keys), c(FALSE, FALSE))

  dep <- tmp_dependency(name = "foo", version = "1.0")
  dm2 <- dm(insert(dm, dep))
  expect_equal(has(dm2, keys), c(TRUE, FALSE))
})

test_that("html_dependency signature delegates to character()", {
  dm <- with_config_dm()
  dep <- tmp_dependency(name = "alpha", version = "0.1")

  expect_false(has(dm, dep))
  dm2 <- dm(insert(dm, dep))
  expect_true(has(dm2, dep))
})

test_that("htmlwidget signature checks all deps", {
  dm <- with_config_dm()
  dep1 <- tmp_dependency(name = "one", version = "1.0")
  dep2 <- tmp_dependency(name = "two", version = "1.0")
  w <- htmlwidgets::createWidget("widgetX", list(), package = "htmltools")
  attr(w, "html_dependencies") <- list(dep1, dep2)

  expect_false(has(dm, w))
  dm1 <- dm(insert(dm, dep1))
  expect_false(has(dm1, w))
  dm_all <- dm(insert(dm, list(dep1, dep2)))
  expect_true(has(dm_all, w))
})

test_that("list signature recurses", {
  dm <- with_config_dm()
  dep1 <- tmp_dependency(name = "one", version = "1.0")
  dep2 <- tmp_dependency(name = "two", version = "1.0")
  w <- htmlwidgets::createWidget("widgetY", list(), package = "htmltools")
  attr(w, "html_dependencies") <- list(dep1, dep2)

  dm1 <- dm(insert(dm, dep1))

  lst <- list("one@1.0", dep1, dep2, w)
  expect_equal(has(dm1, lst), c(TRUE, TRUE, FALSE, FALSE))
})

test_that("unsupported types throw", {
  dm <- with_config_dm()
  expect_error(has(dm, 123), "Unsupported type")
})
