from __future__ import annotations

from numpy.typing import ArrayLike  # For type hints

import numpy as np
import pandas as pd

# FIXME: Move plotly plots to submodule mooplot.plotly
import plotly.express as px
import plotly.graph_objects as go
from moocore import filter_dominated_within_sets
from . import colour
from ._utils import (
    parse_line_dash,
    parse_2d_line_dash,
    parse_line_width,
    parse_2d_line_width,
    _parse_plot_type,
)


_3d_margin = dict(r=5, l=5, b=20, t=20)


def plot_pf(
    data: ArrayLike,
    type: str = "points",
    filter_dominated: bool = True,
    **layout_kwargs,
) -> go.Figure:
    """Plot Pareto fronts.

    This function can produce an interactive point graph, stair step graph or 3D surface graph. It accepts 2 or 3 objectives.

    Parameters
    ----------
    data :
        Array of numerical values, maybe created by :func:`moocore.read_datasets()`,
        where each row gives the coordinates of a point
        in objective space and the last column defines the sets to which each row of ``data`` belongs.
    type :
        Type of plot. Any of:

        - 'points' : produces a scatter-like point graph *(2 or 3 objectives)*
        - 'lines' : produces a stepped line graph *(2 objectives only)*
        - 'points,lines' : produces a stepped line graph with points *(2 objective only)*
        - 'fill' : produces a stepped line graph with filled areas between lines. See :func:`plot_eaf` *(2 objective only)*
        - 'surface' : produces a smoothed 3d surface *(3 objective only*)
        - 'surface,points' : produces a smoothed 3d surface with datapoints plotted *(3 objective only*)
        - 'cube' : produces a discrete cube surface *(3 objective only*)

        Abbreviations such as ``'p'`` or ``'p,l'`` are accepted.
    filter_dominated :
        Whether to automatically filter dominated points within each set. Default is ``True``.
    layout_kwargs :
        Update features of the graph such as title axis titles, colours etc.
        These additional parameters are passed to plotly :meth:`plotly.graph_objects.Figure.update_layout`.
        See :class:`plotly.graph_objects.Layout`.

    Returns
    -------
        Graphical object. The user can customise any part of the graph after it is created.

    Examples
    --------
    >>> x = moocore.get_dataset("input1.dat")
    >>> mooplot.plot_pf(x, type="points,lines")  # doctest: +ELLIPSIS
    Figure({...

    .. minigallery:: mooplot.plot_pf
       :add-heading:

    """
    # FIXME: Accept a Pandas DataFrame.
    data = np.asarray(data, dtype=float)
    ncols = data.shape[1]
    if ncols < 3:
        raise ValueError(
            "'data' must have at least 3 columns (2 objectives + set column)"
        )
    if ncols > 4:
        raise NotImplementedError(
            "Only 2D or 3D datasets are currently supported"
        )
    dim = ncols - 1
    if filter_dominated:
        data = filter_dominated_within_sets(data)

    type_parsed = _parse_plot_type(type, dim)

    df = pd.DataFrame(
        data, columns=[f"Objective {d + 1}" for d in range(dim)] + ["Set"]
    )
    # Convert set num to string without decimal points, plotly interprets ints as discrete colour sequences.
    df["Set"] = df["Set"].astype(int).astype(str)
    num_percentiles = df["Set"].nunique()
    if dim == 2:
        # FIXME this can be combined with plot_2d_eaf function to tidy up
        if type_parsed == "fill":
            def_colours = colour.get_default_fill_colorway(num_percentiles)
            colorway = colour.parse_colorway(
                dict.get(layout_kwargs, "colorway", def_colours),
                num_percentiles,
            )
            fill_border_colours = colour.parse_colorway(
                dict.get(layout_kwargs, "fill_border_colours", def_colours),
                num_percentiles,
            )
            figure = create_2d_eaf_plot(data, colorway, fill_border_colours)
            # Make sure these arguments are not used twice
            layout_kwargs.pop("fill_border_colours", None)
            layout_kwargs.pop("colorway", None)

        else:
            colorway = colour.parse_colorway(
                dict.get(
                    layout_kwargs, "colorway", px.colors.qualitative.Plotly
                ),
                num_percentiles,
            )
            layout_kwargs["colorway"] = colorway
            # Sort the the points by Objective 1 within each set, while keeping the set order (May be inefficient)
            for s in df["Set"].unique():
                mask = df["Set"] == s
                df.loc[mask] = (
                    df.loc[mask].sort_values(by=df.columns[0]).values
                )

            figure = px.line(
                df,
                x=df.columns[0],
                y=df.columns[1],
                color="Set",
                color_discrete_sequence=colorway,
            )

            # FIXME: This should be configurable.
            maximise = [False, False]
            # Extend lines past the figure boundaries.
            for trace in figure.data:
                trace.x, trace.y = add_extremes(trace.x, trace.y, maximise)

            figure.update_traces(line_shape="hv", mode=type_parsed)

    elif dim == 3:
        colorway = colour.parse_colorway(
            dict.get(layout_kwargs, "colorway", px.colors.qualitative.Plotly),
            num_percentiles,
        )
        title = layout_kwargs.pop("title", None)

        if "surface" in type_parsed:
            # Currently creates a surface with points joined for each
            figure = _gen_3d_mesh_plot(df, type_parsed)
        elif "markers" in type_parsed:
            figure = px.scatter_3d(
                df,
                x=df.columns[0],
                y=df.columns[1],
                z=df.columns[2],
                color="Set",
                color_discrete_sequence=colorway,
            )
            figure.update_traces(marker_size=4)
            figure.update_layout(margin=_3d_margin)
        elif "cube" in type_parsed:
            figure = _get_cube_plot(data)
        else:
            raise NotImplementedError
        if title:
            figure.update_layout(title=_get_3d_title(title))
    else:
        raise NotImplementedError

    figure.update_layout(layout_kwargs)
    return figure


