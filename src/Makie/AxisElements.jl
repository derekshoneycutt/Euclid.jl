
export euclid_axis, euclid_axis3,
    circle_legend, circle_outline_legend, semicircle_outline_legend, square_legend,
    line_legend, vline_legend,
    acute_angle_legend, right_angle_legend, obtuse_angle_legend

"""
    euclid_axis(f[, title=""])

Setup an axis for drawing Euclid diagrams

# Arguments
- `f`: The figure to draw the axis on. (Consider using a specific scene.)
- `title`: The title of the axis to draw. Default is empty string.
"""
function euclid_axis(f; title="")
    Axis(f,
        aspect=DataAspect(),
        title=title,
        xticklabelsvisible=false, yticklabelsvisible=false,
        yticksvisible=false, xticksvisible=false,
        xgridvisible=false, ygridvisible=false,
        topspinevisible=false, bottomspinevisible=false,
        leftspinevisible=false, rightspinevisible=false)
end


"""
    euclid_axis3(f[, title="")

Setup a 3D axis for drawing Euclid diagrams

# Arguments
- `f`: The figure to draw the axis on. (Consider using a specific scene.)
- `title`: The title of the axis to draw. Default is empty string.
"""
function euclid_axis3(f; title="",
        azimuth::Float32=0.5f0π, elevation::Float32=0.5f0π,)
    Axis3(f,
        aspect=:data,
        title=title,
        azimuth=azimuth, elevation=elevation,
        xlabel="", ylabel="", zlabel="",
        xticklabelsvisible=false, yticklabelsvisible=false,
        yticksvisible=false, xticksvisible=false,
        zticksvisible=false, zticklabelsvisible=false,
        xgridvisible=false, ygridvisible=false, zgridvisible=false,
        xspinesvisible=false, yspinesvisible=false, zspinesvisible=false)
end

"""
    circle_legend([width=0.1f0, color=:blue, center=Point2f0(0.5,0.5)])

Create a circle legend element for displaying on Euclid diagrams

# Arguments
- `width::AbstractFloat`: The width, as a radius, of the circle to draw
- `color`: The color of circle to draw
- `center::Point2f`: Where to draw the center of the circle at, defaults to center position
"""
function circle_legend(; width::AbstractFloat=0.1f0, color=:blue, center::Point2f=Point2f0(0.5,0.5))
    axis_element_points = [Point2f0(center[1] + cos(t) * width, center[2] + sin(t) * width) for t in 0:(π/180):2π]
    PolyElement(points=axis_element_points, color=color, strokecolor=color, strokewidth=1)
end

"""
    circle_outline_legend([width=0.1f0, color=:blue, center=Point2f0(0.5,0.5)])

Create a circle legend element for displaying on Euclid diagrams

# Arguments
- `width::AbstractFloat`: The width, as a radius, of the circle to draw
- `color`: The color of circle to draw
- `center::Point2f`: Where to draw the center of the circle at, defaults to center position
"""
function circle_outline_legend(; width::AbstractFloat=0.1f0, color=:blue,
                                linestyle=:solid, linewidth::AbstractFloat=1.5f0,
                                center::Point2f=Point2f0(0.5,0.5))
    axis_element_points = [Point2f0(center[1] + cos(t) * width, center[2] + sin(t) * width) for t in 0:(π/180):2π]
    LineElement(points=axis_element_points, color=color, linestyle=linestyle, linewidth=linewidth)
end

"""
    semicircle_outline_legend([width=0.1f0, color=:blue, center=Point2f0(0.5,0.5)])

Create a semicircle legend element for displaying on Euclid diagrams

# Arguments
- `width::AbstractFloat`: The width, as a radius, of the circle to draw
- `color`: The color of circle to draw
- `center::Point2f`: Where to draw the center of the circle at, defaults to center position
"""
function semicircle_outline_legend(; width::AbstractFloat=0.1f0, color=:blue,
                                linestyle=:solid, linewidth::AbstractFloat=1.5f0,
                                center::Point2f=Point2f0(0.5,0.5))
    axis_element_points = [Point2f0(center[1] + cos(t) * width, center[2] + sin(t) * width) for t in 0:(π/180):π]
    axis_element_points = vcat(axis_element_points, [Point2f0(center[1] + cos(0) * width, center[2] + sin(0) * width)])
    LineElement(points=axis_element_points, color=color, linestyle=linestyle, linewidth=linewidth)
