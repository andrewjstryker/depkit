# TODO — depkit

## Rename from assetman to depkit

- [x] DESCRIPTION: update Package, Title
- [x] _pkgdown.yml: update site URL and references
- [x] README.md: update package name and examples
- [x] DESIGN.md: replace all `assetman` references with `depkit`
- [x] tests/testthat.R: `library(depkit)` and `test_check("depkit")`
- [x] tests/testthat/helper-assetman.R: renamed to helper-depkit.R
- [x] All test files: `assetman:::` → `depkit:::`
- [x] R/class-definition.R roxygen: updated package name reference
- [ ] NAMESPACE: regenerate after roxygen updates
- [ ] GitHub repo name (if applicable)

## Implementation fixes applied

- [x] Asset output paths scoped under `name-version/` subdirectory to prevent filename collisions between dependencies (added `dep_subdir()`)

## Remaining implementation

- [ ] CDN verification workflow: `cdn_mode = "verify"` trusts `dep$meta$cdn` metadata but does not fetch CDN content to verify byte-equivalence — needs `curl` or `httr2` for download + comparison against local file
- [ ] Document `dep$meta$cdn` convention: structure is `list("rel_path" = list(url=, integrity=, fallback_url=))` or a bare URL string

## Tests added

- [x] CDN verify mode: `cdn_entry_for()`, `build_asset_records()` CDN branch, `js_tag()` CDN output, end-to-end emit
- [x] `compute_sri_hash` with sha384 (default openssl path)
- [x] `dep_subdir` format
- [x] Asset collision prevention (two deps, same filename)
- [x] `insert(InsertUpdate, ANY)` chaining
- [x] `normalize_insert_input` error on unsupported types
- [x] `emit_css`/`emit_js` on InsertUpdate: default keys (added only), empty delta, explicit key override
- [x] `is_empty` reflects delta state
- [x] `remove(DependencyManager, ANY)` fallback dispatch
- [x] `names<-` length mismatch error
- [x] Config validation: invalid `cdn_mode`, vector-length `output_root`/`url_root`

## Remaining test gaps

- [ ] `dependency_source_dir` with `package` field: the `system.file()` branch needs a test using a real installed package
- [ ] `flatten_asset_spec` with list-of-descriptor inputs (script descriptors with `src` key, stylesheet descriptors with `href` key)

## Documentation

- [ ] Add roxygen documentation to all exported generics and classes
- [ ] Document `dep$meta$cdn` convention for CDN metadata on dependencies
- [ ] Add a vignette showing a realistic multi-widget workflow
- [ ] Populate pkgdown reference index in `_pkgdown.yml`