def _apply_default_themes(fig):
    # This theme may be preferable as it has a white background so could make for a more "scientific" look
    fig.update_layout(
        plot_bgcolor="white",
    )
    fig.update_xaxes(
        mirror=True,
        ticks="outside",
        showline=True,
        linecolor="black",
        gridcolor="lightgrey",
    )
    fig.update_yaxes(
        mirror=True,
        ticks="outside",
        showline=True,
        linecolor="black",
        gridcolor="lightgrey",
    )


def _get_3d_title(title):
    return {
        "text": title,
        "y": 0.9,
        "x": 0.45,
        "xanchor": "center",
        "yanchor": "top",
    }


# Generates smooth 3d mesh plot from dataset
def _gen_3d_mesh_plot(df, type):
    num_sets = df["Set"].unique()
    fig = go.Figure()
    for set in num_sets:
        df_one_set = df[df["Set"] == set]
        fig.add_trace(
            go.Mesh3d(
                x=df_one_set["Objective 1"],
                y=df_one_set["Objective 2"],
                z=df_one_set["Objective 3"],
                opacity=0.85,
                name="Set " + set,
            ),
        )
        if "markers" in type:
            fig.add_scatter3d(
                mode="markers",
                x=df_one_set["Objective 1"],
                y=df_one_set["Objective 2"],
                z=df_one_set["Objective 3"],
                name="Set " + set + " points",
                marker=dict(size=3),
            )
    fig.update_traces(showlegend=True)
    fig.update_layout(
        margin=_3d_margin,
        legend_title_text="Set",
        scene=dict(
            xaxis_title="Objective 1",
            yaxis_title="Objective 2",
            zaxis_title="Objective 3",
        ),
    )
    return fig


def _get_cube_points(dataset):
    ds_cube = np.zeros((dataset.shape[0] * 8, 5), dtype=float)
    cube_num = 0
    for row in range(ds_cube.shape[0]):
        if row % 8 == 0:
            cube_num = cube_num + 1

        # i,j,k represent binary digits that are counted up from 0 to 7 for each cube
        # these are multiplied by the co-ordinates of the orignal point to create 8 total points
        # Each point is a corner of a cube
        i = (row % 8) >> 2
        j = ((row % 8) >> 1) & 1
        k = (row % 8) & 1
        ds_cube[row, 0] = dataset[int(row / 8), 0] * float(i)
        ds_cube[row, 1] = dataset[int(row / 8), 1] * float(j)
        ds_cube[row, 2] = dataset[int(row / 8), 2] * float(k)
        ds_cube[row, 3] = dataset[int(row / 8), 3]
        ds_cube[row, 4] = cube_num

    return ds_cube


