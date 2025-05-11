from __future__ import annotations

import numpy as np
from matplotlib import colors
import re

# FIXME add tests for this module


def RGBA_arr_to_string(rgba_arr) -> list:
    """RGBA array to RGBA string.

    Convert a matrix of RGBA values to list of rgba strings. If the input array has only one row, then return single string.

    Parameters
    ----------
    rgba_arr : numpy array (n, 4)
        Numpy array with n rows and 4 columns, where each row represents a different colour and each column is a float representing one of RGBA
        If n=1, then return a single string instead of a list

    Returns
    -------
        A list of `rgba(w,x,y,z)` strings compatible with a plotly colorscale.

    """
    if len(rgba_arr.shape) != 1:
        rgba_strings = []
        rgba_arr = np.asarray(rgba_arr)
        for i in range(rgba_arr.shape[0]):
            # FIXME: Why not do the round to rgba_arr?
            rgba = np.round(rgba_arr[i], 4)
            rgba_strings.append(
                f"rgba({rgba[0]},{rgba[1]},{rgba[2]},{rgba[3]})"
            )
        return rgba_strings
    else:
        return f"rgba({rgba_arr[0]},{rgba_arr[1]},{rgba_arr[2]},{rgba_arr[3]})"


def parse_colour_to_nparray(colour, strings: bool = False):
    """Parse a single colour argument to a (1,4) numpy array representing its RGBA values.

    This can be used to manipulate the values before converting it back to RGBA string using :func:`RGBA_arr_to_string`.

    Parameters
    ----------
    colour : Named CSS colour, RGBA string or 8 character hex RGBA integer.
        A colour argument can be one of the following:
            - Named CSS colour string: "red" or "hotpink"
            - RGBA string: "rgba(0.2, 0.5, 0.1, 0.5)"
            - 8 character hex RGBA integer: 0x1234abcde
    strings :
        If ``strings=True`` then the argument will return a list of ``'rgba(w,x,y,z)'`` strings instead of a numpy array

    Returns
    -------
    numpy array (1,4)
        A (1,4) numpy array where each index represents one of the red, green, blue, alpha values (from 0-1)

    """
    if isinstance(colour, str):
        # Match strings similar to rgba(0,0,0,0) with whitespace allowed
        rgba_matches = re.findall(
            r"rgba *\((?=[\d. ]*[\d]) *([\d.]+) *, *([\d.]+) *, *([\d.]+) *, *([\d.]+) *\)",
            colour,
        )
        rgb_matches = re.findall(
            r"rgb *\((?=[\d. ]*[\d]) *([\d.]+) *, *([\d.]+) *, *([\d.]+) *\)",
            colour,
        )

        if colors.is_color_like(colour):
            # Allow CSS colour strings such as "blue" or "hotpink"
            rgba_colour = np.array(list(colors.to_rgba(colour)), dtype=float)
        elif rgba_matches:
            # Parse strings such as rgba(0, 1, 2,3 ), removing the whitespace
            rgba_colour = np.array(
                [x.strip() for x in list(rgba_matches[0])], dtype=float
            )
        elif rgb_matches:
            # Convert RGB match to RGBA by appending alpha=1
            rgb_matches = list(rgb_matches[0]) + ["1"]
            rgba_colour = np.array(
                [x.strip() for x in rgb_matches], dtype=float
            )
        else:
            raise ValueError(
                f"String color argument : '{colour}' is not recognised. It must be known CSS4 color or 'rgba(w,x,y,z)' string"
            )
    elif isinstance(colour, int):
        # Accept 8 digit hexadecimal number where every 2 digits represent one of (RGBA). Alpha value is the least significant byte
        rgba_colour = (
            np.array(
                [((colour >> 8 * i) & 0xFF) for i in reversed(range(4))],
                dtype=np.float64,
            )
            / 255.0
        )
    else:
        raise TypeError(
            f"Color argument '{colour}' not recognised, may be wrong type"
        )
    if strings:
        return RGBA_arr_to_string(rgba_colour)
    else:
        return rgba_colour


