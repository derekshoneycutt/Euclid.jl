
export EuclidCircle2fHighlight, highlight, show_complete, hide, animate

"""
    EuclidCircle2fHighlight

Describes highlighting a circle in a Euclid diagram
"""
mutable struct EuclidCircle2fHighlight
    baseOn::EuclidCircle2f
    plots
    current_width::Observable{Float32}
    current_progress::Observable{Float32}
    max_width::Observable{Float32}
end


"""
    highlight(circle[, width=2f0, color=:red, larger=false])

Set up highlighting a circle in a Euclid diagram

# Arguments
- `circle::EuclidCircle2f`: The circle to highlight in the diagram
- `width::Union{Float32, Observable{Float32}}`: The width of the lines to draw the highlight
- `color`: The color to use in highlighting the circle
"""
function highlight(circle::EuclidCircle2f;
                    width::Union{Float32, Observable{Float32}}=2f0, color=:red)

    center = circle.center
    radius = circle.radius
    startθ = circle.startθ
    endθ = circle.endθ
    obs_width = width isa Observable{Float32} ? width : Observable(width)
    current_progress = Observable(0f0)

    current_theta = @lift($startθ + ($endθ - $startθ + 0.0001)*$current_progress)
    curve_point(θ, r, cx, cy) = Point2f0(r * cos(θ) + cx, r * sin(θ) + cy)
    curve_points = @lift(
        [curve_point(θ, $radius, ($center)[1], ($center)[2])
            for θ in ($startθ):(π/180):($current_theta)])

    observable_highlight = Observable(0f0)
    use_color = get_color(color)

    plots = [
        lines!(curve_points, color=opacify(use_color, 0.6), linewidth=observable_highlight),
        lines!(@lift([$center, curve_point($current_theta, $radius, ($center)[1], ($center)[2])]),
                linewidth=@lift($current_progress >= 1f0 || $current_progress == 0f0 ? 0f0 : $obs_width),
                color=opacify(use_color, 0.6))
    ]

    EuclidCircle2fHighlight(circle, plots, observable_highlight, current_progress, obs_width)
end

"""
    show_complete(circle)

Complete a previously defined highlight operation for a circle in a Euclid diagram. It will be fully highlighted.

# Arguments
- `circle::EuclidCircle2fHighlight`: The description of the highlight to finish
"""
function show_complete(circle::EuclidCircle2fHighlight)
    circle.current_width[] = circle.max_width[]
    circle.current_progress[] = 1f0
end

"""
    hide(circle)

Hide highlights of a circle in a Euclid diagram

# Arguments
- `circle::EuclidCircle2fHighlight`: The description of the highlight to completely hide
"""
function hide(circle::EuclidCircle2fHighlight)
    circle.current_width[] = 0f0
    circle.current_progress[] = 0f0
end

"""
    animate(circle, hide_until, max_at, min_at, t)

Animate highlighting a circle in a Euclid diagram

# Arguments
- `circle::EuclidCircle2fHighlight`: The circle to animate in the diagram
- `hide_until::AbstractFloat`: The time point to begin highlighting the circle at
- `max_at::AbstractFloat`: The time point to have maximum highlight at
- `min_at::AbstractFloat`: The time point to finish going back to no more highlighting
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    circle::EuclidCircle2fHighlight, hide_until::AbstractFloat, max_at::AbstractFloat, min_at::AbstractFloat, t::AbstractFloat)

    perform(t, hide_until, max_at, max_at + 0.00001, min_at,
        () -> circle.current_width[] = 0f0,
        () -> circle.current_width[] = line.max_width[],
        () -> circle.current_width[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            circle.current_width[] = circle.max_width[]
            circle.current_progress[] = on_t
        else
            on_t = (t-max_at)/(min_at-max_at)
            circle.current_width[] = circle.max_width[] - (circle.max_width[] * on_t)
            circle.current_progress[] = 1f0
        end
    end
end
