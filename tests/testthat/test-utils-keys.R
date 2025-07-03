test_that("dep_key() concatenates name and version with '@' separator", {
  dep <- htmltools::htmlDependency("abc", "2.3.4", src = "")
  expect_equal(dep_key(dep), "abc@2.3.4")
})


test_that("key_components() splits key into name and version", {
  key <- "xyz@1.0.0"
  comps <- key_components(key)
  expect_equal(comps$name, "xyz")
  expect_equal(comps$version, "1.0.0")
})


test_that("key_components() errors on invalid key format", {
  expect_error(key_components("invalid-key"), "Invalid key format")
  expect_error(key_components("too@many@separators"), "Invalid key format")
})