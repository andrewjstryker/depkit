.onLoad <- function(libname, pkgname) {
  pkg_opts <-
    list(
      # Where should JS/CSS live locally?
      widgetman.local_path = system.file("www", package = pkgname),
      widgetman.local_js_path = file.path(
        getOption("widgetman.local_path"),
        "js"
      ),
      widgetman.local_css_path = file.path(
        getOption("widgetman.local_path"),
        "css"
      ),

      # Which CDNs should we try, using the format: package, version
      widgetman.cdns = c(
        # Primary library CDNs
        "https://cdnjs.cloudflare.com/ajax/libs/%s/%s",
        "https://cdn.jsdelivr.net/npm/%s@%s",
        "https://unpkg.com/%s@%s",
        # GitHub releases via jsDelivr
        "https://cdn.jsdelivr.net/gh/%s@%s/dist",
        "https://cdn.jsdelivr.net/gh/%s@%s",
        # RawGit replacement for GitHub-hosted assets
        "https://rawcdn.githack.com/%s/%s/raw"
      ),

      # How long (in seconds) before we give up and fall back?
      widgetman.timeout = 5
    )
  # only set defaults if user hasn’t already
  to_set <- setdiff(names(pkg_opts), names(options()))
  if (length(to_set)) options(pkg_opts[to_set])
}
