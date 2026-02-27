# Makefile for an R package
# Targets:
# - install_deps: Installs required packages (devtools, testthat, pkgdown)
# - build: Builds the package tarball
# - test: Runs tests via testthat using devtools
# - check: Runs R CMD check on the built package
# - pkgdown: Builds the package website using pkgdown
# - clean: Removes build artifacts

.PHONY: all
all: test pkgdown #> Run tests and build pkgdown website (default)

.PHONY: install_deps
install_deps: #> Install required packages for development
	R -e "install.packages(c('renv', 'devtools', 'testthat', 'pkgdown'), repos = 'https://cloud.r-project.org')"

.PHONY: snapshot
snapshot: #> Scan for package versions
	R -e "renv::snapshot()"

.PHONY: restore
restore: #> Insert pinned package version into the environment
	R -e "renv::restore()"

.PHONY: build
build: #> Build the package tarball
	R CMD build .

.PHONY: test
test: #> Run tests using testthat via devtools
	R -e "devtools::test()"

.PHONY: check
check: build #> Check the built package
	R CMD check $$(ls -t *.tar.gz | head -n 1)

.PHONY: document
document: #> Update documentation and NAMESPACE using roxygen2
	R -e "devtools::document()"

.PHONY: site
site: #> Build the pkgdown website
	R -e "pkgdown::build_site()"
	
.PHONY: serve
serve: #> Serve the pkgdown website locally
	R -e "pkgdown::serve_site()"

.PHONY: clean
clean: #> Remove generated files
	rm -rf *.tar.gz *.Rcheck docs

.PHONY: help
help: #> Print this help mesage
	@gawk -f generate-help.awk ${MAKEFILE_LIST}
		
