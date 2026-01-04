test_that("names<- updates registry names", {
  dep <- tmp_dependency(name = "a", version = "0.1")
  dm <- dm(insert(with_config_dm(), dep))
  names(dm) <- "b@0.2"
  expect_equal(names(dm), "b@0.2")
})

test_that("names() reflects registry keys", {
  deps <- list(
    tmp_dependency(name = "a", version = "1.2"),
    tmp_dependency(name = "b", version = "1.2")
  )
  dm <- dm(insert(with_config_dm(), deps))
  expect_equal(names(dm), vapply(deps, assetman:::make_dep_key, character(1)))
})
