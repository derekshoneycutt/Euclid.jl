
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

    vec_θs = @lift(sort([fix_angle(vector_angle($center, $extremA)),
                         fix_angle(vector_angle($center, $extremB))]))

    θ_use = @lift((($vec_θs)[2] - ($vec_θs)[1] <= π) ⊻ larger ? 1 : 2)

    θ_start = @lift(($vec_θs)[$θ_use])
    θ_end = @lift($θ_use == 2 ? ($vec_θs)[1] + 2π : ($vec_θs)[2])

    norm_1 = @lift(norm($extremA - $center))
    norm_2 = @lift(norm($extremB - $center))
    draw_at = @lift(min($norm_1, $norm_2) * 0.25)

    rangle = round(π/2f0, digits=4)
    θ = @lift(round(fix_angle(angle_between($extremA - $center, $extremB - $center)), digits=4))
    angle_range = @lift($θ == rangle && !larger ?
                         [Point2f0([cos($θ_start); sin($θ_start)]*√((($draw_at)^2)/2) + $center),
                          Point2f0([cos($θ_start+π/4); sin($θ_start+π/4)]*$draw_at + $center),
                          Point2f0([cos($θ_end); sin($θ_end)]*√((($draw_at)^2)/2) + $center)] :
                         [Point2f([cos(t); sin(t)]*$draw_at + $center) for t in $θ_start:(π/180):$θ_end])

    strangle = round(1f0π, digits=4)
    dot_begin = @lift($θ == strangle ?
                        ([cos(π/2f0 + $θ_start); sin(π/2f0 + $θ_start)]*($draw_at/1.5f0) + first($angle_range)) :
                        $center)
    dot_end = @lift($θ == strangle ?
                        ([cos(π/2f0 + $θ_start); sin(π/2f0 + $θ_start)]*($draw_at/1.5f0) + last($angle_range)) :
                        (larger ?
                            ([cos(π + $θ_start); sin(π + $θ_start)]*($draw_at*1.25f0) + $center) :
                            ($θ > rangle ?
                                ([cos(π/2f0 + $θ_start); sin(π/2f0 + $θ_start)]*($draw_at*1.25f0) + $center) :
                                $center)))

    dot_width = @lift($θ > rangle || larger ? 0.6f0 : 0f0)

    observable_highlight = Observable(0f0)
    observable_dot_highlight = Observable{Float32}(0f0)
    use_color = get_color(color)

    plots = [
        lines!(@lift([$extremA, $center, $extremB]),
                color=opacify(use_color, 0.6),
                linewidth=observable_highlight),
        lines!(angle_range,
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
