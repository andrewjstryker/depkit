test_that("names<- updates registry names", {
  dep <- tmp_dependency(name = "a", version = "0.1")
  dm1 <- dm(insert(with_config_dm(), dep))
  names(dm1) <- "b@0.2"
  expect_equal(names(dm1), "b@0.2")
})

test_that("names<- errors on length mismatch", {
  dep <- tmp_dependency(name = "a", version = "0.1")
  dm1 <- dm(insert(with_config_dm(), dep))
  expect_error(names(dm1) <- c("x", "y"), "same length")
})

test_that("names() reflects registry keys", {
  deps <- list(
    tmp_dependency(name = "a", version = "1.2"),
    tmp_dependency(name = "b", version = "1.2")
  )
  dm1 <- dm(insert(with_config_dm(), deps))
  expect_equal(names(dm1), vapply(deps, depkit:::make_dep_key, character(1)))
})
