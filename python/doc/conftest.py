# ruff: noqa: D100, D103
import pytest
import moocore
import mooplot


@pytest.fixture(autouse=True)
def add_namespace(doctest_namespace):
    doctest_namespace["moocore"] = moocore
    doctest_namespace["mooplot"] = mooplot
