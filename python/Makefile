# This file should be almost identical to
# https://github.com/multi-objective/moocore/blob/main/python/Makefile
.PHONY : install build test doc clean docdeps pre-commit pre-commit-update

install: build
	python3 -m pip install -e . --disable-pip-version-check --find-links wheelhouse

build:
	python3 -m build

test:
	tox

pre-commit-update:
	pre-commit autoupdate
	pre-commit run -a

pre-commit:
	pre-commit run -a

docdeps:
	python3 -m pip install -r requirements_dev.txt --disable-pip-version-check --quiet

show:
	$(MAKE) -C doc show

doc:
	$(MAKE) -C doc clean html

clean:
	$(MAKE) -C doc clean
	find . -name '__pycache__' | xargs $(RM) -r
	$(RM) -r .pytest_cache/ .tox/ build/ src/*.egg-info/
	$(RM) -r doc/source/reference/generated/
	$(RM) .coverage coverage.xml