def _get_tri_indexs(num_cubes):
    # Each number in i,j,k represents an index of a point
    # Each column of i,j,k forms a triangle from three points
    # This pre-configuration forms a cube from 12 triangles
    i = [1, 1, 4, 4, 2, 2, 0, 3, 3, 6, 4, 4]
    j = [3, 5, 5, 1, 4, 4, 2, 2, 2, 7, 6, 7]
    k = [7, 7, 1, 0, 6, 0, 1, 1, 6, 3, 7, 5]
    # tri_index is a numpy array that contains indexs for n number of cubes
    tri_index = np.zeros((3, num_cubes * 12), dtype=int)
    tri_index[:3, :12] = np.array([i, j, k]).reshape(3, 12)
    for n in range(num_cubes):
        # Copy the triangle index preconfiguration to every cube
        tri_index[0:3, n * 12 : (n + 1) * 12] = (
            np.array([i, j, k]).reshape(3, 12) + 8 * n
        )
    return tri_index


# Returns a cube point. This is
def _get_cube_plot(dataset):
    fig = go.Figure()
    np_cubes = _get_cube_points(dataset)
    col_names = [
        "Objective 1",
        "Objective 2",
        "Objective 3",
        "Set",
        "Cube Number",
    ]

    cube_df = pd.DataFrame(np_cubes, columns=col_names)
    for s in cube_df["Set"].unique():
        set_n_df = cube_df[cube_df["Set"] == s]
        num_cubes = set_n_df["Cube Number"].nunique()
        # Define the corners of all triangles in all cubes
        cube_indexs = _get_tri_indexs(num_cubes)
        fig.add_trace(
            go.Mesh3d(
                x=set_n_df["Objective 1"],
                y=set_n_df["Objective 2"],
                z=set_n_df["Objective 3"],
                i=cube_indexs[0, :],
                j=cube_indexs[1, :],
                k=cube_indexs[2, :],
                showlegend=True,
                name=f"Set {s}",
            )
        )
    fig.update_layout(
        margin=_3d_margin,
        legend_title_text="Set",
        scene=dict(
            xaxis_title="Objective 1",
            yaxis_title="Objective 2",
            zaxis_title="Objective 3",
        ),
    )
    return fig


def add_extremes(x, y, maximise):
    best_x = np.max(x) if maximise[0] else np.min(x)
    best_y = np.max(y) if maximise[1] else np.min(y)
    dtype = np.finfo(x.dtype)
    inf_x = dtype.min if maximise[0] else dtype.max
    inf_y = dtype.min if maximise[1] else dtype.max
    return np.concatenate([[best_x], x, [inf_x]]), np.concatenate(
        [[inf_y], y, [best_y]]
    )


