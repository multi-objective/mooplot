**mooplot**: Visualizations for Multi-Objective Optimization
========================================================
<!-- badges: start -->
[ [**R package**][r-mooplot-homepage] ] [ [GitHub][r-mooplot-github] ]
[![Build status][r-build-badge]][r-build-link]
[![Code Coverage][r-coverage-badge]][r-coverage-link]
[![CRAN version](https://www.r-pkg.org/badges/version-last-release/mooplot)][r-mooplot-cran]
[![CRAN Status](https://badges.cranchecks.info/worst/mooplot.svg)][r-mooplot-cran-results]
[![CRAN Downloads](https://cranlogs.r-pkg.org/badges/grand-total/mooplot)][r-mooplot-cran]
[![r-universe version][r-universe-version-badge]](https://multi-objective.r-universe.dev/mooplot)
[![r-universe build status][r-universe-build-badge]](https://github.com/r-universe/multi-objective/actions/workflows/build.yml)

[ [**Python package**][py-mooplot-homepage] ] [ [GitHub][py-mooplot-github] ]
[![Build status][py-build-badge]][py-build-link]
[![Code Coverage][py-coverage-badge]][py-coverage-link]
[![PyPI - Version](https://img.shields.io/pypi/v/mooplot)][py-mooplot-pypi]
[![PyPI - Downloads](https://img.shields.io/pypi/dm/mooplot?color=blue)][py-mooplot-pypi]
<!-- badges: end -->

**Contributors:**
    [Manuel López-Ibáñez](https://lopez-ibanez.eu),
    [Carlos M. Fonseca](https://eden.dei.uc.pt/~cmfonsec/),
    [Luís Paquete](https://eden.dei.uc.pt/~paquete/),
    Mickaël Binois.
    Fergus Rooney.

---------------------------------------

Introduction
============

The **mooplot** package implements various visualizations that are useful in
multi-objective optimization. These visualizations include:

 * Visualization of Pareto frontiers.
 * Visualization of the Empirical Attainment Function (EAF) and the differences
between EAFs. The EAF describes the probabilistic distribution of the outcomes
obtained by a stochastic algorithm in the objective space.

These visualizations may be used for exploring the performance of stochastic local
search algorithms for multi-objective optimization problems and help in identifying
certain algorithmic behaviors in a graphical way.

**Keywords**: empirical attainment function, summary attainment surfaces, EAF
differences, multi-objective optimization, graphical analysis, visualization.

The repository is composed of:

 * `r/`: An R package that uses the C library.
 * `python/`: A Python package that uses the C library.

Each component is documented in the `README.md` file found under each folder.


[py-build-badge]: https://github.com/multi-objective/mooplot/workflows/Python/badge.svg
[py-build-link]: https://github.com/multi-objective/mooplot/actions/workflows/python.yaml
[py-coverage-badge]: https://codecov.io/gh/multi-objective/mooplot/branch/main/graph/badge.svg?flag=python
[py-coverage-link]: https://app.codecov.io/gh/multi-objective/mooplot/tree/main/python
[py-mooplot-github]: https://github.com/multi-objective/mooplot/tree/main/python#readme
[py-mooplot-homepage]: https://multi-objective.github.io/mooplot/python
[py-mooplot-pypi]: https://pypi.org/project/mooplot/
[r-build-badge]: https://github.com/multi-objective/mooplot/workflows/R/badge.svg
[r-build-link]: https://github.com/multi-objective/mooplot/actions/workflows/R.yaml
[r-coverage-badge]: https://codecov.io/gh/multi-objective/mooplot/branch/main/graph/badge.svg?flag=R
[r-coverage-link]: https://app.codecov.io/gh/multi-objective/mooplot/tree/main/r
[r-mooplot-cran-results]: https://cran.r-project.org/web/checks/check_results_mooplot.html
[r-mooplot-cran]: https://cran.r-project.org/package=mooplot
[r-mooplot-github]: https://github.com/multi-objective/mooplot/tree/main/r#readme
[r-mooplot-homepage]: https://multi-objective.github.io/mooplot/r/
[r-universe-version-badge]: https://multi-objective.r-universe.dev/badges/mooplot
[r-universe-build-badge]: https://github.com/r-universe/multi-objective/actions/workflows/build.yml/badge.svg
