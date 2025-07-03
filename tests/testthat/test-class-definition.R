test_that("empty manager is valid", {
  dm <- DependencyManager()
  expect_s4_class(dm, "DependencyManager")
})

test_that("error on unnamed registry entry", {
  bad <- list(htmltools::htmlDependency("foo", "1.0", src=""))
  names(bad) <- ""
  expect_error(
    new("DependencyManager", registry = bad),
    "All registry entries must be named"
  )
})

test_that("error on duplicate names", {
  dep1 <- htmltools::htmlDependency("foo", "1.0", src="")
  key <- dep_key(dep1)
  reg <- stats::setNames(list(dep1, dep1), c(key, key))
  expect_error(
    new("DependencyManager", registry = reg),
    "Registry names must be unique"
  )
})

test_that("error on non-htmlDependency in registry", {
  reg <- stats::setNames(list("not a dep"), "foo-1.0")
  expect_error(
    new("DependencyManager", registry = reg),
    "Registry contains non-htmlDependency values"
  )
})
