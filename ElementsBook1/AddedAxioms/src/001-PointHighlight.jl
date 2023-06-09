
export EuclidPointHighlight, EuclidPoint2fHighlight, EuclidPoint3fHighlight, highlight, show_complete, hide, animate

"""
    EuclidPointHighlight

Describes highlighting a point in a Euclid diagram
"""
mutable struct EuclidPointHighlight{N}
    baseOn::EuclidPoint{N}
    plots
    current_width::Observable{Float32}
    max_width::Observable{Float32}
end

EuclidPoint2fHighlight = EuclidPointHighlight{2}
EuclidPoint3fHighlight = EuclidPointHighlight{3}

"""
highlight(point[, width=0.02f0, color=:red])

Set up highlighting a single point in a Euclid diagram

# Arguments
- `point::EuclidPoint2f`: The point to highlight in the diagram
- `width::Union{Float32, Observable{Float32}}`: The width of the circle to draw the highlight
- `color`: The color to use in highlighting the point
"""
function highlight(point::EuclidPoint2f;
                   width::Union{Float32, Observable{Float32}}=0.02f0, color=:red)

    observable_highlight = Observable(0f0)
    observable_max_width = width isa Observable{Float32} ? width : Observable(width)

    plots = poly!(@lift(Circle($(point.data), $observable_highlight)), color=opacify(color, 0.6))

    EuclidPoint2fHighlight(point, plots, observable_highlight, observable_max_width)
end

"""
highlight(point[, width=0.02f0, color=:red])

Set up highlighting a single point in a Euclid diagram

# Arguments
- `point::EuclidPoint3f`: The point to highlight in the diagram
- `width::Union{Float32, Observable{Float32}}`: The width of the circle to draw the highlight
- `color`: The color to use in highlighting the point
"""
function highlight(point::EuclidPoint3f;
                   width::Union{Float32, Observable{Float32}}=0.02f0, color=:red)

    observable_highlight = Observable(0f0)
    observable_max_width = width isa Observable{Float32} ? width : Observable(width)

    plots = mesh!(@lift(Sphere($(point.data), $observable_highlight)), color=opacify(color, 0.6))

    EuclidPoint3fHighlight(point, plots, observable_highlight, observable_max_width)
end

"""
    show_complete(point)

Complete a previously defined highlight operation for a point in a Euclid diagram. It will be fully highlighted.

# Arguments
- `point::EuclidPointHighlight`: The description of the highlight to finish
"""
function show_complete(point::EuclidPointHighlight)
    point.current_width[] = point.max_width
end

"""
    hide(point)

Hide highlights of a point in a Euclid diagram

# Arguments
- `point::EuclidPointHighlight`: The description of the highlight to completely hide
"""
function hide(point::EuclidPointHighlight)
    point.current_width[] = 0f0
end

"""
    animate(point, hide_until, max_at, min_at, t)

Animate highlighting a point in a Euclid diagram

# Arguments
- `point::EuclidPointHighlight`: The point to animate in the diagram
- `hide_until::AbstractFloat`: The time point to begin highlighting the point at
- `max_at::AbstractFloat`: The time point to have maximum highlight at
- `min_at::AbstractFloat`: The time point to finish going back to no more highlighting
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    point::EuclidPointHighlight, hide_until::AbstractFloat, max_at::AbstractFloat, min_at::AbstractFloat, t::AbstractFloat)

    perform(t, hide_until, max_at, max_at + 0.00001, min_at,
        () -> point.current_width[] = 0f0,
        () -> point.current_width[] = point.max_width[],
        () -> point.current_width[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            point.current_width[] = point.max_width[] * on_t
        else
            on_t = (t-max_at)/(min_at-max_at)
            point.current_width[] = point.max_width[]- (point.max_width[] * on_t)
        end
    end
end
