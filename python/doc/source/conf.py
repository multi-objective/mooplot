# Configuration file for the Sphinx documentation builder.
# ruff: noqa: D100, D103
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# See also: https://github.com/networkx/networkx/blob/main/doc/conf.py

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information
from datetime import date
import mooplot


# Set plotly renderer to capture _repr_html_ for sphinx-gallery
try:
    import plotly.io
except ImportError:
    pass
else:
    plotly.io.renderers.default = "sphinx_gallery"

project = "mooplot"
_full_version = mooplot.__version__
release = _full_version.split("+", 1)[0]
version = ".".join(release.split(".")[:2])
year = date.today().year
# Can we get this from pyproject.toml ?
author = "Manuel López-Ibáñez and Fergus Rooney"
copyright = f"2023-{year}, {author}"
html_site_root = f"https://multi-objective.github.io/{project}/python/"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration
extensions = [
    "sphinx_design",  # grid directive
    "sphinx.ext.napoleon",
    "sphinx.ext.autodoc",  # Core Sphinx library for auto html doc generation from docstrings
    "sphinx.ext.autosummary",  # Create neat summary tables for modules/classes/methods etc
    "sphinx.ext.intersphinx",  # Link to other project's documentation (see mapping below)
    "sphinx.ext.viewcode",  # Add a link to the Python source code for classes, functions etc.
    "sphinx_copybutton",  # A small sphinx extension to add a "copy" button to code blocks.
    "sphinx.ext.doctest",
    "sphinx.ext.extlinks",
    "sphinx.ext.mathjax",
    "myst_nb",
    "sphinx.ext.autosectionlabel",
    "sphinxcontrib.bibtex",
    "sphinx_gallery.gen_gallery",
    "matplotlib.sphinxext.plot_directive",
]

# try:
#     import jupyterlite_sphinx  # noqa: F401

#     extensions.append("jupyterlite_sphinx")
#     with_jupyterlite = True
# except ImportError:
#     # In some cases we don't want to require jupyterlite_sphinx to be installed,
#     # e.g. the doc-min-dependencies build
#     warnings.warn(
#         "jupyterlite_sphinx is not installed, you need to install it "
#         "if you want JupyterLite links to appear in each example"
#     )
#     with_jupyterlite = False


# -----------------------------------------------------------------------------
# Autosummary
# -----------------------------------------------------------------------------
autosummary_generate = True
# autosummary_generate_overwrite = False
# autosummary_ignore_module_all = False
# If true, the current module name will be prepended to all description
# unit titles (such as .. function::).
# add_module_names = True
# autosummary_imported_members = True  # Also documents imports in __init__.py
# Napoleon settings
napoleon_google_docstring = False
napoleon_numpy_docstring = True
napoleon_preprocess_types = True
napoleon_use_rtype = False
napoleon_include_init_with_doc = True
napoleon_use_param = True
napoleon_type_aliases = {
    "array_like": ":term:`array_like`",
}

bibtex_bibfiles = ["REFERENCES.bib"]
bibtex_reference_style = "super"
bibtex_default_style = "unsrt"

# If true, '()' will be appended to :func: etc. cross-reference text.
add_function_parentheses = True

autodoc_typehints = "description"
autodoc_type_aliases = {
    "ArrayLike": "ArrayLike",
}

# Options for the `::plot` directive:
# https://matplotlib.org/stable/api/sphinxext_plot_directive_api.html
# plot_formats = ["png"]
# plot_include_source = True
# plot_html_show_formats = False
# plot_html_show_source_link = False

html_theme = "pydata_sphinx_theme"

# The reST default role (used for this markup: `text`) to use for all
# documents.
default_role = "literal"

# FIXME: Implement a version switch like NumPy.
# Set up the version switcher.  The versions.json is stored in the doc repo.
# if os.environ.get('CIRCLE_JOB', False) and \
#         os.environ.get('CIRCLE_BRANCH', '') != 'main':
#     # For PR, name is set to its ref
#     switcher_version = os.environ['CIRCLE_BRANCH']
# elif ".9999" in version:
#     switcher_version = "devdocs"
# else:
#     switcher_version = f"{version}"

