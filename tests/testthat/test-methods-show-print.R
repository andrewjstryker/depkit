test_that("show() prints summary", {
  dep <- htmltools::htmlDependency("p", "0.1", src="")
  dm <- DependencyManager(dep)
  txt <- capture.output(show(dm))
  expect_match(txt[1], "<DependencyManager> with 1 registered dependency:")
  expect_match(txt[2], "p@0.1")
})

test_that("print() returns invisibly", {
  dm <- DependencyManager()
  out <- capture.output(r <- print(dm))
  expect_equal(r, dm)
})
