import pytest
import numpy as np
import moocore

import mooplot


# FIXME: For some reason this stopped working!!!
# def test_docstrings():
#     import doctest
#     doctest.FLOAT_EPSILON = 1e-9
#     # Run doctests for "moocore" module and fail if one of the docstring tests is incorrect.
#     # Pass in the "moocore" module so that the docstrings don't have to import every time
#     doctest.testmod(mooplot, raise_on_error=True, extraglobs={"mooplot": mooplot})


def test_plt_dta_types(test_datapath):
    """
    Check that the plot_pf() functions has the right input handling
    """
    with pytest.raises(Exception) as expt:
        mooplot.plot_pf(datasets="Wrong input")
    assert expt.type == ValueError
    with pytest.raises(Exception) as expt:
        mooplot.plot_pf(datasets=np.ndarray(shape=(5, 1)))
    assert expt.type == ValueError
    with pytest.raises(Exception) as expt:
        mooplot.plot_pf(datasets=np.ndarray(shape=(5, 5)))
    assert expt.type == NotImplementedError

    X = moocore.read_datasets(moocore.get_dataset_path("input1.dat"))
    with pytest.raises(Exception) as expt:
        mooplot.plot_pf(X, type="Bugel horn")
    assert expt.type == ValueError
    # FIXME: Check that the plots are the same.
    mooplot.plot_pf(X, type="points,lines")
    mooplot.plot_pf(X, type="p,l")
    mooplot.plot_pf(X, type="l  ,p")
    mooplot.plot_pf(X, type="points,l")
    mooplot.plot_pf(X, type="point ,lines")
    mooplot.plot_pf(X, type="LiNe ,  PoInTs")
