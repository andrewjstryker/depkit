# depkit

**depkit** is a build-time HTML dependency kit for R. It tracks css/js
assets as ordered unique sets, copies newly discovered files, and emits
deterministic `<link>` / `<script>` snippets derived from dependency
metadata.

## Quick start

``` r
library(depkit)

dm <- DependencyManager(
  output_root = tempfile("asset-output"),
  url_root = "/assets"
)

dep <- htmltools::htmlDependency(
  name = "demo",
  version = "1.0.0",
  src = c(file = system.file("www", package = "htmlwidgets")),
  script = "htmlwidgets.js",
  stylesheet = "htmlwidgets.css"
)

u <- insert(dm, dep)

# emit only newly added assets
emit_css(u)
emit_js(u)

# emit all known assets
emit_css(dm(u))
emit_js(dm(u))
```

Insert always returns an `InsertUpdate` delta; emission is pure and
stateless.
