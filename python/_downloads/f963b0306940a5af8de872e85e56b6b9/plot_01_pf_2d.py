"""
Plotting Pareto fronts in 2D
============================

Various examples using :func:`mooplot.plot_pf`.
"""

import moocore
import mooplot

# %%
# Plot 2D datasets
# ----------------
#
# The default is ``type='points'``.

data = moocore.get_dataset("input1.dat")
# Select only the first 5 datasets
data = data[data[:, -1] <= 5, :]
fig = mooplot.plot_pf(data, title="input1.dat")
fig

# %%
# Plot a two objective dataset with points and lines
fig = mooplot.plot_pf(data, type="p,l")
fig
