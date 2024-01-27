MOOPLOT: Multi-Objective Optimization Toolkit 
==============================================
<!-- badges: start -->
[![Python build
status](https://github.com/multi-objective/mooplot/workflows/Python/badge.svg)](https://github.com/multi-objective/mooplot/actions/workflows/python.yaml)
[![R build
status](https://github.com/multi-objective/mooplot/workflows/R/badge.svg)](https://github.com/multi-objective/mooplot/actions/workflows/R.yaml)
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
