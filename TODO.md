# TODO — depkit

## Rename from assetman to depkit

- DESCRIPTION: update Package, Title
- \_pkgdown.yml: update site URL and references
- README.md: update package name and examples
- DESIGN.md: replace all `assetman` references with `depkit`
- tests/testthat.R:
  [`library(depkit)`](https://andrewjstryker.github.io/depkit) and
  `test_check("depkit")`
- tests/testthat/helper-assetman.R: renamed to helper-depkit.R
- All test files: `assetman:::` → `depkit:::`
- R/class-definition.R roxygen: updated package name reference
- NAMESPACE: regenerate after roxygen updates
- GitHub repo name (if applicable)

## Implementation fixes applied

- Asset output paths scoped under `name-version/` subdirectory to
  prevent filename collisions between dependencies (added
  `dep_subdir()`)

## Remaining implementation

- CDN resolution: automatic jsDelivr-based CDN discovery via
  `cdn = TRUE`, with hash verification and SRI integrity
- Removed `dep$meta$cdn` convention — CDN info is now resolved
  automatically

## Tests added

- CDN mode: `build_asset_records()` CDN branch, `js_tag()` CDN output,
  `cdn_cache` integration, end-to-end emit
- `compute_sri_hash` with sha384 (default openssl path)
- `dep_subdir` format
- Asset collision prevention (two deps, same filename)
- `insert(InsertUpdate, ANY)` chaining
- `normalize_insert_input` error on unsupported types
- `emit_css`/`emit_js` on InsertUpdate: default keys (added only), empty
  delta, explicit key override
- `is_empty` reflects delta state
- `remove(DependencyManager, ANY)` fallback dispatch
- `names<-` length mismatch error
- Config validation: invalid `cdn`, vector-length
  `output_root`/`url_root`

## Remaining test gaps

- `dependency_source_dir` with `package` field: the
  [`system.file()`](https://rdrr.io/r/base/system.file.html) branch
  needs a test using a real installed package
- `flatten_asset_spec` with list-of-descriptor inputs (script
  descriptors with `src` key, stylesheet descriptors with `href` key)

## Documentation

- Add roxygen documentation to all exported generics and classes
- CDN documentation updated (automatic resolution via jsDelivr)
- Add a vignette showing a realistic multi-widget workflow
- Populate pkgdown reference index in `_pkgdown.yml`
