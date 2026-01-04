test_that("length reflects registry size", {
  deps <- list(
    tmp_dependency(name = "a", version = "1.0"),
    tmp_dependency(name = "b", version = "1.0")
  )
  dm <- dm(insert(with_config_dm(), deps))
  expect_length(dm, 2)
})

test_that("length handles empty registry", {
  dm <- with_config_dm()
  expect_length(dm, 0)
})