html_theme_options = {
    "collapse_navigation": True,
    "header_links_before_dropdown": 6,
    #    "navigation_depth": 2,
    "show_prev_next": True,
    "use_edit_page_button": True,
    "github_url": "https://github.com/multi-objective/{project}",
    # Add light/dark mode and documentation version switcher:
    # "navbar_end": ["theme-switcher", "version-switcher", "navbar-icon-links"],
    "navbar_end": ["theme-switcher", "navbar-icon-links"],
    # "icon_links": [
    #     {
    #         # Label for this link
    #         "name": "GitHub",
    #         # URL where the link will redirect
    #         "url": f"https://github.com/multi-objective/{project}",  # required
    #         # Icon class (if "type": "fontawesome"), or path to local image (if "type": "local")
    #         "icon": "fa-brands fa-square-github",
    #         # The type of image to be used (see below for details)
    #         "type": "fontawesome",
    #     }
    # ],
}
# Removes, from all docs, the copyright footer.
html_show_copyright = False

html_context = {
    "display_github": True,
    "github_user": "multi-objective",
    "github_repo": project,
    "github_version": "main",
    "doc_path": "doc",
}
# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ["_static"]
html_css_files = [
    "css/custom.css",
]
templates_path = ["_templates"]
# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = [
    "_build",
    "Thumbs.db",
    ".DS_Store",
    "**.ipynb_checkpoints",
    "_templates",
    "modules.rst",
    "source",
    # Exclude .py and .ipynb files in auto_examples generated by sphinx-gallery.
    # This is to prevent sphinx from complaining about duplicate source files.
    "auto_examples/*.ipynb",
    "auto_examples/*.py",
]
suppress_warnings = ["mystnb.unknown_mime_type"]

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

# html_permalinks_icon = "<span>#</span>"

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = "sphinx"

# Intersphinx mapping
intersphinx_mapping = {
    "geopandas": ("https://geopandas.org/en/stable/", None),
    "matplotlib": ("https://matplotlib.org/stable/", None),
    "moocore": ("https://multi-objective.github.io/moocore/python/", None),
    "neps": ("https://numpy.org/neps/", None),
    "numpy": ("https://numpy.org/doc/stable/", None),
    "nx-guides": ("https://networkx.org/nx-guides/", None),
    "pandas": ("https://pandas.pydata.org/pandas-docs/stable/", None),
    "plotly": ("https://plotly.com/python-api-reference/", None),
    "pygraphviz": ("https://pygraphviz.github.io/documentation/stable/", None),
    "python": ("https://docs.python.org/3/", None),
    "scipy": ("https://docs.scipy.org/doc/scipy/", None),
    "sphinx-gallery": ("https://sphinx-gallery.github.io/stable/", None),
    "sympy": ("https://docs.sympy.org/latest/", None),
}

# From https://github.com/scikit-learn/scikit-learn/blob/main/doc/conf.py
sphinx_gallery_conf = {
    "examples_dirs": "../../examples",
    "gallery_dirs": "auto_examples",
    # Directory where function/class granular galleries are stored.
    "backreferences_dir": "reference/generated/backreferences",
    # Modules for which function/class level galleries are created.
    "doc_module": ("mooplot"),
    # Regexes to match objects to exclude from implicit backreferences.
    # The default option is an empty set, i.e. exclude nothing.
    # To exclude everything, use: '.*'
    "exclude_implicit_doc": {r"pyplot\.show"},
    "show_memory": False,
    # "reference_url": {"mooplot": None},
    # "subsection_order": SubSectionTitleOrder("../examples"),
    # "within_subsection_order": SKExampleTitleSortKey,
    # "binder": {
    #     "org": "scikit-learn",
    #     "repo": "scikit-learn",
    #     "binderhub_url": "https://mybinder.org",
    #     "branch": binder_branch,
    #     "dependencies": "./binder/requirements.txt",
    #     "use_jupyter_lab": True,
    # },
    # avoid generating too many cross links
    "inspect_global_variables": False,
    "remove_config_comments": True,
    "matplotlib_animations": True,
    # "plot_gallery": "True",
    # "recommender": {"enable": True, "n_examples": 5, "min_df": 12},
    # "reset_modules": ("matplotlib", "seaborn"),
}
# if with_jupyterlite:
#     sphinx_gallery_conf["jupyterlite"] = {
#         "notebook_modification_function": notebook_modification_function
#     }
