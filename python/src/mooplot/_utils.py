def _parse_plot_type(plot_type: str, dimension: int):
    if not isinstance(plot_type, str):
        raise TypeError("plot 'type' must be a string")
    plot_type = plot_type.replace(" ", "").lower().split(",")
    if len(plot_type) > 2:
        raise ValueError(f"Too many commas in plot 'type={plot_type}'")
    allowed_types = ["lines", "points", "surface", "cube", "fill"]
    selected_types = [
        t for t in allowed_types if any(t.startswith(x) for x in plot_type)
    ]

    if dimension == 2 and (
        "surface" in selected_types or "cube" in selected_types
    ):
        raise ValueError(
            "Plot types 'surface' and 'cube' are only valid for plotting 3 objectives"
        )

    if "points" in selected_types:
        if "lines" in selected_types:
            return "lines+markers"
        elif "surface" in selected_types:
            return "surface+markers"
        else:
            return "markers"
    elif "lines" in selected_types:
        return "lines"
    elif "surface" in selected_types:
        return "surface"
    elif "cube" in selected_types:
        return "cube"
    elif "fill" in selected_types:
        return "fill"
    else:
        raise ValueError(f"Plot 'type={plot_type} not recognised")


# FIXME Seems like these similar parsing functions can be combined
def parse_line_dash(dash, size, default):
    dash_parsed = dash if dash else default
    allowed_names = [
        "solid",
        "dot",
        "dash",
        "longdash",
        "dashdot",
        "longdashdot",
    ]
    if isinstance(dash_parsed, str):
        if dash_parsed not in allowed_names:
            raise ValueError(
                f"'{dash_parsed}' not recognised as line dash type. Allowed types are {allowed_names}"
            )
        dash_parsed = [dash_parsed] * size
    elif isinstance(dash_parsed, list):
        if False in [d in allowed_names for d in dash_parsed]:
            raise ValueError(
                f"Dash list {dash_parsed} contains an unrecognised dash type.\nAllowed types are {allowed_names}"
            )
        dash_parsed = (
            dash_parsed * (size // len(dash_parsed))
            + dash_parsed[: size % len(dash_parsed)]
        )  # Make list same length as size, repeating if its smaller
    else:
        raise TypeError(
            f"type {type(dash)} not recognised for dashed line argument"
        )
    return dash_parsed


def parse_2d_line_dash(dash, size_list, default):
    dash_parsed = dash if dash else default
    if isinstance(dash_parsed, str):
        # Set all traces to be same single value
        dash_parsed = [
            parse_line_dash(dash, size, default) for size in size_list
        ]
    elif isinstance(dash_parsed, list):
        # Can individually select each trace, or set to the same for each
        if len(dash_parsed) != len(size_list):
            raise ValueError(
                "2d dash_size list should be same length as number of traces"
            )
        dash_parsed = [
            parse_line_dash(dash_i, size_list[i], default)
            for i, dash_i in enumerate(dash_parsed)
        ]
    else:
        raise TypeError(f"type {type(dash)} not recognised for dash argument")
    return dash_parsed


def parse_line_width(line, size, default):
    line_parsed = line if line else default
    if isinstance(line_parsed, (int, float)):
        line_parsed = [line_parsed] * size
    elif isinstance(line_parsed, list):
        if False in [
            isinstance(line_i, (int, float)) for line_i in line_parsed
        ]:
            raise TypeError("line size wrong type, must be a number")
        line_parsed = (
            line_parsed * (size // len(line_parsed))
            + line_parsed[: size % len(line_parsed)]
        )  # Make list same length as size, repeating if its smaller
    else:
        raise TypeError(
            f"line width argument {line_parsed}, type {str(type(line_parsed))} not recognised"
        )
    return line_parsed


def parse_2d_line_width(line, size_list, default):
    parsed_2d = line if line else default
    if isinstance(parsed_2d, (int, float)):
        # Set all traces to be same single value
        parsed_2d = [
            parse_line_width(parsed_2d, size, default) for size in size_list
        ]
    elif isinstance(parsed_2d, list):
        # Can individually select each trace, or set to the same for each
        if len(parsed_2d) != len(size_list):
            raise ValueError(
                "2d line size argument should be same length as number of traces"
            )
        parsed_2d = [
            parse_line_width(line_i, size_list[i], default)
            for i, line_i in enumerate(parsed_2d)
        ]
    else:
        raise TypeError(
            f"type {type(parsed_2d)} not recognised for dashed line argument"
        )
    return parsed_2d