# Create a fill plot -> Such as EAF percentile  plot.
# If a figure is given, update the figure instead of creating a new one
# If no name is given, the last column eg. Percentile is chosen.
def create_2d_eaf_plot(
    dataset,
    colorway,
    fill_border_colours,
    figure=None,
    type="fill",
    names=None,
    line_dashes=None,
    line_width=None,
) -> go.Figure:
    # Get a line plot and sort by the last column eg. Set number or percentile
    # FIXME: remove this recursion.
    lines_plot = plot_pf(dataset, type="line", filter_dominated=False)
    ordered_lines = sorted(lines_plot.data, key=lambda x: int(x["name"]))
    float_inf = np.finfo(
        np.float64
    ).max  # Interpreted as infinite value by plotly

    # Add an line to fill down from infinity to the last percentile
    ordered_lines.append(
        dict(x=np.array([0, float_inf]), y=np.array([float_inf, float_inf]))
    )
    percentile_names = np.unique(dataset[:, -1]).astype(int)
    num_percentiles = len(percentile_names)

    # If figure argument is given, add to an existing figure, else create new
    # figure.
    figure = figure if figure else go.Figure()

    if names:
        if isinstance(names, str):
            names = [names] * num_percentiles
        elif isinstance(names, list) and len(names) < num_percentiles:
            raise ValueError(
                f"Names list (len {len(names)}) should equal number of different traces (len {num_percentiles})"
            )
    line_dashes = parse_line_dash(
        line_dashes, num_percentiles, default="solid"
    )
    line_width = parse_line_width(line_width, num_percentiles, default=2)

    is_fill = "fill" in type
    choose_mode = (
        "lines"
        if ("lines" in type or is_fill)
        else ("markers" if "points" in type else "lines")
    )
    for i, line in enumerate(ordered_lines):
        # In fill graphs the first two traces should be the same colour
        # In non-fill graphs the last
        fill_i = i - 1 if i > 0 else i  #
        name_i = fill_i if is_fill else min(i, num_percentiles - 1)

        if names:
            select_names = f"{names[name_i]} - {percentile_names[name_i]}"
            select_legend_group = names[name_i]
        else:
            select_names = percentile_names[name_i]
            select_legend_group = percentile_names[name_i]

        line_colour = (
            fill_border_colours[name_i] if type == "fill" else colorway[name_i]
        )
        figure.add_trace(
            go.Scatter(
                x=line["x"],
                y=line["y"],
                mode=choose_mode,
                fill="none" if (i == 0 or not is_fill) else "tonexty",
                line={
                    "shape": "hv",
                    "dash": line_dashes[name_i],
                    "color": line_colour,
                    "width": line_width[name_i],
                },
                fillcolor=colorway[fill_i],
                name=str(select_names),
                legendgroup=str(select_legend_group),
                showlegend=(
                    False
                    if (
                        is_fill
                        and i == 0
                        or not is_fill
                        and i == len(ordered_lines) - 1
                    )
                    else True
                ),  # Don't show extra traces in case
            )
        )
    return figure


def _combine_2d_figures(
    datasets,
    names,
    types,
    colorways,
    fill_border_colours,
    line_dashes,
    line_widths,
):
    # Create a single 2d graph containing multiple different EAF plots
    num_sets = [
        len(np.unique(set[:, -1])) for set in datasets
    ]  # A list containing the number of traces in each plot
    # FIXME fix this colour thing
    def_colours = colour.get_example_gradients(num_sets, choice="scientific")
    def_line = colour.get_2d_colorway_from_colour(num_sets, "rgba(0,0,0,0.7)")

    line_dashes = parse_2d_line_dash(line_dashes, num_sets, default="solid")
    colourway = colour.parse_2d_colorway(colorways, def_colours, num_sets)
    fill_border_colours = colour.parse_2d_colorway(
        fill_border_colours, def_line, num_sets
    )
    line_widths = parse_2d_line_width(line_widths, num_sets, default=2)

    combined_figure = go.Figure()
    for i, dataset in enumerate(datasets):
        combined_figure = create_2d_eaf_plot(
            dataset,
            colourway[i],
            fill_border_colours[i],
            figure=combined_figure,
            type=types[i],
            names=names[i],
            line_dashes=line_dashes[i],
            line_width=line_widths[i],
        )
    return combined_figure


