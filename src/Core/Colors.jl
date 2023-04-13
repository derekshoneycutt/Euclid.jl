
export get_color, opacify

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
