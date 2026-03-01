# Emit JS script tags

Generates `<script>` HTML tags for registered JavaScript assets. When
CDN is enabled (`cdn = TRUE`), tags include `integrity` and
`crossorigin` attributes with a local fallback.

## Usage

``` r
emit_js(x, keys = NULL)
```

## Arguments

- x:

  A dependency_manager or insert_update.

- keys:

  Optional character vector of asset ids to filter.

## Value

Character vector of HTML `<script>` tags, one per JS asset.

## See also

[`emit_css()`](https://andrewjstryker.github.io/depkit/reference/emit_css.md),
[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md),
[`DependencyManager()`](https://andrewjstryker.github.io/depkit/reference/DependencyManager.md)
