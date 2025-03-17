# ruff: noqa: D100, D101, D102, D103
import pytest
import numpy as np
import moocore

import mooplot


def test_plt_dta_types(test_datapath):
    """Check that the plot_pf() functions has the right input handling."""
    with pytest.raises(Exception) as expt:
        mooplot.plot_pf("Wrong input")
    assert expt.type is ValueError
    with pytest.raises(Exception) as expt:
        mooplot.plot_pf(np.ndarray(shape=(5, 1)))
    assert expt.type is ValueError
    with pytest.raises(Exception) as expt:
        mooplot.plot_pf(np.ndarray(shape=(5, 5)))
    assert expt.type is NotImplementedError

    X = moocore.get_dataset("input1.dat")
    with pytest.raises(Exception) as expt:
        mooplot.plot_pf(X, type="Bugel horn")
    assert expt.type is ValueError
    # FIXME: Check that the plots are the same.
    mooplot.plot_pf(X, type="points,lines")
    mooplot.plot_pf(X, type="p,l")
    mooplot.plot_pf(X, type="l  ,p")
    mooplot.plot_pf(X, type="points,l")
    mooplot.plot_pf(X, type="point ,lines")
    mooplot.plot_pf(X, type="LiNe ,  PoInTs")
