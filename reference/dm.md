# Extract the DependencyManager from an InsertUpdate

Retrieves the updated `dependency_manager` stored inside an
`insert_update` object, allowing continued use after an
[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md)
call.

## Usage

``` r
dm(update)
```

## Arguments

- update:

  An insert_update object.

## Value

A `dependency_manager` object.

## See also

[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md),
[`is_empty()`](https://andrewjstryker.github.io/depkit/reference/is_empty.md)
