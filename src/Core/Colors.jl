
export get_color, opacify, color_shift, shift_color

suggested_pallete = [
    :steelblue,
    :khaki3,
    :palevioletred1,
    :gray60
]

"""
    get_color(:symbol)

Gets an RGB color based on a symbol representing it


# Arguments
- `color::Symbol`: The color to translate to RGB
"""
function get_color(color::Symbol)
    parse(RGB, color)
end

"""
    get_color("color")

Gets an RGB color based on a string representing it

# Arguments
- `color::String`: The color to translate to RGB
"""
function get_color(color::String)
    parse(RGB, color)
end

"""
    get_color(color::RGB)

Gets an RGB color based on an already existing RGB object

# Arguments
- `color::RGB`: The color to translate to copy
"""
function get_color(color::RGB)
    color
end


"""
    opacify(color, opacity)

Get an RGBA based on a color value, but with specified opacity

# Arguments
- `color`: The color to opacify
- `opacity::AbstractFloat`: The opacity to add (0-1)
"""
function opacify(color, opacity::AbstractFloat)
    use_color = get_color(color)
    RGBA(use_color.r, use_color.g, use_color.b, opacity)
end

"""
    color_shift(color1, color2)

Get a vector representing the shift in RGB values between 2 colors

# Arguments
- `start`: The starting color for the vector
- `target`: The target color that the vector points to
"""
function color_shift(start, target)
    startc = get_color(start)
    targetc = get_color(target)

    Start = Float32[startc.r, startc.g, startc.b]
    Target = Float32[targetc.r, targetc.g, targetc.b]

    diff = Target - Start

    return Point3f(diff)
end

"""
    shift_color(color, shift)

Shift a color by some vector covering RGB values

# Arguments
- `color`: The original color to shift
- `shift::Point3f`: The vector to apply and get a new color with
"""
function shift_color(color, shift::Point3f)
    c = get_color(color)
    C = [c.r, c.g, c.b] + shift
    return RGB(C[1], C[2], C[3])
end
