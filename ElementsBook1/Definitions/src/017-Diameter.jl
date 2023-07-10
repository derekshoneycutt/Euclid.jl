export diameter

"""
    diameter(circle, θ[, width=1f0, color=:blue, linestyle=:solid])

Get a diameter line across a circle at a given theta angle

# Arguments
- `circle::EuclidCircle` : The circle to get a diameter line for
- `θ::AbstractFloat` : The angle to get the diameter for
- `width::Union{Float32, Observable{Float32}}` : The width of the line to draw
- `color` : The color of the line to draw
- `linestyle` : The style of the line to draw
"""
function diameter(circle::EuclidCircle2f, θ::AbstractFloat;
    width::Union{Float32, Observable{Float32}}=1f0, color=:blue, linestyle=:solid)

    c = circle.center
    r = circle.radius
    point1 = @lift(Point2f0(cos(θ), sin(θ)) * $r + $c)
    point2 = @lift(Point2f0(cos(θ + π), sin(θ + π)) * $r + $c)

    line(point1, point2, width=width, color=color, linestyle=linestyle)
end
