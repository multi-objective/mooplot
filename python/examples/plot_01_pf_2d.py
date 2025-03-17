"""
Plotting Pareto fronts in 2D
============================

Various examples using :func:`mooplot.plot_pf`.
"""

import plotly.express as px

df = px.data.tips()
fig = px.bar(
    df,
    x="sex",
    y="total_bill",
    facet_col="day",
    color="smoker",
    barmode="group",
    template="presentation+plotly",
)
fig.update_layout(height=400)
fig

# %%
# In addition to the classical scatter or bar charts, plotly provides a large
# variety of traces, such as the sunburst hierarchical trace of the following
# example. plotly is an interactive library: click on one of the continents
# for a more detailed view of the drill-down.

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
