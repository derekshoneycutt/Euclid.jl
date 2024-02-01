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
function diameter(label::String, circle::EuclidCircle2f, θ::Float32;
        width::Float32=1f0, opacity::Float32=0f0,
        color=:blue, linestyle=:solid)
    def = diameter(circle.data[], θ, width=width, opacity=opacity, color=color)
    line(label, def, linestyle=linestyle)
end
function diameter(label::String, circle::EuclidCircle3f, θ::Float32;
        width::Float32=0.01f0, opacity::Float32=0f0,
        color=:blue, linestyle=:solid)
    def = diameter(circle.data[], θ, width=width, opacity=opacity, color=color)
    line(label, def, linestyle=linestyle)
end
