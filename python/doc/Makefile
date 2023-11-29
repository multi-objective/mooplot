# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= LANG=C sphinx-build
SOURCEDIR     = source
BUILDDIR      = _build

root_dir:=$(abspath $(shell dirname $(firstword $(MAKEFILE_LIST))))

.PHONY: help Makefile

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

show:
	@python3 -c "import webbrowser; webbrowser.open_new_tab('file://$(root_dir)/$(BUILDDIR)/html/index.html')"

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" -WT --keep-going -d $(BUILDDIR)/doctrees $(SPHINXOPTS) $(O)
