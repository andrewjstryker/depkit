# depkit

**depkit** is build-time plumbing for R packages that generate static
HTML pages containing htmlwidgets. It manages the CSS and JavaScript
dependencies those widgets carry — deduplicating shared libraries,
copying files to an output directory, and emitting production-quality
HTML tags.

## Why not just use htmltools?

htmltools provides
[`renderDependencies()`](https://rstudio.github.io/htmltools/reference/renderDependencies.html)
and
[`copyDependencyToDir()`](https://rstudio.github.io/htmltools/reference/copyDependencyToDir.html),
which handle dependency rendering and file copying. These work well
inside Shiny and R Markdown, where the runtime manages the full document
lifecycle.

For static site generation — blog engines, custom document pipelines,
Hugo post-processing — the requirements are different:

|                           | htmltools                                | depkit                                                           |
|---------------------------|------------------------------------------|------------------------------------------------------------------|
| **Insertion model**       | Batch: pass a complete list, get results | Incremental: insert widgets one at a time, emit deltas as you go |
| **CDN delivery**          | No                                       | Automatic via jsDelivr, verified by hash                         |
| **Subresource integrity** | No                                       | SRI hashes on all CDN tags                                       |
| **Local fallback**        | N/A                                      | `onerror` fallback on every CDN tag                              |
| **State management**      | Stateless functions                      | Persistent manager object that threads through a build pipeline  |

depkit accepts the same `html_dependency` objects and htmlwidgets that
htmltools does. It’s a narrow package that handles one concern — asset
management for static HTML — and produces `<script>` tags with CDN URLs,
SRI integrity, and local fallback that htmltools has no mechanism to
generate.

## Installation

``` r
# install.packages("pak")
pak::pak("andrewjstryker/depkit")
```

## Example: a page builder

depkit is designed as plumbing for site generators and document
pipelines. Here’s a sketch of how a page builder might use it:

``` r
build_page <- function(widgets, output_dir) {
  dm <- depkit::DependencyManager(
    output_root = file.path(output_dir, "assets"),
    url_root = "/assets",
    cdn = TRUE
  )

  body_html <- character()
  head_css <- character()

  for (w in widgets) {
    u <- depkit::insert(dm, w)
    head_css <- c(head_css, depkit::emit_css(u))
    body_html <- c(body_html, render_widget_html(w))
    dm <- depkit::dm(u)
  }

  footer_js <- depkit::emit_js(dm)

  # Assemble the page — depkit provides the snippets, you decide the layout
  write_html(output_dir, head_css = head_css,
             body = body_html, footer_js = footer_js)
}
```

Each widget’s dependencies are deduplicated automatically. Shared
libraries like jQuery are registered once and emitted once, regardless
of how many widgets use them.

## CDN support

With `cdn = TRUE`, depkit checks each JS file against
[jsDelivr](https://www.jsdelivr.com/) by hash. When a match is found,
the emitted tag uses the CDN URL with [subresource
integrity](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity)
and a local fallback:

``` html
<script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.min.js"
        integrity="sha384-ZvpUoO/..."
        crossorigin="anonymous"
        onerror="this.onerror=null;this.src='/assets/jquery-3.5.1/jquery.min.js';">
</script>
```

No configuration of CDN URLs is required. Any failure — network error,
404, hash mismatch — silently falls back to a local-only tag.

## License

MIT
