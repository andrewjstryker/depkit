# Package index

## Constructor

Create a new dependency manager.

- [`DependencyManager()`](https://andrewjstryker.github.io/depkit/reference/DependencyManager.md)
  : Construct a DependencyManager

## Manage dependencies

Register, query, and remove dependencies.

- [`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md)
  : Insert dependencies
- [`has()`](https://andrewjstryker.github.io/depkit/reference/has.md) :
  Check whether dependencies are registered
- [`remove()`](https://andrewjstryker.github.io/depkit/reference/remove.md)
  : Remove dependencies

## Emit HTML

Generate HTML tags for registered assets.

- [`emit_css()`](https://andrewjstryker.github.io/depkit/reference/emit_css.md)
  : Emit CSS link tags
- [`emit_js()`](https://andrewjstryker.github.io/depkit/reference/emit_js.md)
  : Emit JS script tags

## InsertUpdate helpers

Work with the result of an insert() call.

- [`dm()`](https://andrewjstryker.github.io/depkit/reference/dm.md) :
  Extract the DependencyManager from an InsertUpdate
- [`is_empty()`](https://andrewjstryker.github.io/depkit/reference/is_empty.md)
  : Check if an InsertUpdate added nothing
