# Remove dependencies

Removes one or more previously registered dependencies and their
associated asset ids from the manager. Does not delete copied files from
disk.

## Usage

``` r
remove(x, dep)
```

## Arguments

- x:

  A dependency_manager.

- dep:

  A dependency key, html_dependency, htmlwidget, or list.

## Value

An updated `dependency_manager` with the specified dependencies removed.

## See also

[`has()`](https://andrewjstryker.github.io/depkit/reference/has.md),
[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md),
[`DependencyManager()`](https://andrewjstryker.github.io/depkit/reference/DependencyManager.md)
