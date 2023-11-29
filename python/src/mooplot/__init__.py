# ruff: noqa: D104
from ._plot import plot_pf, plot_eaf

__all__ = [
    "plot_pf",
    "plot_eaf",
]

from importlib.metadata import version as _metadata_version

__version__ = _metadata_version(__package__ or __name__)
# Remove symbols imported for internal use
del _metadata_version
