test_that("cdn_entry_for returns NULL when no CDN metadata", {
  dep <- tmp_dependency(name = "plain", version = "1.0", js = "a.js")
  result <- depkit:::cdn_entry_for(dep, "a.js")
  expect_null(result)
})

test_that("cdn_entry_for extracts URL from string entry", {
  dep <- tmp_dependency(name = "lib", version = "1.0", js = "a.js")
  dep$meta <- list(cdn = list("a.js" = "https://cdn.example.com/a.js"))
  result <- depkit:::cdn_entry_for(dep, "a.js")
  expect_equal(result$url, "https://cdn.example.com/a.js")
})

test_that("cdn_entry_for extracts structured entry with integrity", {
  dep <- tmp_dependency(name = "lib", version = "1.0", js = "a.js")
  dep$meta <- list(cdn = list("a.js" = list(
    url = "https://cdn.example.com/a.js",
    integrity = "sha384-abc123",
    fallback_url = "/fallback/a.js"
  )))
  result <- depkit:::cdn_entry_for(dep, "a.js")
  expect_equal(result$url, "https://cdn.example.com/a.js")
  expect_equal(result$integrity, "sha384-abc123")
  expect_equal(result$fallback_url, "/fallback/a.js")
})

test_that("cdn_entry_for falls back to basename lookup", {
  dep <- tmp_dependency(name = "lib", version = "1.0", js = "sub/a.js")
  dep$meta <- list(cdn = list("a.js" = "https://cdn.example.com/a.js"))
  result <- depkit:::cdn_entry_for(dep, "sub/a.js")
  expect_equal(result$url, "https://cdn.example.com/a.js")
})

test_that("build_asset_records includes CDN info in verify mode", {
  out <- tempfile("cdn-out")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets", cdn_mode = "verify")
  dep <- tmp_dependency(name = "cdn", version = "1.0", js = "lib.js")
  dep$meta <- list(cdn = list("lib.js" = list(
    url = "https://cdn.example.com/lib.js",
    integrity = "sha384-test123"
  )))
  u <- insert(dm0, dep)
  dm1 <- dm(u)

  recs <- depkit:::build_asset_records(dm1, dm1$js_assets, "js")
  expect_equal(recs[[1]]$cdn_url, "https://cdn.example.com/lib.js")
  expect_equal(recs[[1]]$integrity, "sha384-test123")
})

test_that("build_asset_records computes SRI when integrity not provided", {
  out <- tempfile("cdn-out")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets", cdn_mode = "verify")
  dep <- tmp_dependency(name = "cdn2", version = "1.0", js = "lib.js")
  dep$meta <- list(cdn = list("lib.js" = "https://cdn.example.com/lib.js"))
  u <- insert(dm0, dep)
  dm1 <- dm(u)

  recs <- depkit:::build_asset_records(dm1, dm1$js_assets, "js")
  expect_true(startsWith(recs[[1]]$integrity, "sha384-"))
})

test_that("build_asset_records skips CDN for CSS even in verify mode", {
  out <- tempfile("cdn-out")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets", cdn_mode = "verify")
  dep <- tmp_dependency(name = "cdn3", version = "1.0", css = "style.css")
  dep$meta <- list(cdn = list("style.css" = "https://cdn.example.com/style.css"))
  u <- insert(dm0, dep)
  dm1 <- dm(u)

  recs <- depkit:::build_asset_records(dm1, dm1$css_assets, "css")
  expect_null(recs[[1]]$cdn_url)
})

test_that("js_tag emits CDN script with integrity and fallback", {
  rec <- list(
    url = "/assets/lib.js",
    cdn_url = "https://cdn.example.com/lib.js",
    integrity = "sha384-abc123",
    fallback_url = "/assets/lib.js"
  )
  tag <- depkit:::js_tag(rec)
  expect_match(tag, "cdn.example.com/lib.js")
  expect_match(tag, "sha384-abc123")
  expect_match(tag, "crossorigin=\"anonymous\"")
  expect_match(tag, "onerror=")
})

test_that("js_tag emits local-only when no CDN", {
  rec <- list(url = "/assets/lib.js", cdn_url = NULL)
  tag <- depkit:::js_tag(rec)
  expect_match(tag, "^<script src=\"/assets/lib.js\"></script>$")
})

test_that("emit_js uses CDN tags in verify mode end-to-end", {
  out <- tempfile("cdn-out")
  dm0 <- DependencyManager(output_root = out, url_root = "/assets", cdn_mode = "verify")
  dep <- tmp_dependency(name = "cdnlib", version = "2.0", js = "app.js")
  dep$meta <- list(cdn = list("app.js" = list(
    url = "https://cdn.example.com/app.js",
    integrity = "sha384-xyz"
  )))
  u <- insert(dm0, dep)
  tags <- emit_js(u)
  expect_length(tags, 1)
  expect_match(tags, "cdn.example.com/app.js")
  expect_match(tags, "sha384-xyz")
})
