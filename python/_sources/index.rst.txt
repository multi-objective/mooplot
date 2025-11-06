.. _mooplot_docs_mainpage:

########################################################
mooplot: Visualizations for Multi-Objective Optimization
########################################################

.. toctree::
   :maxdepth: 1
   :hidden:

   API reference <reference/index>
   Examples <auto_examples/index>
   whatsnew/index

**Version**: |version| (See :ref:`whatsnew`)

**Date** |today|

**Useful links**:
`Source Repository <https://github.com/multi-objective/mooplot>`_ |
`Issue Tracker <https://github.com/multi-objective/mooplot/issues>`_

This webpage documents the ``mooplot`` Python package. There is also a ``mooplot`` `R package <https://multi-objective.github.io/mooplot/r>`_.

The **mooplot** package implements various visualizations that are useful in multi-objective optimization. These visualizations include:

* Visualization of Pareto frontiers.
* Visualization of the Empirical Attainment Function (EAF) and the differences between EAFs. The EAF describes the probabilistic distribution of the outcomes obtained by a stochastic algorithm in the objective space.

These visualizations may be used for exploring the performance of stochastic local search algorithms for multi-objective optimization problems and help in identifying certain algorithmic behaviors in a graphical way.

**Keywords**: empirical attainment function, summary attainment surfaces, EAF differences, multi-objective optimization, graphical analysis, visualization.


.. grid:: 2
    :gutter: 4
    :padding: 2 2 0 0
    :class-container: sd-text-center


    .. grid-item-card:: API Reference
        :img-top: _static/index_user_guide.svg
        :class-card: intro-card
        :shadow: md
        :link: reference
        :link-type: ref

        The reference guide contains a detailed description of the functions,
        modules, and objects.

    .. grid-item-card:: Examples
        :img-top: _static/index_getting_started.svg
        :class-card: intro-card
        :shadow: md
        :link: auto_examples
        :link-type: ref

        Detailed examples and tutorials.

.. This is not really the index page, that is found in
   _templates/indexcontent.html The toctree content here will be added to the
   top of the template header
