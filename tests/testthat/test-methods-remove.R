test_that("remove(character) drops entries and assets", {
  dep <- tmp_dependency(name = "rm", version = "3.0", js = "a.js")
  u <- insert(with_config_dm(), dep)
  dm1 <- dm(u)
  key <- assetman:::make_dep_key(dep)
  dm2 <- remove(dm1, key)
  expect_length(dm2, 0)
  expect_equal(dm2@js_assets, character())
})

test_that("remove(html_dependency) works", {
  dep <- tmp_dependency(name = "foo", version = "4.5")
  dm1 <- dm(insert(with_config_dm(), dep))
  dm2 <- remove(dm1, dep)
  expect_false(has(dm2, assetman:::make_dep_key(dep)))
})

test_that("remove(htmlwidget) removes all deps", {
  dep <- tmp_dependency(name = "lib", version = "2.0")
  w <- htmlwidgets::createWidget("test", list(), package = "htmltools")
  attr(w, "html_dependencies") <- list(dep)

  dm1 <- dm(insert(with_config_dm(), w))
  expect_true(has(dm1, w))
  dm2 <- remove(dm1, w)
  expect_false(has(dm2, w))
})

test_that("remove(list) handles mixed inputs", {
  dep1 <- tmp_dependency(name = "a", version = "1.0")
  dep2 <- tmp_dependency(name = "b", version = "2.0")
  w <- htmlwidgets::createWidget("t", list(), package = "htmltools")
  attr(w, "html_dependencies") <- list(dep1, dep2)

  dm1 <- dm(insert(with_config_dm(), list(dep1, dep2, w)))
  dm2 <- remove(dm1, list(dep1, dep2, w))
  expect_length(dm2, 0)
})

test_that("remove non-existent key errors", {
  dm <- with_config_dm()
  expect_error(remove(dm, "nope@0.1"), "not registered")
})