def apply_legend_preset(fig, preset: str = "centre_top_right"):
    """Apply a preset to the legend, changing it's position, text or colour.

    For more advanced legend behaviour.

    Parameters
    ----------
    fig :
        Figure to apply preset to
    preset :
        If `preset` is a string, this will change the position of the legend. It must be one of the following: "outside_top_right", "outside_top_left", "top_right", "bottom_right", "top_left", \
        "bottom_left","centre_top_right", "centre_top_left","centre_bottom_right", "centre_bottom_left".

        Set it to a list [preset_position_name, title_text, background_colour, border_colour] to change position, title text, background colour and border colour

    """
    colour = None
    text = None
    border_colour = None
    if isinstance(preset, list):
        position = preset[0]
        text = preset[1]
        colour = preset[2]
        border_colour = preset[3]
    elif isinstance(preset, dict):
        position = preset.get("position")
        text = preset.get("text")
        colour = preset.get("colour")
        border_colour = preset.get("border_colour")
    elif isinstance(preset, str):
        position = preset
    else:
        raise TypeError("preset argument type not recognised")

    pos_presets = dict(
        outside_top_right=(1.02, 1),
        outside_top_left=(-0.2, 1),
        top_right=(1, 1),
        bottom_right=(1, 0),
        top_left=(0, 1),
        bottom_left=(0, 0),
        centre_top_right=(0.975, 0.95),
        centre_top_left=(0.025, 0.95),
        centre_bottom_right=(0.975, 0.05),
        centre_bottom_left=(0.025, 0.05),
    )
    position = position if position else "centre_top_right"
    xanchor = (
        "left" if "left" in position or "outside" in position else "right"
    )
    yanchor = "top" if "top" in position or "outside" in position else "bottom"

    colour = "rgba(0,0,0,0)" if colour == "invisible" else colour
    border_colour = "rgba(0,0,0,0)" if colour == "invisible" else border_colour

    fig.update_layout(
        legend=dict(
            x=pos_presets[position][0],
            y=pos_presets[position][1],
            xanchor=xanchor,
            yanchor=yanchor,
            bgcolor=colour,
            bordercolor=border_colour,
            borderwidth=0 if not border_colour else 2.5,
        )
    )
    if text or text == "":
        fig.update_layout(
            legend=dict(
                title_text=text,
            )
        )


