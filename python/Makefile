.PHONY : install build test doc clean docdeps

install: build
	python3 -m pip install -e . --disable-pip-version-check --find-links wheelhouse

build:
	python3 -m build

test:
	tox

black:
	pre-commit autoupdate
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
	$(RM) -rf .pytest_cache/ .tox/ build/ src/*.egg-info/
	$(RM) -rf doc/source/reference/generated/
	$(RM) -f .coverage coverage.xml
