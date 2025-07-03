
test_that("names<-() updates and re-validates", {
  dep <- htmltools::htmlDependency("a", "0.1", src="")
  dm <- DependencyManager(dep)
  names(dm) <- "b-0.2"
  expect_equal(names(dm), "b-0.2")
})

test_that("names() reflects registry", {
  deps <- list(
    htmltools::htmlDependency("a", "1.2", src=""),
    htmltools::htmlDependency("b", "1.2", src=""),
    htmltools::htmlDependency("c", "1.2", src="")
  )

  dm <- DependencyManager(deps)

  expect_equal(
    names(dm),
    vapply(
      deps,
      dep_key,
      character(1)
    )
  )
})