def discrete_opacity_gradient(
    colour: str,
    steps: int,
    start_opacity: float = 0.0,
    end_opacity: float = 1.0,
) -> list:
    """Create opacity gradient colour list for use in plotly colorscales.

    Linearly interpolates between starting and ending opacity.

    Parameters
    ----------
    colour :
        The name of a standard CSS colour.
    steps :
        Number of steps between the start and end opacity. Also the size of the list returned.
    start_opacity, end_opacity :
        Choose what the starting and ending values of opacity are for the list of colours (between 0 and 1).

    Returns
    -------
        A list of RGBA string values compatible with plotly colorscales, interpolating opacity between two values

    """
    rgba_color = parse_colour_to_nparray(colour)
    # Create a 2d array of colours, where the alpha value is linearly interpolated from the start to end value
    gradient = np.tile(rgba_color, ((steps, 1)))
    gradient[:, -1] = np.linspace(start_opacity, end_opacity, num=steps)
    gradient_strings = RGBA_arr_to_string(gradient)
    return gradient_strings


def discrete_colour_gradient(colour_a: str, colour_b: str, steps: int) -> list:
    """Create colour gradient list for use in plotly colorscales.

    Linearly interpolates between two colours using a define amount of steps.

    Parameters
    ----------
    colour_a, colour_b :
        The names of standard CSS colours to create a gradient
    steps :
        Number of steps between between the starting and ending colour. Also the size of the list returned

    Returns
    -------
        A list of RGBA string values compatible with plotly colorscales

    """
    a_rgba = parse_colour_to_nparray(colour_a)
    if steps <= 1:
        # If no gradient, return first colour
        return RGBA_arr_to_string(a_rgba)

    b_rgba = parse_colour_to_nparray(colour_b)
    colour_gradient = np.ndarray((steps, 4))

    for step in range(steps):
        difference = b_rgba - a_rgba
        colour_gradient[step, :] = a_rgba + step * (difference / (steps - 1))
    return RGBA_arr_to_string(colour_gradient)


def get_default_fill_colorway(steps):
    return discrete_opacity_gradient("black", steps=steps, start_opacity=0.6)


def get_2d_colorway_from_colour(steps, colour):
    # Input single colour, return 2d list of colours populated with same colour
    colour = parse_colour_to_nparray(colour, strings=True)
    colour_list = [[colour] * step for step in steps]
    return colour_list


class ColourGradient:
    def __init__(self, colour_a, colour_b):
        self._col_a = colour_a
        self._col_b = colour_b

    def create_gradient(self, steps):
        self.gradient = discrete_colour_gradient(
            self._col_a, self._col_b, steps
        )
        if not isinstance(self.gradient, list):
            self.gradient = [self.gradient]
        return self.gradient


