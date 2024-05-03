"""Plotting Pareto fronts with `plot_pf()`
=======================================

Various examples using :func:`mooplot.plot_pf`.

"""

# %%
# Plot 2D datasets
# ----------------
#
# The default is `type='points'`.
import moocore
import mooplot

sets = moocore.read_datasets(moocore.get_dataset_path("input1.dat"))
# Select only the first 5 datasets
sets = sets[sets[:, -1] <= 5, :]
fig = mooplot.plot_pf(sets, title="input1.dat")
fig

# %%
# Plot a two objective dataset with points and lines
fig = mooplot.plot_pf(sets, type="p,l")
fig

# %%
# Plot 3D datasets
# ----------------
#
filename = moocore.get_dataset_path("spherical-250-10-3d.txt")
sets = moocore.read_datasets(filename)
# Select only the last 3 datasets
sets = sets[sets[:, -1] >= 8, :]
fig = mooplot.plot_pf(sets, title="Spherical")
fig

# %%
# Three objective surface
# -----------------------
#
# Use the `type="surface"` argument to draw a smooth 3D surface for each
# dataset.
fig = mooplot.plot_pf(sets, type="surface")
fig

# %%
# Three objective surface+points
# ------------------------------
#
# Use `type="surface, points"` to add both points and surfaces to the plot. You
# can compare the surface of one dataset to the points of another by clicking
# on "set 1" and "set 2 points" in the legend to hide some of the points and
# surfaces.
filename = moocore.get_dataset_path("uniform-250-10-3d.txt")
sets = moocore.read_datasets(filename)
sets = sets[sets[:, -1] >= 8, :]
fig = mooplot.plot_pf(sets, type="surface, points", title="Uniform")
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
fig = mooplot.plot_pf(sets, type="cube")
fig
