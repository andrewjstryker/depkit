# Construct a DependencyManager

Creates a new dependency manager that tracks HTML dependencies,
deduplicates assets, copies files to an output directory, and emits
deterministic HTML tags. Use
[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md)
to register dependencies and
[`emit_css()`](https://andrewjstryker.github.io/depkit/reference/emit_css.md)/[`emit_js()`](https://andrewjstryker.github.io/depkit/reference/emit_js.md)
to generate the corresponding HTML.

## Usage

``` r
DependencyManager(
  registry = list(),
  output_root = NULL,
  url_root = NULL,
  cdn_mode = "off"
)
```

## Arguments

- registry:

  Optional list of html_dependency objects to pre-register.

- output_root:

  Filesystem root for copied assets.

- url_root:

  Base URL for emitted assets.

- cdn_mode:

  CDN handling mode (`"off"` or `"verify"`).

## Value

A `dependency_manager` object.

## See also

[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md),
[`has()`](https://andrewjstryker.github.io/depkit/reference/has.md),
[`remove()`](https://andrewjstryker.github.io/depkit/reference/remove.md),
[`emit_css()`](https://andrewjstryker.github.io/depkit/reference/emit_css.md),
[`emit_js()`](https://andrewjstryker.github.io/depkit/reference/emit_js.md)

## Examples

``` r
dm <- DependencyManager(
  output_root = tempfile("assets"),
  url_root = "/static"
)
dep <- htmltools::htmlDependency(
  "example", "1.0",
  src = c(file = system.file(package = "htmltools")),
  script = NULL
)
upd <- insert(dm, dep)
dm(upd)
#> <DependencyManager> with 1 registered dependency:
#>   example@1.0
```