# Parse different types of colorway arguments into an acceptable format, or choose default
def parse_colorway(colorway, length):
    if isinstance(colorway, str) or isinstance(colorway, int):
        colorway = parse_colour_to_nparray(colorway, strings=True)
        colorway = [colorway] * length
    elif isinstance(colorway, list):
        colorway = [
            parse_colour_to_nparray(col, strings=True) for col in colorway
        ]
        # If list smaller than expected, repeat it until it reaches length
        colorway = (
            colorway * (length // len(colorway))
            + colorway[: length % len(colorway)]
        )
    else:
        raise TypeError(
            "Colorway argument needs to be string, int or list of (string or int)"
        )
    return colorway


# Parse "list of list" colourway arguments
def parse_2d_colorway(colorway, default, size_list):
    parsed_2d = colorway if colorway else default
    if isinstance(parsed_2d, str):
        # Set all traces to be same single value
        parsed_2d = [parse_colorway(parsed_2d, size) for size in size_list]
    elif isinstance(parsed_2d, list):
        # Can individually select each trace, or set to the same for each.
        if len(parsed_2d) != len(size_list):
            raise ValueError(
                "2d colorway list should be same length as number of traces"
            )
        parsed_2d = [
            parse_colorway(color_i if color_i else default, size_list[i])
            for i, color_i in enumerate(parsed_2d)
        ]
    else:
        raise TypeError(
            f"type {type(parsed_2d)} not recognised for colorway argument"
        )
    return parsed_2d


# These gradients are generated using a language model and are untested so the values may be wrong
def get_example_gradients(num_steps, choice="scientific"):
    example_gradients = {
        "arctic_exploration": {
            "frosty_blue": ColourGradient(0x93C5FDFF, 0x3693E1FF),
            "icy_cyan": ColourGradient(0xA8E6CFFF, 0x5EB5A6FF),
            "glacier_teal": ColourGradient(0x6CC3D5FF, 0x408C9EFF),
            "snowy_white": ColourGradient(0xF0F8FFFF, 0xC8E1EAFF),
            "arctic_blue": ColourGradient(0x65C1ECFF, 0x3088ABFF),
            "polar_silver": ColourGradient(0xCFD8DCFF, 0x89979FFF),
            "frozen_gray": ColourGradient(0xABB9C2FF, 0x6C7D86FF),
            "cold_ice": ColourGradient(0xB5D9EBFF, 0x7FA8D4FF),
            "crisp_blue": ColourGradient(0x6DAAD5FF, 0x3773A0FF),
            "arctic_sky": ColourGradient(0x9EC9E8FF, 0x4B80A7FF),
        },
        "scientific": {
            "gray_to_black": ColourGradient(0x808080FF, 0x000000FF),
            "blue_to_gray": ColourGradient(0x1F77B4FF, 0x808080FF),
            "green_to_gray": ColourGradient(0x2CA02CFF, 0x808080FF),
            "orange_to_gray": ColourGradient(0xFF7F0EFF, 0x808080FF),
            "purple_to_gray": ColourGradient(0x9467BDFF, 0x808080FF),
            "teal_to_gray": ColourGradient(0x17BECFFF, 0x808080FF),
            "red_to_gray": ColourGradient(0xD62728FF, 0x808080FF),
            "pink_to_gray": ColourGradient(0xE377C2FF, 0x808080FF),
            "brown_to_gray": ColourGradient(0x8C564BFF, 0x808080FF),
            "blue_to_cyan": ColourGradient(0x1F77B4FF, 0x17BECFFF),
        },
        "contrast": {
            "frosty_blue": ColourGradient(0x93C5FDFF, 0x3693E1FF),
            "vibrant_green": ColourGradient(0x00FF00FF, 0x00CC00FF),
            "intense_purple": ColourGradient(0x9B59B6FF, 0x5D328BFF),
            "brilliant_orange": ColourGradient(0xFFA500FF, 0xFF8000FF),
            "deep_cyan": ColourGradient(0x17BECFFF, 0x008B8BFF),
            "hot_pink": ColourGradient(0xFF69B4FF, 0xFF1493FF),
            "bright_turquoise": ColourGradient(0x40E0D0FF, 0x00CED1FF),
            "fiery_red": ColourGradient(0xFF0000FF, 0xCC0000FF),
            "luminous_lime": ColourGradient(0x00FF00FF, 0x32CD32FF),
            "electric_yellow": ColourGradient(0xFFFF00FF, 0xFFCC00FF),
        },
        "warm": {
            "red_to_yellow": ColourGradient(0xFF0000FF, 0xFFFF00FF),
            "orange_to_yellow": ColourGradient(0xFFA500FF, 0xFFFF00FF),
            "orange_to_red": ColourGradient(0xFFA500FF, 0xFF0000FF),
            "brown_to_orange": ColourGradient(0x8B4513FF, 0xFFA500FF),
            "red_to_brown": ColourGradient(0xFF0000FF, 0x8B4513FF),
            "yellow_to_brown": ColourGradient(0xFFFF00FF, 0x8B4513FF),
            "red_to_pink": ColourGradient(0xFF0000FF, 0xFF69B4FF),
            "orange_to_pink": ColourGradient(0xFFA500FF, 0xFF69B4FF),
            "yellow_to_red": ColourGradient(0xFFFF00FF, 0xFF0000FF),
            "yellow_to_orange": ColourGradient(0xFFFF00FF, 0xFFA500FF),
        },
    }

    if isinstance(num_steps, list):
        final = []
        gradient_list = list(example_gradients[choice].items())
        for i, step in enumerate(num_steps):
            gradient = gradient_list[i][1].create_gradient(step)
            final.append(gradient)
        return final
    elif isinstance(num_steps, int):
        return [
            gradient.create_gradient(num_steps)
            for name, gradient in example_gradients[choice].items()
        ]
