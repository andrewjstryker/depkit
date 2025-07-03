test_that("remove(character) drops entries", {
  dep <- htmltools::htmlDependency("rm", "3.0", src="")
  dm <- DependencyManager(dep)
  key <- dep_key(dep)
  dm2 <- remove(dm, key)
  expect_length(dm2, 0)
})

test_that("remove(htmlDependency) works", {
  dep <- htmltools::htmlDependency("foo", "4.5", src="")
  key <- dep_key(dep)
  dm <- DependencyManager(dep)
  dm2 <- remove(dm, dep)
  expect_false(has(dm2, key))
})

test_that("remove(htmlwidget) works", {
  dep <- htmltools::htmlDependency("lib", "2.0", src = "")
  w   <- htmlwidgets::createWidget("test", x = list(), package = "htmltools")
  # now inject it:
  attr(w, "html_dependencies") <- list(dep)

  dm <- DependencyManager(w)

  expect_length(length(htmltools::htmlDependencies(w)), 1)

  for (hd in htmltools::htmlDependencies(w)) {
    expect_true(has(dm, dep_key(hd)))
  }

  dm <- DependencyManager(w)
  dm2 <- remove(dm, w)
  expect_false(has(dm2, w))
})

test_that("remove(list) handles mixed inputs", {
  dep1 <- htmltools::htmlDependency("a", "1.0", src="")
  dep2 <- htmltools::htmlDependency("b", "2.0", src="")
  dep3 <- htmltools::htmlDependency("c", "3.0", src="")

  w <- htmlwidgets::createWidget("t", list(), package="htmltools")
  attr(w, "html_dependencies") <- list(dep1, dep2)

  dm <- DependencyManager(list(dep3, w))
  dm2 <- remove(dm, list(dep3, w))
  expect_length(dm2, 0)
})

test_that("remove non-existent key errors", {
  dm <- DependencyManager()
  expect_error(remove(dm, "nope-0.1"))
})