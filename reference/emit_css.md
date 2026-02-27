# Emit CSS link tags

Generates `<link>` HTML tags for registered CSS assets.

## Usage

``` r
emit_css(x, keys = NULL)
```

## Arguments

- x:

  A dependency_manager or insert_update.

- keys:

  Optional character vector of asset ids to filter.

## Value

Character vector of HTML `<link rel="stylesheet">` tags, one per CSS
asset.

## See also

[`emit_js()`](https://andrewjstryker.github.io/depkit/reference/emit_js.md),
[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md),
[`DependencyManager()`](https://andrewjstryker.github.io/depkit/reference/DependencyManager.md)
