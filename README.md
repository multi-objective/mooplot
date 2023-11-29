mooplot: Visualizations for Multi-Objective Optimization
========================================================
<!-- badges: start -->
[ [**R package**][r-mooplot-homepage] ] [ [GitHub][r-mooplot-github] ] [![Build status][r-build-badge]][r-build-link] [![Code Coverage][r-coverage-badge]][r-coverage-link]

[ [**Python package**][py-mooplot-homepage] ] [ [GitHub][py-mooplot-github] ] [![Build status][py-build-badge]][py-build-link] [![Code Coverage][py-coverage-badge]][py-coverage-link]
<!-- badges: end -->

nondominated
------------

Obtain information and perform some operations on the nondominated
sets given as input.


Building `nondominated'
-----------------------

The program has been tested on GNU/Linux using bash as shell and a
recent version of GCC (>= 4.2). If you have success or problems using
other systems, please let me know.

I recommend that you compile specifically for your architecture
using GCC option -march=. The default compilation is done with:

  make nondominated

This uses the option "-march=native". If your GCC version does not
support "native", you can give an explicit architecture:

  make nondominated march=i686

See the GCC manual for the names of the architectures supported by
your version of GCC.


Using `nondominated'
--------------------

See the output of

  nondominated --help


License
-------

See LICENSE file or contact the author.


  Contact
  -------

Manuel Lopez-Ibanez <manuel.lopez-ibanez@ulb.ac.be>


[py-build-badge]: https://github.com/multi-objective/mooplot/workflows/Python/badge.svg
[py-build-link]: https://github.com/multi-objective/mooplot/actions/workflows/python.yaml
[py-coverage-badge]: https://codecov.io/gh/multi-objective/mooplot/branch/main/graph/badge.svg?flag=python
[py-coverage-link]: https://codecov.io/gh/multi-objective/mooplot/tree/main/python
[py-mooplot-github]: https://github.com/multi-objective/mooplot/tree/main/python#readme
[py-mooplot-homepage]: https://multi-objective.github.io/mooplot/python
[r-build-badge]: https://github.com/multi-objective/mooplot/workflows/R/badge.svg
[r-build-link]: https://github.com/multi-objective/mooplot/actions/workflows/R.yaml
[r-coverage-badge]: https://codecov.io/gh/multi-objective/mooplot/branch/main/graph/badge.svg?flag=R
[r-coverage-link]: https://codecov.io/gh/multi-objective/mooplot/tree/main/r
[r-mooplot-github]: https://github.com/multi-objective/mooplot/tree/main/r#readme
[r-mooplot-homepage]: https://multi-objective.github.io/mooplot/r/
