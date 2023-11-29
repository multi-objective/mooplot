**mooplot**: Visualizations for Multi-Objective Optimization
============================================================

<!-- badges: start -->
[![Build status][py-build-badge]][py-build-link]
[![Code Coverage][py-coverage-badge]][py-coverage-link]
[![PyPI - Version](https://img.shields.io/pypi/v/mooplot)][py-mooplot-pypi]
[![PyPI - Downloads](https://img.shields.io/pypi/dm/mooplot?color=blue)][py-mooplot-pypi]
<!-- badges: end -->

[ [**Homepage**][py-mooplot-homepage] ] [ [**GitHub**][py-mooplot-github] ]

**Contributors:**
    [Manuel López-Ibáñez](https://lopez-ibanez.eu),
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

The [book chapter](#LopPaqStu09emaa) [1] explains the use of these
visualization tools and illustrates them with examples arising from practice.

**Keywords**: empirical attainment function, summary attainment surfaces, EAF
differences, multi-objective optimization, graphical analysis, visualization.

R package
---------

There is also a `mooplot` package for R: https://multi-objective.github.io/mooplot/r


[py-build-badge]: https://github.com/multi-objective/mooplot/workflows/Python/badge.svg
[py-build-link]: https://github.com/multi-objective/mooplot/actions/workflows/python.yaml
[py-coverage-badge]: https://codecov.io/gh/multi-objective/mooplot/branch/main/graph/badge.svg?flag=python
[py-coverage-link]: https://app.codecov.io/gh/multi-objective/mooplot/tree/main/python
[py-mooplot-github]: https://github.com/multi-objective/mooplot/tree/main/python#readme
[py-mooplot-homepage]: https://multi-objective.github.io/mooplot/python
[py-mooplot-pypi]: https://pypi.org/project/mooplot/