end

"""
    square_legend([width=0.1f0, color=:blue, center=Point2f0(0.5,0.5)])

Create a square legend element for displaying on Euclid diagrams

# Arguments
- `width::AbstractFloat`: The width of the square to draw
- `color`: The color of square to draw
- `center::Point2f`: Where to draw the center of the square at, defaults to center position
"""
function square_legend(; width::AbstractFloat=1f0, color=:blue, center::Point2f=Point2f0(0.5,0.5))
    from_center = width / 2f0
    do_box = [Point2f0(center .- from_center),  Point2f0(center - [from_center, -from_center]),
              Point2f0(center .+ from_center), Point2f0(center - [-from_center, from_center])]
    PolyElement(points=do_box, color=color, strokecolor=color, strokewidth=0)
end

"""
    triangle_legend([width=0.1f0, color=:blue, center=Point2f0(0.5,0.5)])

Create a triangle legend element for displaying on Euclid diagrams

# Arguments
- `color`: The color of square to draw
"""
function square_legend(; color=:blue)
    do_box = [Point2f0(0, 0), Point2f0(1, 0), Piont2f0(0.5, 0.86602545)]
    PolyElement(points=do_box, color=color, strokecolor=color, strokewidth=0)
end

"""
    line_legend([width=0.1f0, color=:blue, linestyle=:solid, linewidth=1.5f0, start_y=0.5f0, end_y=0.5f0])

Create a horizontal/diagonal line legend element for displaying on Euclid diagrams

# Arguments
- `width::AbstractFloat`: The width of the line to draw. Is centered horizontally.
- `color`: The color of line to draw
- `linestyle`: The style of line to draw
- `linewidth::AbstractFloat`: The width of the line to draw
- `start_y::AbstractFloat`: The starting y-position to draw the line at. Defaults in the middle.
- `end_y::AbstractFloat`: The ending y-position to draw the line at. Defaults in the middle.
"""
function line_legend(; width::AbstractFloat=0.1f0, color=:blue,
                       linestyle=:solid, linewidth::AbstractFloat=1.5f0,
                       start_y::AbstractFloat=0.5f0, end_y::AbstractFloat=0.5f0)
    start_line = width >= 1 ? 0 : width / 2f0
    end_line = width >= 1 ? 1 : 1 - (width / 2f0)
    axis_element_points = [Point2f0(start_line, start_y), Point2f0(end_line, end_y)]
    LineElement(points=axis_element_points, color=color, linestyle=linestyle, linewidth=linewidth)
end

"""
    vline_legend(x[, color=:blue, linestyle=:solid, linewidth=1.5f0, start_y=0.5f0, end_y=0.5f0])

Create a vertical line legend element for displaying on Euclid diagrams

# Arguments
- `x::AbstractFloat`: The x-position to draw the line at.
- `color`: The color of line to draw
- `linestyle`: The style of line to draw
- `linewidth::AbstractFloat`: The width of the line to draw
- `start_y::AbstractFloat`: The starting y-position to draw the line at. Defaults in the middle.
- `end_y::AbstractFloat`: The ending y-position to draw the line at. Defaults in the middle.
"""
function vline_legend(x::AbstractFloat; color=:blue,
                       linestyle=:solid, linewidth::AbstractFloat=1.5f0,
                       start_y::AbstractFloat=0.5f0, end_y::AbstractFloat=0.5f0)
    axis_element_points = [Point2f0(x, start_y), Point2f0(x, end_y)]
    LineElement(points=axis_element_points, color=color, linestyle=linestyle, linewidth=linewidth)
end

