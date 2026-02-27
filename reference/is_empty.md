# Check if an InsertUpdate added nothing

Tests whether an
[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md)
operation resulted in any new assets being added. Useful for skipping
downstream work when nothing changed.

## Usage

``` r
is_empty(update)
```

## Arguments

- update:

  An insert_update object.

## Value

Scalar logical. `TRUE` if no CSS or JS assets were added, `FALSE`
otherwise.

## See also

[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md),
[`dm()`](https://andrewjstryker.github.io/depkit/reference/dm.md)
