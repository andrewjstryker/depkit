test_that("insert(htmlDependency) adds exactly once", {
  dep <- htmltools::htmlDependency("lib", "2.0", src="")
  dm0 <- DependencyManager()
  dm1 <- insert(dm0, dep)
  dm2 <- insert(dm1, dep)
  expect_length(dm1, 1)
  expect_identical(dm2, dm1)  # idempotent
})

test_that("insert(htmlwidget) registers its dependencies", {
  dep <- htmltools::htmlDependency("lib", "2.0", src = "")
  w   <- htmlwidgets::createWidget("test", x = list(), package = "htmltools")
  # now inject it:
  attr(w, "html_dependencies") <- list(dep)

  dm <- DependencyManager(w)

  expect_length(length(htmltools::htmlDependencies(w)), 1)

  for (hd in htmltools::htmlDependencies(w)) {
    expect_true(has(dm, dep_key(hd)))
  }
})

test_that("remove(list) handles mixed inputs", {
  dep1 <- htmltools::htmlDependency("a", "1.0", src="")
  dep2 <- htmltools::htmlDependency("b", "2.0", src="")
  dep3 <- htmltools::htmlDependency("c", "3.0", src="")

  w <- htmlwidgets::createWidget("t", list(), package="htmltools")
  attr(w, "html_dependencies") <- list(dep1, dep2)

  dm <- DependencyManager(list(dep3, w))

  for (d in list(dep3, w)) {
    expect_true(has(dm, d))
  }
})