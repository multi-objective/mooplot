# ruff: noqa: D100, D101, D102, D103
import pytest
import moocore
import mooplot


@pytest.fixture(autouse=True)
def add_doctest_imports(doctest_namespace) -> None:
    doctest_namespace["moocore"] = moocore
    doctest_namespace["mooplot"] = mooplot