"""
    acute_angle_legend([color=:blue, linewidth=1.5f0, linestyle=:solid])

Create an acute angle legend element for displaying on Euclid diagrams

# Arguments
- `color`: The color of angle lines to draw
- `linewidth::AbstractFloat`: The width of the angle lines to draw
- `linestyle`: The style of angle lines to draw
- `draw_angle`: Whether to draw the angle between the lines or just the lines
"""
function acute_angle_legend(; color=:blue, linewidth::AbstractFloat=1.5f0, linestyle=:solid, draw_angle=:filled)
    origin = Point2f0(0,0)
    base_extrem = Point2f0(1,0)
    angle_extrem = Point2f0(cos(π/4), sin(π/4))
    angle_lines = [Point2f0(cos(θ) * 0.5f0, sin(θ) * 0.5f0) for θ in 0:(π/40):(π/4)]
    angle_poly = [Point2f0(p) for p in vcat(angle_lines, [origin])]

    lines = LineElement(points=[base_extrem, origin, angle_extrem], color=color, linewidth=linewidth, linestyle=linestyle)

    if draw_angle == :outline
        outline = LineElement(points=angle_lines, color=color, linewidth=linewidth, linestyle=linestyle)
        lines = [lines, outline]
    elseif draw_angle == :filled
        lines = [lines, PolyElement(points=angle_poly, color=color, strokecolor=color, strokewidth=0)]
    end

    lines
end

"""
    right_angle_legend([color=:blue, linewidth=1.5f0, linestyle=:solid])

Create a right angle legend element for displaying on Euclid diagrams

# Arguments
- `color`: The color of angle lines to draw
- `linewidth::AbstractFloat`: The width of the angle lines to draw
- `linestyle`: The style of angle lines to draw
- `draw_angle`: Whether to draw the angle between the lines or just the lines
"""
function right_angle_legend(; color=:blue, linewidth::AbstractFloat=1.5f0, linestyle=:solid, draw_angle=:filled)
    origin = Point2f0(0,0)
    base_extrem = Point2f0(1,0)
    angle_extrem = Point2f0(0,1)
    angle_lines = [Point2f0(0.5,0), Point2f0(0.5, 0.5), Point2f0(0,0.5)]
    angle_poly = [Point2f0(p) for p in vcat(angle_lines, [origin])]

    lines = LineElement(points=[base_extrem, origin, angle_extrem], color=color, linewidth=linewidth, linestyle=linestyle)

    if draw_angle == :outline
        outline = LineElement(points=angle_lines, color=color, linewidth=linewidth, linestyle=linestyle)
        lines = [lines, outline]
    elseif draw_angle == :filled
        lines = [lines, PolyElement(points=angle_poly, color=color, strokecolor=color, strokewidth=0)]
    end

    lines
end

"""
    obtuse_angle_legend([color=:blue, linewidth=1.5f0, linestyle=:solid])

Create a right angle legend element for displaying on Euclid diagrams

# Arguments
- `color`: The color of angle lines to draw
- `linewidth::AbstractFloat`: The width of the angle lines to draw
- `linestyle`: The style of angle lines to draw
- `draw_angle`: Whether to draw the angle between the lines or just the lines
"""
function obtuse_angle_legend(; color=:blue, linewidth::AbstractFloat=1.5f0, linestyle=:solid, draw_angle=:filled)
    origin = Point2f0(0.15,0)
    base_extrem = Point2f0(1,0)
    angle_extrem = Point2f0(cos(3π/4) * 0.5f0, sin(3π/4))
    angle_lines = [Point2f0(cos(θ) * 0.25f0 + 0.15f0, sin(θ) * 0.25f0) for θ in 0:(π/80):(3π/4)]
    angle_poly = [Point2f0(p) for p in vcat(angle_lines, [origin])]

    lines = LineElement(points=[base_extrem, origin, angle_extrem], color=color, linewidth=linewidth, linestyle=linestyle)

    if draw_angle == :outline
        outline = LineElement(points=angle_lines, color=color, linewidth=linewidth, linestyle=linestyle)
        lines = [lines, outline]
    elseif draw_angle == :filled
        lines = [lines, PolyElement(points=angle_poly, color=color, strokecolor=color, strokewidth=0)]
    end

    lines
end
