test_that("character signature is fully vectorized", {
  dm <- DependencyManager()

  # empty vector → empty result
  expect_equal(has(dm, character(0)), logical(0))

  # none registered → all FALSE
  names <- c("foo@1.0", "bar@2.0")
  expect_equal(has(dm, names), c(FALSE, FALSE))

  # insert one dependency by name
  dm2 <- insert(dm, htmltools::htmlDependency("foo", "1.0", src = tempfile()))
  expect_equal(has(dm2, names), c(TRUE, FALSE))
})

test_that("html_dependency signature delegates to character()", {
  dm <- DependencyManager()
  dep <- htmltools::htmlDependency("alpha", "0.1", src = tempfile())

  # before insert: single FALSE
  out1 <- has(dm, dep)
  expect_length(out1, 1)
  expect_false(out1)

  # after insert: single TRUE
  dm2 <- insert(dm, dep)
  out2 <- has(dm2, dep)
  expect_length(out2, 1)
  expect_true(out2)
})

test_that("htmlwidget signature returns scalar based on all dependencies", {
  dm <- DependencyManager()

  #--- create two HTML dependencies
  dep1 <- htmltools::htmlDependency("one", "1.0", src = tempfile())
  dep2 <- htmltools::htmlDependency("two", "2.0", src = tempfile())

  #--- build a widget that carries exactly those two deps
  w <- htmlwidgets::createWidget(
    name         = "testwidget",
    x            = list(),
    package      = "htmltools"
  )

  # hack to add dependencies
  attr(w, "html_dependencies") <- list(dep1, dep2)

  deps <- htmltools::htmlDependencies(w)
  expect_length(deps, 2)
  expect_identical(deps, list(dep1, dep2))

  # none inserted → FALSE
  expect_false(has(dm, w))

  # insert just the first dependency → still FALSE
  dm1 <- insert(dm, deps[[1]])
  expect_false(has(dm1, w))

  # insert *all* dependencies → TRUE
  dm_all <- insert(dm, deps)
  expect_true(has(dm_all, w))
})

test_that("list signature recurses and vectorizes over mixed inputs", {
  dm <- DependencyManager()
  dep1 <- htmltools::htmlDependency("one", "1.0", src = tempfile())
  dep2 <- htmltools::htmlDependency("two", "1.0", src = tempfile())
  w <- htmlwidgets::createWidget("widgetX", list(), package = "htmltools")
  attr(w, "html_dependencies") <- list(dep1, dep2)

  # insert only dep1
  dm1 <- insert(dm, dep1)

  lst <- list(
    "one@1.0", # character name
    dep1, # html_dependency
    dep2, # html_dependency (not inserted)
    w # htmlwidget (no deps inserted)
  )
  expect_equal(has(dm1, lst), c(TRUE, TRUE, FALSE, FALSE))
})

test_that("empty list input returns logical(0)", {
  dm <- DependencyManager()
  expect_equal(has(dm, list()), logical(0))
})

test_that("unsupported types throw a clear error", {
  dm <- DependencyManager()
  expect_error(
    has(dm, 123),
    "Unsupported type for 'dep'"
  )
})
