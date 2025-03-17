"""
Plotting Pareto fronts in 3D
============================

Various examples using :func:`mooplot.plot_pf`.
"""

import moocore
import mooplot

# %%
# Points
# ------
#
data = moocore.get_dataset("spherical-250-10-3d.txt")
# Select only the last 3 datasets
data = data[data[:, -1] >= 8, :]
fig = mooplot.plot_pf(data, title="Spherical")
fig

# %%
# Three objective surface
# -----------------------
#
# Use the `type="surface"` argument to draw a smooth 3D surface for each
# dataset.
fig = mooplot.plot_pf(data, type="surface")
fig

# %%
# Three objective surface+points
# ------------------------------
#
# Use `type="surface, points"` to add both points and surfaces to the plot. You
# can compare the surface of one dataset to the points of another by clicking
# on "set 1" and "set 2 points" in the legend to hide some of the points and
# surfaces.
data = moocore.get_dataset("uniform-250-10-3d.txt")
data = data[data[:, -1] >= 8, :]
fig = mooplot.plot_pf(data, type="surface, points", title="Uniform")
fig

# %%
# Three objective cube graph
# --------------------------
#
# Use `type="cube"` to add a cuboid for each point.
#
# .. warning::
#     This may be slow in large datasets.
#
fig = mooplot.plot_pf(data, type="cube")
fig
