test_that("emit_css on InsertUpdate emits only added assets by default", {
  out <- tempfile("iu-emit")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets")
  dep1 <- tmp_dependency(name = "a", version = "1.0", css = "a.css")
  dep2 <- tmp_dependency(name = "b", version = "1.0", css = "b.css")

  u1 <- insert(dm0, dep1)
  dm1 <- dm(u1)
  u2 <- insert(dm1, dep2)

  tags <- emit_css(u2)
  expect_length(tags, 1)
  expect_match(tags, "b.css")
})

test_that("emit_js on InsertUpdate emits only added assets by default", {
  out <- tempfile("iu-emit")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets")
  dep1 <- tmp_dependency(name = "a", version = "1.0", js = "a.js")
  dep2 <- tmp_dependency(name = "b", version = "1.0", js = "b.js")

  u1 <- insert(dm0, dep1)
  dm1 <- dm(u1)
  u2 <- insert(dm1, dep2)

  tags <- emit_js(u2)
  expect_length(tags, 1)
  expect_match(tags, "b.js")
})

test_that("emit on InsertUpdate with no new assets returns empty", {
  out <- tempfile("iu-emit")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets")
  dep <- tmp_dependency(name = "a", version = "1.0", css = "a.css", js = "a.js")

  u1 <- insert(dm0, dep)
  dm1 <- dm(u1)
  u2 <- insert(dm1, dep)

  expect_true(is_empty(u2))
  expect_length(emit_css(u2), 0)
  expect_length(emit_js(u2), 0)
})

test_that("emit on InsertUpdate accepts explicit keys override", {
  out <- tempfile("iu-emit")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets")
  dep1 <- tmp_dependency(name = "a", version = "1.0", css = "a.css")
  dep2 <- tmp_dependency(name = "b", version = "1.0", css = "b.css")

  u1 <- insert(dm0, dep1)
  dm1 <- dm(u1)
  u2 <- insert(dm1, dep2)

  all_keys <- dm(u2)$css_assets
  tags <- emit_css(u2, keys = all_keys)
  expect_length(tags, 2)
})

test_that("is_empty reflects delta state", {
  out <- tempfile("iu-emit")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets")
  dep <- tmp_dependency(name = "a", version = "1.0", js = "a.js")

  u1 <- insert(dm0, dep)
  expect_false(is_empty(u1))

  u2 <- insert(dm(u1), dep)
  expect_true(is_empty(u2))
})
