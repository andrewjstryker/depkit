# Getting started with depkit

depkit is build-time plumbing for R packages and pipelines that generate
HTML documents containing widgets. It manages the CSS and JavaScript
files that htmlwidgets and htmltools dependencies carry — deduplicating
shared libraries, copying files to an output directory, and emitting
deterministic `<link>` and `<script>` tags.

depkit does not write HTML documents or decide where tags go. It
produces snippets; your site generator or document builder decides the
layout.

## Core API

### Create a dependency manager

A `DependencyManager` needs an output directory for copied assets and a
URL prefix for emitted tags. These correspond to your build pipeline’s
static asset directory and how it’s served.

``` r
library(depkit)
#> 
#> Attaching package: 'depkit'
#> The following object is masked from 'package:base':
#> 
#>     remove

dm <- DependencyManager(
  output_root = tempfile("assets"),
  url_root = "/static"
)
dm
#> <DependencyManager> with 0 registered dependencies:
```

### Insert dependencies

[`insert()`](https://andrewjstryker.github.io/depkit/reference/insert.md)
accepts `html_dependency` objects, htmlwidgets, or lists of either. It
returns an `InsertUpdate` — a delta that records what was newly added.

``` r
# Create two sample dependencies (standing in for real widget deps)
src1 <- tempfile("dep1")
dir.create(src1)
writeLines("body { margin: 0; }", file.path(src1, "reset.css"))
writeLines("console.log('app');", file.path(src1, "app.js"))

src2 <- tempfile("dep2")
dir.create(src2)
writeLines("console.log('utils');", file.path(src2, "utils.js"))

dep1 <- htmltools::htmlDependency(
  "my-app", "1.0", src = c(file = src1),
  stylesheet = "reset.css", script = "app.js"
)
dep2 <- htmltools::htmlDependency(
  "my-utils", "0.5", src = c(file = src2),
  script = "utils.js"
)

u <- insert(dm, dep1)
u
#> <InsertUpdate> added 1 CSS, 1 JS assets
```

Use [`dm()`](https://andrewjstryker.github.io/depkit/reference/dm.md) to
extract the updated manager for subsequent inserts:

``` r
dm <- dm(u)
u <- insert(dm, dep2)
dm <- dm(u)
dm
#> <DependencyManager> with 2 registered dependencies:
#>   my-app@1.0, my-utils@0.5
```

### Deduplication

Inserting the same dependency again is a no-op. This is the key property
that makes depkit useful — multiple widgets can declare overlapping
dependencies and depkit ensures each is registered exactly once.

``` r
u <- insert(dm, dep1)
is_empty(u)
#> [1] TRUE
```

### Emit HTML tags

[`emit_css()`](https://andrewjstryker.github.io/depkit/reference/emit_css.md)
and
[`emit_js()`](https://andrewjstryker.github.io/depkit/reference/emit_js.md)
generate HTML snippets. Called on a manager, they emit tags for all
registered assets. Called on an `InsertUpdate`, they emit tags for only
what was newly added.

``` r
# All registered CSS
cat(emit_css(dm), sep = "\n")
#> <link rel="stylesheet" href="/static/my-app-1.0/reset.css">

# All registered JS
cat(emit_js(dm), sep = "\n")
#> <script src="/static/my-app-1.0/app.js"></script>
#> <script src="/static/my-utils-0.5/utils.js"></script>
```

### Query and remove

``` r
has(dm, "my-app@1.0")
#> [1] TRUE
names(dm)
#> [1] "my-app@1.0"   "my-utils@0.5"
length(dm)
#> [1] 2
```

``` r
dm_reduced <- remove(dm, "my-utils@0.5")
names(dm_reduced)
#> [1] "my-app@1.0"
```

## Using depkit in a build pipeline

The API above is designed to be called from a page builder function, not
interactively. Here’s a sketch of how a site generator might use depkit
to process a list of widgets into a page:

``` r
build_page <- function(widgets, output_dir) {
  dm <- DependencyManager(
    output_root = file.path(output_dir, "assets"),
    url_root = "/assets"
  )

  head_css <- character()

  for (w in widgets) {
    u <- insert(dm, w)
    head_css <- c(head_css, emit_css(u))
    dm <- dm(u)
  }

  footer_js <- emit_js(dm)

  list(head_css = head_css, footer_js = footer_js)
}

# Example: two widgets with overlapping dependencies
result <- build_page(list(dep1, dep2), tempfile("site"))
cat("<!-- <head> -->\n")
#> <!-- <head> -->
cat(result$head_css, sep = "\n")
#> <link rel="stylesheet" href="/assets/my-app-1.0/reset.css">
cat("\n<!-- end of <body> -->\n")
#> 
#> <!-- end of <body> -->
cat(result$footer_js, sep = "\n")
#> <script src="/assets/my-app-1.0/app.js"></script>
#> <script src="/assets/my-utils-0.5/utils.js"></script>
```

CSS goes in the `<head>`, JS goes at the end of the `<body>`. Shared
dependencies (if dep1 and dep2 declared any) would appear only once.

## CDN support

Set `cdn = TRUE` to automatically resolve JavaScript assets against
[jsDelivr](https://www.jsdelivr.com/). depkit hashes each local JS file
and looks for a match in the jsDelivr package listing. When found, the
emitted `<script>` tag uses the CDN URL with [subresource
integrity](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity)
and a local fallback:

``` html
<script src="https://cdn.jsdelivr.net/npm/pkg@1.0/dist/lib.min.js"
        integrity="sha384-..."
        crossorigin="anonymous"
        onerror="this.onerror=null;this.src='/assets/pkg-1.0/lib.min.js';">
</script>
```

This is best-effort: any failure (network error, 404, hash mismatch)
silently falls back to a local-only tag. No configuration of CDN URLs is
required.

``` r
dm <- DependencyManager(
  output_root = "public/assets",
  url_root = "/assets",
  cdn = TRUE
)
```
