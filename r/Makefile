PACKAGEVERSION=$(shell sh -c 'grep -F "Version: " DESCRIPTION | cut -f2 -d" "')
PACKAGE=$(shell sh -c 'grep -F "Package: " DESCRIPTION | cut -f2 -d" "')
REALVERSION=$(PACKAGEVERSION)$(REVNUM)

BINDIR=$(CURDIR)/..
INSTALL_FLAGS="--with-keep.source"
PACKAGEDIR=$(CURDIR)
RHUB_COMMON_ARGS= path='$(BINDIR)/$(PACKAGE)_$(PACKAGEVERSION).tar.gz', env_vars = c('_R_CHECK_FORCE_SUGGESTS_'='false', R_DEFAULT_SAVE_VERSION='2', R_DEFAULT_SERIALIZE_VERSION='2')
Reval=R --slave -e

define Rsed
	R --slave --vanilla -e 'f <- "$(1)"; txt <- sub($(2), $(3), perl=TRUE, readLines(f)); writeLines(txt, f)'
endef

## Do we have git?
ifeq ($(shell sh -c 'which git 1> /dev/null 2>&1 && echo y'),y)
  ## Is this a working copy?
  ifeq ($(shell sh -c 'LC_ALL=C  git describe --first-parent --always | grep -q "[0-9a-z]\+$$" 2>&1 && echo y'),y)
    $(shell sh -c 'LC_ALL=C  git describe --dirty --first-parent --always --exclude "*" > git_version')
  endif
endif
## Set version information:
REVNUM = $(shell sh -c 'cat git_version 2> /dev/null')

.PHONY: build check clean install pdf submit cran winbuild help gendoc pkgdown

help :
	@echo 'This makefile has the following targets                  '
	@echo '   build     build $(PACKAGE) at $(BINDIR)		'
	@echo '   cran      check with --as-cran			'
	@echo '   check     check with --timings			'
	@echo '   check TEST=x  run test called test-x.R                '
	@echo '   pdf       build $(PACKAGE).pdf			'
	@echo '   winbuild  send to http\://win-builder.r-project.org/	'
	@echo '   submit    submit to CRAN (see DEVEL-README first!)    '
	@echo '   clean     cleanup    '

install: build
	cd $(BINDIR) && R CMD INSTALL $(INSTALL_FLAGS) $(PACKAGE)_$(PACKAGEVERSION).tar.gz

setup:
	Rscript -e 'if(!require(devtools)) install.packages("devtools"); devtools::install_dev_deps(build=FALSE, upgrade="never")'

gendoc: $(PACKAGEDIR)/man/$(PACKAGE)-package.Rd

NAMESPACE $(PACKAGEDIR)/man/$(PACKAGE)-package.Rd: $(PACKAGEDIR)/R/*.R
	$(Reval) 'devtools::document()'

pkgdown: gendoc
	$(Reval) 'pkgdown::build_site(run_dont_run = TRUE)'

build:
	@$(MAKE) gendoc
	cd $(BINDIR) && R CMD build $(PACKAGEDIR)

closeversion:
	git push origin :refs/tags/v$(PACKAGEVERSION) # Remove any existing tag
	git tag -f -a v$(PACKAGEVERSION) -m "Version $(PACKAGEVERSION)"
	git push --tags

releasebuild: clean
	@$(MAKE) gendoc
	cd $(BINDIR) &&	R CMD build $(PACKAGEDIR) && tar -atvf $(PACKAGE)_$(PACKAGEVERSION).tar.gz

releasecheck: cran
	$(Reval) 'urlchecker::url_check()'
	$(MAKE) winbuild # $(MAKE) macbuild # rhub is broken

cran : build
	cd $(BINDIR) && _R_CHECK_FORCE_SUGGESTS_=false _R_OPTIONS_STRINGS_AS_FACTORS_=false R CMD check --as-cran $(PACKAGE)_$(PACKAGEVERSION).tar.gz

check: build
ifdef TEST
	_R_CHECK_FORCE_SUGGESTS_=false NOT_CRAN=true $(Reval) 'devtools::test(filter="$(TEST)")'
else
	cd $(BINDIR) && (_R_CHECK_FORCE_SUGGESTS_=false NOT_CRAN=true R CMD check --run-donttest --run-dontrun --timings $(PACKAGE)_$(PACKAGEVERSION).tar.gz; cat $(PACKAGE).Rcheck/$(PACKAGE)-Ex.timings)
endif

clean:
	cd $(PACKAGEDIR)

pdf:
	$(RM) $(BINDIR)/$(PACKAGE).pdf
	cd $(BINDIR) && R CMD Rd2pdf --no-preview --batch --output=$(PACKAGE).pdf $(PACKAGEDIR)

submit:
	@echo 'Edit cran-comments.md and run devtools::release() in R'

remotecran: releasebuild
	$(Reval) "rhub::check_for_cran($(RHUB_COMMON_ARGS), show_status = TRUE)"

macbuild: releasebuild
	$(Reval) "rhub::check(platform='macos-highsierra-release-cran', $(RHUB_COMMON_ARGS))"

winbuild: releasebuild
	$(Reval) "devtools::check_win_release()"
	$(Reval) "devtools::check_win_devel()"
	$(Reval) "rhub::check_on_windows($(RHUB_COMMON_ARGS))"

covr: build
	$(Reval) "Sys.setenv(NOT_CRAN='true');covr::report(covr::package_coverage(type='all'))"
