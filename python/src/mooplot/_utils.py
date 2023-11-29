# FIXME Seems like these similar parsing functions can be combined
def parse_line_dash(dash, size, default):
    dash_parsed = dash if dash else default
    allowed_names = ["solid", "dot", "dash", "longdash", "dashdot", "longdashdot"]
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
        raise TypeError(f"type {type(dash)} not recognised for dashed line argument")
    return dash_parsed


def parse_2d_line_dash(dash, size_list, default):
    dash_parsed = dash if dash else default
    if isinstance(dash_parsed, str):
        # Set all traces to be same single value
        dash_parsed = [parse_line_dash(dash, size, default) for size in size_list]
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
        if False in [isinstance(line_i, (int, float)) for line_i in line_parsed]:
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
        parsed_2d = [parse_line_width(parsed_2d, size, default) for size in size_list]
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
