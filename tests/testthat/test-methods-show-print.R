test_that("show() prints summary with keys", {
  dep <- tmp_dependency(name = "p", version = "0.1")
  dm1 <- dm(insert(with_config_dm(), dep))
  txt <- capture.output(show(dm1))
  expect_match(txt[1], "<DependencyManager> with 1 registered dependency:")
  expect_match(txt[2], "p@0.1")
})

test_that("print() returns invisibly", {
  dm <- DependencyManager()
  out <- capture.output(r <- print(dm))
  expect_equal(r, dm)
})