def plot_eaf(
    dataset: ArrayLike,
    type: str = "fill",
    percentiles: list = [],
    colorway: list = [],
    fill_border_colours: list = [],
    trace_names: list = [],
    line_dashes: str = "solid",
    line_width: list = [],
    legend_preset: str = "centre_top_right",
    template: str = "simple_white",
    **layout_kwargs,
) -> go.Figure:
    """Plot attainment surfaces in 2D.

    Parameters
    ----------
    dataset :
        The `dataset` argument must be Numpy array of EAF values (2 objectives and percentile marker), or it can be a dictionary of such values. \
        The dictionary must have this format: {'alg_name_1' : dataset1, 'alg_name_2' : dataset2}.
    percentiles :
        A list of percentiles to plot. These must exist in the dataset argument. If multiple datasets are provided, this can also be a list of lists - \
        selecting percentile groups for each algorithm (dictionary interface)
    type :
        The type argument can be "fill", "points", "lines" to define the plot type (See :func:`plot_pf` for more details). If multiple datasets are used (dictionary interface) \
        then this can be a list of types (equal to the number of different datasets provided).
    colorway :
        Colorway is a single colour, or list of colours, for the percentile groups. The colours can be CSS colours such as 'black', 8-digit hexadecimal RGBA integers \
        or strings of RGBA values such as ``rgba(1,1,0,0.5)``. Default is "black". You can use functions ``colour.discrete_colour_gradient`` to create a gradient between two colours \
        In case of multiple datasets ("dictionary interface"), you can use a single list to set the value for each set of lines, or a 2d list to set a value for each line within a surface
    fill_border_colours :
        The same as colorway but defining the boundaries between percentile groups. The default value is to follow colorway. You can set it to `rgb(0,0,0,0)` to make the boundaries invisible
    trace_names :
        Overide the default trace names by providing a list of strings
    line_dashes :
        Select whether lines are dashed. Choices are: 'solid', 'dot', 'dash', 'longdash', 'dashdot', 'longdashdot'. A single string sets the type for all lines. A list sets them individually. \
        In case of multiple datasets ("dictionary interface"), you can use a single list to set the value for each set of lines, or a 2d list to set a value for each line within a surface
    line_width :
        Select the line width (default = 2) of the traces.   Similar interface to line_dashes, colorway etc -> Enter a single value to set all traces. For single datset, a list sets size for all sets \
        For a dictionary of datsets: a list sets the same value for all traces assosciated with that dataset. A list of list individually sets width for every trace in every dataset
    legend_preset :
        See "preset" argument for function ``apply_legend_preset()``
    template :
        Choose layout template for the plot - see `Plotly template tutorial <https://plotly.com/python/templates/>`_ .  Default is "simple_white"
    layout_kwargs :
        Update features of the graph such as title axis titles, colours etc. These additional parameters are passed to \
        plotly update_layout, See here for all the layout features that can be accessed: `Layout Plotly reference <https://plotly.com/python-api-reference/generated/plotly.graph_objects.Layout.html#plotly.graph_objects.Layout/>`_

    Returns
    -------
        The function returns a `Plotly GO figure` object `Figure Plotly reference <https://plotly.com/python-api-reference/generated/plotly.graph_objects.Figure.html#id0/>`_
        This means that the user can customise any part of the graph after it is created

    Notes
    -----
    For more background, see :footcite:t:`LopPaqStu09emaa`.

    References
    ----------
    .. footbibliography::

    """
    if isinstance(dataset, np.ndarray):
        # Plot single EAF data
        if percentiles:
            # If specific values are given, only select data from these given percentiles
            dataset = dataset[np.isin(dataset[:, -1], percentiles)]
        num_percentiles = len(np.unique(dataset[:, -1]))
        def_colours = colour.get_default_fill_colorway(num_percentiles)
        colorway = colour.parse_colorway(
            colorway if colorway else def_colours, num_percentiles
        )
        fill_border_colours = colour.parse_colorway(
            fill_border_colours if fill_border_colours else def_colours,
            num_percentiles,
        )

        fig = create_2d_eaf_plot(
            dataset,
            colorway,
            fill_border_colours,
            type=type,
            line_dashes=line_dashes,
            line_width=line_width,
        )
        fig.update_layout(
            legend_title_text="Percentile",
            xaxis_title="Objective 0",
            yaxis_title="Objective 1",
            title="2D Empirical Attainment Function",
        )

    elif isinstance(dataset, dict):
        """Plot multiple Eaf data. Expect dictionaries with this format:
        {'alg_name' : dataset}
        """
        if percentiles:
            for i, (name, set) in enumerate(dataset.items()):
                if isinstance(percentiles[0], list):
                    # If You want to choose percentiles inside each algorithm, use 2d list
                    if len(percentiles) != len(dataset):
                        raise ValueError("percentile len != dataset len")
                    dataset[name] = set[np.isin(set[:, -1], percentiles[i])]
                elif isinstance(percentiles[0], (int, float)):
                    # Use same percentiles for all datasets
                    dataset[name] = set[np.isin(set[:, -1], percentiles)]
                else:
                    raise TypeError("Incorrect type for percentiles")

        if isinstance(type, str):
            # Set all types to be single type argument
            type = [type] * len(dataset)
        elif len(type) != len(dataset):
            raise ValueError(
                "type list must be same length as dataset dictionary"
            )

        traces_list = []  # Extract list with names from dict
        names_list = []
        for i, (name, set) in enumerate(dataset.items()):
            names_list.append(name)
            traces_list.append(set)

        fig = _combine_2d_figures(
            traces_list,
            names_list,
            type,
            colorway,
            fill_border_colours,
            line_dashes,
            line_width,
        )
        fig.update_layout(
            legend_title_text="Algorithm",
            xaxis_title="Objective 0",
            yaxis_title="Objective 1",
            title="2d Empirical Attainment Function",
        )
    apply_legend_preset(fig, legend_preset)
    fig.update_layout(layout_kwargs, template=template)
    if trace_names:
        # Change trace names
        current_names = [
            trace["name"] for trace in fig.data if trace["showlegend"]
        ]

        if len(trace_names) != len(current_names):
            raise ValueError(
                f"Your names list of len {len(trace_names)} is different to the number of traces: {len(current_names)}"
            )
        for i, tracename in enumerate(current_names):
            fig.update_traces(
                name=trace_names[i], selector=({"name": tracename})
            )

    return fig


def diff_eaf_plot(x, y, n_intervals):
    pass
