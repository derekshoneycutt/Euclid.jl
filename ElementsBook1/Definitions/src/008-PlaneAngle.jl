
export EuclidAngle, EuclidAngle2f, EuclidAngle3f, plane_angle, show_complete, hide, animate

"""
    EuclidAngle

Describes an angle to be drawn and animated in Euclid diagrams
"""
mutable struct EuclidAngle{N}
    point::Observable{Point{N, Float32}}
    extremityA::Observable{Point{N, Float32}}
    extremityB::Observable{Point{N, Float32}}
    plots
    current_anglerad::Observable{Float32}
    current_width::Observable{Float32}
    show_width::Observable{Float32}
    angle_points
end
EuclidAngle2f = EuclidAngle{2}
EuclidAngle3f = EuclidAngle{3}

"""
    plane_angle(point, lengthA, lengthB, theta[, draw_angle=0f0, width=1.5f0, color=:blue])

Sets up a new angle in a Euclid Diagram for drawing. Basing on theta will not give an angle that watches observables

# Arguments
- `point::Point2f`: The location of the central point of the angle, where the lines meet
- `lengthA::Float32`: The length of side A, the base of the angle
- `lengthB::Float32`: The length of side B, the rotated side of the angle
- `theta::Float32`: The angle in radians to draw
- `draw_angle::Observable{Float32}`: The displacement angle to draw the angle at (both lines will be rotated)
- `width::Union{Float32, Observable{Float32}}`: The width of the line to draw
- `color`: The color to draw the line with
"""
function plane_angle(point::Point2f,
                     lengthA::Float32, lengthB::Float32,
                     theta::Float32;
                     draw_angle::Float32=0f0,
                     width::Union{Float32, Observable{Float32}}=1.5f0, color=:blue)

    θangle = draw_angle + theta

    extremityA = Point2f0([cos(draw_angle) -sin(draw_angle); sin(draw_angle) cos(draw_angle)] * [lengthA, 0] + point)
    extremityB = Point2f0([cos(θangle) -sin(θangle); sin(θangle) cos(θangle)] * [lengthB, 0] + point)
    plane_angle(point, extremityA, extremityB, width=width, color=color, larger=(theta > π))
end

"""
    plane_angle(point, pointA, point B[, width=1.5f0, color=:blue])

Sets up a new angle in a Euclid Diagram for drawing. May make it an observable angle.

# Arguments
- `center::Observable{Point2f}: The location of the central point of the angle, where the lines meet
- `pointA::Observable{Point2f}`: The location of point A, a vector out from the center
- `pointB::Observable{Point2f}`: The location of point B, a vector out from the center
- `width::Union{Float32, Observable{Float32}}`: The width of the line to draw
- `color`: The color to draw the line with
"""
function plane_angle(center::Observable{Point2f}, pointA::Observable{Point2f}, pointB::Observable{Point2f};
                     width::Union{Float32, Observable{Float32}}=1.5f0, color=:blue, larger::Bool=false)

    observable_width = Observable(0f0)
    observable_show_width = width isa Observable{Float32} ? width : Observable(width)
    observable_anglerad = Observable(0f0)

    angle_data = get_angle_measure_observables(center, pointA, pointB, larger, observable_anglerad)

    pl = [lines!(@lift([Point2f0($pointA), Point2f0($center), Point2f0($pointB)]),
                 color=color, linewidth=(observable_width)),
          poly!(@lift([Point2f0(p) for p in vcat($(angle_data.angle_range), [$center])]),
                color=color, strokewidth=0f0)]

    EuclidAngle2f(center, pointA, pointB, pl, observable_anglerad, observable_width, observable_show_width, nothing)
end
function plane_angle(center::Observable{Point3f}, pointA::Observable{Point3f}, pointB::Observable{Point3f};
                     width::Union{Float32, Observable{Float32}}=0.02f0, color=:blue, larger::Bool=false)

    observable_width = Observable(0f0)
    observable_show_width = width isa Observable{Float32} ? width : Observable(width)
    observable_anglerad = Observable(0f0)

    pl = [mesh!(@lift(Cylinder(Point3f0($pointA), Point3f0($center), $observable_width)),
                   color=color),
          mesh!(@lift(Cylinder(Point3f0($pointB), Point3f0($center), $observable_width)),
                   color=color)]

    EuclidAngle3f(center, pointA, pointB, pl, observable_anglerad, observable_width, observable_show_width, nothing)
end
function plane_angle(center::Observable{Point2f}, pointA::Point2f, pointB::Point2f;
                width::Union{Float32, Observable{Float32}}=1.5f0, color=:blue, larger::Bool=false)
    plane_angle(center, Observable(pointA), Observable(pointB), width=width, color=color, larger=larger)
end
function plane_angle(center::Observable{Point2f}, pointA::Observable{Point2f}, pointB::Point2f;
                width::Union{Float32, Observable{Float32}}=1.5f0, color=:blue, larger::Bool=false)
    plane_angle(center, pointA, Observable(pointB), width=width, color=color, larger=larger)
end
function plane_angle(center::Observable{Point2f}, pointA::Point2f, pointB::Observable{Point2f};
                width::Union{Float32, Observable{Float32}}=1.5f0, color=:blue, larger::Bool=false)
    plane_angle(center, Observable(pointA), pointB, width=width, color=color, larger=larger)
