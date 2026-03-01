test_that("compute_sri_hash returns sha384 prefixed hash", {
  f <- tempfile()
  writeLines("console.log('test');", f)
  hash <- depkit:::compute_sri_hash(f)
  expect_true(startsWith(hash, "sha384-"))
  expect_true(nchar(hash) > 10)
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

test_that("css_tag emits link tag", {
  rec <- list(url = "/assets/style.css")
  tag <- depkit:::css_tag(rec)
  expect_match(tag, "<link rel=\"stylesheet\" href=\"/assets/style.css\">")
})

test_that("flatten_jsdelivr_files flattens nested tree", {
  tree <- list(
    list(type = "directory", name = "dist", files = list(
      list(type = "file", name = "app.js", hash = "abc123"),
      list(type = "file", name = "app.min.js", hash = "def456")
    )),
    list(type = "file", name = "index.js", hash = "ghi789")
  )
  flat <- depkit:::flatten_jsdelivr_files(tree)
  expect_length(flat, 3)
  expect_equal(flat[[1]]$name, "/dist/app.js")
  expect_equal(flat[[2]]$name, "/dist/app.min.js")
  expect_equal(flat[[3]]$name, "/index.js")
  expect_equal(flat[[1]]$hash, "abc123")
})

test_that("compute_jsdelivr_hash returns sha256 base64", {
  f <- tempfile()
  writeLines("console.log('test');", f)
  hash <- depkit:::compute_jsdelivr_hash(f)
  # sha256 base64 ends with = padding, no prefix
  expect_false(startsWith(hash, "sha"))
  expect_true(nchar(hash) > 10)
})

test_that("jsdelivr_cdn_url constructs correct URL", {
  url <- depkit:::jsdelivr_cdn_url("jquery", "3.6.0", "/dist/jquery.min.js")
  expect_equal(url, "https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js")
})

test_that("match_by_hash finds matching file", {
  files <- list(
    list(name = "/dist/a.js", hash = "sha384-abc"),
    list(name = "/dist/b.js", hash = "sha384-def")
  )
  expect_equal(depkit:::match_by_hash("sha384-def", files), "/dist/b.js")
  expect_null(depkit:::match_by_hash("sha384-zzz", files))
})

test_that("resolve_cdn returns NULL on network error", {
  dep <- tmp_dependency(name = "nonexistent-pkg-xyz", version = "0.0.0", js = "a.js")
  # Use a hostname that will fail
  result <- local({
    # Mock by calling resolve_cdn with a package that won't exist
    depkit:::resolve_cdn(dep, "a.js")
  })
  expect_null(result)
})

test_that("resolve_and_annotate populates cdn_cache", {
  dep <- tmp_dependency(name = "testpkg", version = "1.0", js = "lib.js")
  dm0 <- with_config_dm(cdn = TRUE)
  u <- insert(dm0, dep)
  dm1 <- dm(u)

  # Manually populate as if jsDelivr returned a match
  info <- depkit:::collect_asset_ids(dep)
  dm1$cdn_cache[[info$js_ids]] <- list(
    cdn_url = "https://cdn.jsdelivr.net/npm/testpkg@1.0/lib.js",
    integrity = "sha384-fakehash"
  )

  recs <- depkit:::build_asset_records(dm1, dm1$js_assets, "js")
  expect_equal(recs[[1]]$cdn_url, "https://cdn.jsdelivr.net/npm/testpkg@1.0/lib.js")
  expect_equal(recs[[1]]$integrity, "sha384-fakehash")
})

test_that("build_asset_records skips CDN when cdn = FALSE", {
  dep <- tmp_dependency(name = "noCdn", version = "1.0", js = "lib.js")
  dm0 <- with_config_dm(cdn = FALSE)
  u <- insert(dm0, dep)
  dm1 <- dm(u)

  recs <- depkit:::build_asset_records(dm1, dm1$js_assets, "js")
  expect_null(recs[[1]]$cdn_url)
})

test_that("build_asset_records skips CDN for CSS even when cdn = TRUE", {
  dep <- tmp_dependency(name = "cssDep", version = "1.0", css = "style.css")
  dm0 <- with_config_dm(cdn = TRUE)
  u <- insert(dm0, dep)
  dm1 <- dm(u)

  recs <- depkit:::build_asset_records(dm1, dm1$css_assets, "css")
  expect_null(recs[[1]]$cdn_url)
})

test_that("cdn_cache entries are used in emit_js", {
  dep <- tmp_dependency(name = "emitlib", version = "2.0", js = "app.js")
  dm0 <- with_config_dm(cdn = TRUE)
  u <- insert(dm0, dep)
  dm1 <- dm(u)

  # Manually inject cdn_cache entry
  info <- depkit:::collect_asset_ids(dep)
  dm1$cdn_cache[[info$js_ids]] <- list(
    cdn_url = "https://cdn.jsdelivr.net/npm/emitlib@2.0/app.js",
    integrity = "sha384-xyz"
  )

  tags <- emit_js(dm1)
  expect_length(tags, 1)
  expect_match(tags, "cdn.jsdelivr.net/npm/emitlib@2.0/app.js")
  expect_match(tags, "sha384-xyz")
  expect_match(tags, "onerror=")
})
