export EuclidCircle, EuclidCircle2f, circle, show_complete, hide, animate

"""
    EuclidCircle{N}

Describes a circle to be drawn and animated in Euclid diagrams
"""
mutable struct EuclidCircle{N}
    center::Observable{Point{N, Float32}}
    radius::Observable{Float32}
    startθ::Observable{Float32}
    endθ::Observable{Float32}
    tilts::Observable{Vector{Float32}}
    plots
    current_width::Observable{Float32}
    show_width::Observable{Float32}
end
EuclidCircle2f = EuclidCircle{2}

"""
    circle(center, radius[, startθ=0f0, endθ=2f0π, width=2f0, color=:blue, linestyle=:solid])

Sets up a new circle in a Euclid Diagram for drawing.

# Arguments
- `center::Point2f` : The center point of the circle
- `radius::Float32` : The radius of the circle to draw
- `startθ::Float32` : The starting angle; default is to draw whole circle
- `endθ::Float32` : The ending angle; default is to draw whole circle
- `width::Float32` : Width of the line to draw the circle
- `color` : Color of the circle to draw
- `linestyle` : The style of the line to draw for the circle
"""
function circle(center::Observable{Point2f}, radius::Observable{Float32};
                startθ::Union{Float32, Observable{Float32}}=0f0,
                endθ::Union{Float32, Observable{Float32}}=2f0π,
                width::Union{Float32, Observable{Float32}}=1f0,
                color=:blue, linestyle=:solid)

    observable_width = Observable(0f0)
    observable_show_width = width isa Observable{Float32} ? width : Observable(width)
    observable_start = startθ isa Observable{Float32} ? startθ : Observable(startθ)
    observable_end = endθ isa Observable{Float32} ? endθ : Observable(endθ)

    points = @lift([Point2f($radius*cos(θ)+($center)[1], $radius*sin(θ)+($center)[2])
                        for θ in $observable_start:(π/180):$observable_end])


    plots = lines!(points, color=color, linewidth=(observable_width),
                    linestyle=linestyle)

    EuclidCircle2f(center, radius, observable_start, observable_end,
        Observable([0f0]), plots,
        observable_width, observable_show_width)
end

function circle(center::Point2f, radius::Observable{Float32};
                startθ::Union{Float32, Observable{Float32}}=0f0,
                endθ::Union{Float32, Observable{Float32}}=2f0π,
                width::Union{Float32, Observable{Float32}}=1f0,
                color=:blue, linestyle=:solid)

    circle(Observable(center), radius; startθ=startθ, endθ=endθ, width=width,
            color=color, linestyle=linestyle)
end
function circle(center::Observable{Point2f}, radius::Float32;
                startθ::Union{Float32, Observable{Float32}}=0f0,
                endθ::Union{Float32, Observable{Float32}}=2f0π,
                width::Union{Float32, Observable{Float32}}=1f0,
                color=:blue, linestyle=:solid)

    circle(center, Observable(radius); startθ=startθ, endθ=endθ, width=width,
            color=color, linestyle=linestyle)
end
function circle(center::Point2f, radius::Float32;
                startθ::Union{Float32, Observable{Float32}}=0f0,
                endθ::Union{Float32, Observable{Float32}}=2f0π,
                width::Union{Float32, Observable{Float32}}=1f0,
                color=:blue, linestyle=:solid)

    circle(Observable(center), Observable(radius); startθ=startθ, endθ=endθ, width=width,
            color=color, linestyle=linestyle)
end

"""
    show_complete(circle)

Completely show previously defined circle in a Euclid diagram

# Arguments
- `circle::EuclidCircle`: The circle to completely show
"""
function show_complete(circle::EuclidCircle)
    circle.current_width[] = circle.show_width[]
end

"""
    hide(circle)

Completely hide previously defined circle in a Euclid diagram

# Arguments
- `circle::EuclidCircle`: The circle to completely hide
"""
function hide(circle::EuclidCircle)
    circle.current_width[] = 0f0
end

"""
    animate(circle, hide_until, max_at, t[, fade_start=0f0, fade_end=0f0])

Animate drawing and perhaps then hiding circle drawn in a Euclid diagram

# Arguments
- `circle::EuclidCircle`: The circle to animate in the diagram
- `hide_until::AbstractFloat`: The point to hide the circle until
- `max_at::AbstractFloat`: The time to max drawing the circle at -- when it is fully drawn
- `t::AbstractFloat`: The current timeframe of the animation
- `fade_start::AbstractFloat`: When to begin fading the circle away from the diagram
- `fade_end::AbstractFloat`: When to end fading the circle awawy from the diagram -- it will be hidden entirely
"""
function animate(circle::EuclidCircle, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                 fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)

    perform(t, hide_until, max_at, fade_start, fade_end,
        () -> circle.current_width[] = 0f0,
        () -> circle.current_width[] = circle.show_width[],
        () -> circle.current_width[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            circle.current_width[] = circle.show_width[] * on_t
        else
            on_t = (t-fade_start)/(fade_end-fade_start)
            circle.current_width[] = circle.show_width[]- (circle.show_width[] * on_t)
        end
    end
end



