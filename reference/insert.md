# Insert dependencies

Registers new dependencies in the manager, copies their asset files to
the output directory, and records CSS/JS asset ids for later emission.
Dependencies that are already registered are silently skipped.

## Usage

``` r
insert(x, dep)
```

## Arguments

- x:

  A dependency_manager or insert_update.

- dep:

  An html_dependency, htmlwidget, or list.

## Value

An `insert_update` object containing the updated dependency manager and
vectors of newly added CSS and JS asset ids.

## See also

[`dm()`](https://andrewjstryker.github.io/depkit/reference/dm.md),
[`is_empty()`](https://andrewjstryker.github.io/depkit/reference/is_empty.md),
[`remove()`](https://andrewjstryker.github.io/depkit/reference/remove.md),
[`DependencyManager()`](https://andrewjstryker.github.io/depkit/reference/DependencyManager.md)
