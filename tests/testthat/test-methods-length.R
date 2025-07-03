test_that("length() reflects registry", {
  deps <- list(
    htmltools::htmlDependency("a", "1.2", src=""),
    htmltools::htmlDependency("b", "1.2", src=""),
    htmltools::htmlDependency("c", "1.2", src="")
  )

  dm <- DependencyManager(deps)

  expect_length(dm, length(deps))
})

test_that("length() handles empty registry", {
  dm <- DependencyManager()
  expect_length(dm, 0)
})