end
function plane_angle(center::Point2f, pointA::Observable{Point2f}, pointB::Point2f;
                width::Union{Float32, Observable{Float32}}=1.5f0, color=:blue, larger::Bool=false)
    plane_angle(Observable(center), pointA, Observable(pointB), width=width, color=color, larger=larger)
end
function plane_angle(center::Point2f, pointA::Observable{Point2f}, pointB::Observable{Point2f};
                width::Union{Float32, Observable{Float32}}=1.5f0, color=:blue, larger::Bool=false)
    plane_angle(Observable(center), pointA, pointB, width=width, color=color, larger=larger)
end
function plane_angle(center::Point2f, pointA::Point2f, pointB::Observable{Point2f};
                width::Union{Float32, Observable{Float32}}=1.5f0, color=:blue, larger::Bool=false)
    plane_angle(Observable(center), Observable(pointA), pointB, width=width, color=color, larger=larger)
end
function plane_angle(center::Point2f, pointA::Point2f, pointB::Point2f;
                width::Union{Float32, Observable{Float32}}=1.5f0, color=:blue, larger::Bool=false)
    plane_angle(Observable(center), Observable(pointA), Observable(pointB), width=width, color=color, larger=larger)
end
function plane_angle(center::Observable{Point3f}, pointA::Point3f, pointB::Point3f;
                width::Union{Float32, Observable{Float32}}=0.02f0, color=:blue, larger::Bool=false)
    plane_angle(center, Observable(pointA), Observable(pointB), width=width, color=color, larger=larger)
end
function plane_angle(center::Observable{Point3f}, pointA::Observable{Point3f}, pointB::Point3f;
                width::Union{Float32, Observable{Float32}}=0.02f0, color=:blue, larger::Bool=false)
    plane_angle(center, pointA, Observable(pointB), width=width, color=color, larger=larger)
end
function plane_angle(center::Observable{Point3f}, pointA::Point3f, pointB::Observable{Point3f};
                width::Union{Float32, Observable{Float32}}=0.02f0, color=:blue, larger::Bool=false)
    plane_angle(center, Observable(pointA), pointB, width=width, color=color, larger=larger)
end
function plane_angle(center::Point3f, pointA::Observable{Point3f}, pointB::Point3f;
                width::Union{Float32, Observable{Float32}}=0.02f0, color=:blue, larger::Bool=false)
    plane_angle(Observable(center), pointA, Observable(pointB), width=width, color=color, larger=larger)
end
function plane_angle(center::Point3f, pointA::Observable{Point3f}, pointB::Observable{Point3f};
                width::Union{Float32, Observable{Float32}}=0.02f0, color=:blue, larger::Bool=false)
    plane_angle(Observable(center), pointA, pointB, width=width, color=color, larger=larger)
end
function plane_angle(center::Point3f, pointA::Point3f, pointB::Observable{Point3f};
                width::Union{Float32, Observable{Float32}}=0.02f0, color=:blue, larger::Bool=false)
    plane_angle(Observable(center), Observable(pointA), pointB, width=width, color=color, larger=larger)
end
function plane_angle(center::Point3f, pointA::Point3f, pointB::Point3f;
                width::Union{Float32, Observable{Float32}}=0.02f0, color=:blue, larger::Bool=false)
    plane_angle(Observable(center), Observable(pointA), Observable(pointB), width=width, color=color, larger=larger)
end

"""
    show_complete(angle)

Completely show previously defined angle in a Euclid diagram

# Arguments
- `angle::EuclidAngle`: The angle to completely show
"""
function show_complete(angle::EuclidAngle)
    angle.current_width[] = angle.show_width[]
    angle.current_anglerad[] = 0.25f0
end

"""
    hide(angle)

Completely hide previously defined angle in a Euclid diagram

# Arguments
- `angle::EuclidAngle`: The angle to completely hide
"""
function hide(angle::EuclidAngle)
    angle.current_width[] = 0f0
    angle.current_anglerad[] = 0f0
end

"""
    animate(angle, hide_until, max_at, t[, fade_start=0f0, fade_end=0f0])

Animate drawing and perhaps then hiding angle drawn in a Euclid diagram

# Arguments
- `angle::EuclidAngle`: The angle to animate in the diagram
- `hide_until::AbstractFloat`: The point to hide the angle until
- `max_at::AbstractFloat`: The time to max drawing the angle at -- when it is fully drawn
- `t::AbstractFloat`: The current timeframe of the animation
- `fade_start::AbstractFloat`: When to begin fading the angle away from the diagram
- `fade_end::AbstractFloat`: When to end fading the angle awawy from the diagram -- it will be hidden entirely
"""
function animate(
    angle::EuclidAngle, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
    fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)

    perform(t, hide_until, max_at, fade_start, fade_end,
        () -> angle.current_width[] = 0f0,
        () -> angle.current_width[] = angle.show_width[],
        () -> angle.current_width[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            angle.current_width[] = angle.show_width[] * on_t
            angle.current_anglerad[] = on_t*0.25
        else
            on_t = (t-fade_start)/(fade_end-fade_start)
            angle.current_width[] = angle.show_width[]- (angle.show_width[] * on_t)
            angle.current_anglerad[] = 0.25-(on_t*0.25)
        end
    end
end

