
export EuclidAngle2fHighlight, highlight, show_complete, hide, animate

"""
    EuclidAngle2fHighlight

Describes highlighting an angle in a Euclid diagram
"""
mutable struct EuclidAngle2fHighlight
    baseOn::EuclidAngle2f
    plots
    current_width::Observable{Float32}
    current_dot_width::Observable{Float32}
    max_width::Observable{Float32}
    max_dot_width::Observable{Float32}
end

"""
    highlight(angle[, width=2f0, color=:red, larger=false])

Set up highlighting an angle in a Euclid diagram

# Arguments
- `angle::EuclidAngle2f`: The angle to highlight in the diagram
- `width::Union{Float32, Observable{Float32}}`: The width of the lines to draw the highlight
- `color`: The color to use in highlighting the angle
- `larger::Bool`: Whether to always highlight the larger angle (otherwise will highlight smaller)
"""
function highlight(angle::EuclidAngle2f;
                    width::Union{Float32, Observable{Float32}}=2f0, color=:red,
                    larger::Bool=false)

    center = angle.point
    extremA = angle.extremityA
    extremB = angle.extremityB
    obs_width = width isa Observable{Float32} ? width : Observable(width)

    angle_data = get_angle_measure_observables(center, extremA, extremB, larger, 0.25f0)

    dot_begin = @lift(isapprox($(angle_data.θ), π, atol=0.0001) ?
                        ([cos(π/2f0 + $(angle_data.θ_start)); sin(π/2f0 + $(angle_data.θ_start))]*($(angle_data.draw_at)/1.5f0) +
                            first($(angle_data.angle_range))) :
                        $center)
    dot_end = @lift(isapprox($(angle_data.θ), π, atol=0.0001) ?
                        ([cos(π/2f0 + $(angle_data.θ_start)); sin(π/2f0 + $(angle_data.θ_start))]*($(angle_data.draw_at)/1.5f0) +
                            last($(angle_data.angle_range))) :
                        (larger ?
                            ([cos(π + $(angle_data.θ_start)); sin(π + $(angle_data.θ_start))]*($(angle_data.draw_at)*1.25f0) +
                                $center) :
                            ($(angle_data.θ) > π/2 ?
                                ([cos(π/2f0 + $(angle_data.θ_start)); sin(π/2f0 + $(angle_data.θ_start))]*($(angle_data.draw_at)*1.25f0) +
                                    $center) :
                                $center)))

    dot_width = @lift(isapprox($(angle_data.θ), π/2, atol=0.0001) || larger ? 0.6f0 : 0f0)

    observable_highlight = Observable(0f0)
    observable_dot_highlight = Observable{Float32}(0f0)
    use_color = get_color(color)

    plots = [
        lines!(@lift([$extremA, $center, $extremB]),
                color=opacify(use_color, 0.6),
                linewidth=observable_highlight),
        lines!(angle_data.angle_range,
                color=opacify(use_color, 0.6),
                linewidth=observable_highlight),
        lines!(@lift([Point2f0($dot_begin), Point2f0($dot_end)]), linestyle=:dot,
                color=@lift(opacify(use_color, $observable_dot_highlight)),
                linewidth=(obs_width[] / 4f0))
    ]

    EuclidAngle2fHighlight(angle, plots, observable_highlight, observable_dot_highlight, obs_width, dot_width)
end

"""
    show_complete(angle)

Complete a previously defined highlight operation for an angle in a Euclid diagram. It will be fully highlighted.

# Arguments
- `angle::EuclidAngle2fHighlight`: The description of the highlight to finish
"""
function show_complete(angle::EuclidAngle2fHighlight)
    angle.current_width[] = angle.max_width[]
    angle.current_dot_width[] = angle.max_dot_width[]
end

"""
    hide(angle)

Hide highlights of an angle in a Euclid diagram

# Arguments
- `angle::EuclidAngle2fHighlight`: The description of the highlight to completely hide
"""
function hide(angle::EuclidAngle2fHighlight)
    angle.current_width[] = 0f0
    angle.current_dot_width[] = 0f0
end

"""
    animate(angle, hide_until, max_at, min_at, t)

Animate highlighting an angle in a Euclid diagram

# Arguments
- `angle::EuclidAngle2fHighlight`: The angle to animate in the diagram
- `hide_until::AbstractFloat`: The time point to begin highlighting the angle at
- `max_at::AbstractFloat`: The time point to have maximum highlight at
- `min_at::AbstractFloat`: The time point to finish going back to no more highlighting
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    angle::EuclidAngle2fHighlight, hide_until::AbstractFloat, max_at::AbstractFloat, min_at::AbstractFloat, t::AbstractFloat)

    perform(t, hide_until, max_at, max_at + 0.00001, min_at,
        () -> angle.current_width[] = 0f0,
        () -> angle.current_width[] = line.max_width[],
        () -> angle.current_width[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            angle.current_width[] = angle.max_width[] * on_t
            angle.current_dot_width[] = angle.max_dot_width[] * on_t
        else
            on_t = (t-max_at)/(min_at-max_at)
            angle.current_width[] = angle.max_width[] - (angle.max_width[] * on_t)
            angle.current_dot_width[] = angle.max_dot_width[] - (angle.max_dot_width[] * on_t)
        end
    end
end
