
export EuclidStraightLine2f, highlight_rectilineal, show_complete, hide, animate

"""
    EuclidRectilinealAngle2f

Describes highlighting a rectilineal angle in a Euclid diagram
"""
mutable struct EuclidRectilinealAngle2f
    baseOn::EuclidAngle2f
    highlightA::EuclidStraightLine2f
    highlightB::EuclidStraightLine2f
end



"""
    highlight_rectilineal(angle, markers[, width=2f0, color=:red])

Set up highlighting a rectilineal angle in a Euclid diagram

# Arguments
- `angle::EuclidAngle2f`: The angle to highlight in the diagram
- `markers::Integer`: The number of markers to use in highlighting each straight line
- `width::Union{Float32, Observable{Float32}}`: The width of the circles to draw the highlight
- `color`: The color to use in highlighting the angle
"""
function highlight_rectilineal( angle::EuclidAngle2f, markers::Integer;
                                width::Union{Float32, Observable{Float32}}=0.01f0,
                                color=:red)

    highlightA = highlight_straight(line(angle.point, angle.extremityA), markers, width=width, color=color)
    highlightB = highlight_straight(line(angle.point, angle.extremityB), markers, width=width, color=color)

    EuclidRectilinealAngle2f(angle, highlightA, highlightB)
end


"""
    show_complete(angle)

Complete a previously defined highlight operation for a rectilineal angle in a Euclid diagram. It will have the markers non-moving.

# Arguments
- `angle::EuclidRectilinealAngle2f`: The description of the highlight to show
"""
function show_complete(angle::EuclidRectilinealAngle2f)
    show_complete(angle.highlightA)
    show_complete(angle.highlightB)
end

"""
    hide(angle)

Hide highlights of a rectilineal angle in a Euclid diagram

# Arguments
- `angle::EuclidRectilinealAngle2f`: The description of the highlight to completely hide markers for
"""
function hide(angle::EuclidRectilinealAngle2f)
    hide(angle.highlightA)
    hide(angle.highlightB)
end

"""
    animate(angle, hide_until, max_at, min_at, t)

Animate highlighting a rectilineal angle in a Euclid diagram

# Arguments
- `angle::EuclidRectilinealAngle2f`: The angle to animate in the diagram
- `hide_until::AbstractFloat`: The time point to begin highlighting the angle at
- `end_at::AbstractFloat`: The time point to finish going back to no more highlighting
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(angle::EuclidRectilinealAngle2f,
                 hide_until::AbstractFloat, end_at::AbstractFloat,
                 t::AbstractFloat)

    animate(angle.highlightA, hide_until, end_at, t)
    animate(angle.highlightB, hide_until, end_at, t)
end
