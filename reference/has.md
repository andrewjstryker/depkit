# Check whether dependencies are registered

Tests whether one or more dependencies have already been registered in a
dependency manager.

## Usage

``` r
has(x, dep)
```

## Arguments

- x:

  A dependency_manager.

- dep:

  A dependency key, html_dependency, htmlwidget, or list.

## Value

Logical. A scalar `TRUE`/`FALSE` when `dep` is a single key,
html_dependency, or htmlwidget; a logical vector when `dep` is a list.

## See also

[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md),
[`remove()`](https://andrewjstryker.github.io/depkit/reference/remove.md),
[`DependencyManager()`](https://andrewjstryker.github.io/depkit/reference/DependencyManager.md)
