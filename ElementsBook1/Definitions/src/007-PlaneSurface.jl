
export EuclidPlaneSurface2f, highlight_plane, show_complete, hide, animate

"""
    EuclidPlaneSurface2f

Describes highlighting a plane surface in a Euclid diagram
"""
mutable struct EuclidPlaneSurface2f
    start::Observable{Point2f}
    width::Observable{Float32}
    height::Observable{Float32}
    lines::Vector{EuclidLine2f}
    straight_markers::Vector{EuclidStraightLine2f}
    line_moves::Vector{EuclidLine2fMove}
end



"""
    highlight_plane(start, width, height, line_count, marker_count[, line_width=1.5f0, marker_width=0.01f0, line_color=:blue, marker_color=:red])

Set up highlighting a plane surface in a Euclid diagram

# Arguments
- `start::Observable{Point2f}`: The starting point to draw straight lines in the plane
- `width::Observable{Float32}`: The width of the plane to draw lines in
- `height::Observable{Float32}`: The height of hte plane to draw lines in
- `line_count::Integer`: The number of lines to draw through the plane
- `marker_count::Integer`: The number of markers to use in highlighting straight lines
- `line_width::Union{Float32, Observable{Float32}}`: The width of the lines to draw
- `marker_width::Union{Float32, Observable{Float32}}`: The width of the circles to draw the straight line highlights
- `line_color`: The color of the lines to draw through the plane
- `marker_color`: The color to use in highlighting the straight lines
"""
function highlight_plane(
        start::Observable{Point2f}, width::Observable{Float32}, height::Observable{Float32},
        line_count::Integer, marker_count::Integer;
        line_width::Union{Float32, Observable{Float32}}=1.5f0,
        marker_width::Union{Float32, Observable{Float32}}=0.01f0,
        line_color=:blue, marker_color=:red)

    width_end = @lift($start + [$width, 0])
    wvec = @lift($width_end - $start)
    wvec_n = @lift($wvec / line_count)
    lines = [
        line(@lift(Point2f($start + $wvec_n * (i - 1))),
             @lift(Point2f($start + [0, $height] + $wvec_n * (i - 1))),
             width=line_width, color=line_color)
        for i in 1:line_count]
    straight_markers = [
        highlight_straight(l, marker_count, width=marker_width, color=marker_color)
        for (i,l) in enumerate(lines)]
    line_moves = [
        move(l, @lift(Point2f($wvec_n * i + $start)))
        for (i,l) in enumerate(lines)]

    EuclidPlaneSurface2f(start, width, height, lines, straight_markers, line_moves)
end
function highlight_plane(
        start::Observable{Point2f}, width::Float32, height::Float32,
        line_count::Integer, marker_count::Integer;
        line_width::Union{Float32, Observable{Float32}}=1.5f0,
        marker_width::Union{Float32, Observable{Float32}}=0.01f0,
        line_color=:blue, marker_color=:red)

    highlight_plane(start, Observable(width), Observable(height),
        line_count, marker_count, line_width=line_width, marker_width=marker_width,
        line_color=line_color, marker_color=marker_color)
end
function highlight_plane(
        start::Observable{Point2f}, width::Observable{Float32}, height::Float32,
        line_count::Integer, marker_count::Integer;
        line_width::Union{Float32, Observable{Float32}}=1.5f0,
        marker_width::Union{Float32, Observable{Float32}}=0.01f0,
        line_color=:blue, marker_color=:red)

    highlight_plane(start, width, Observable(height),
        line_count, marker_count, line_width=line_width, marker_width=marker_width,
        line_color=line_color, marker_color=marker_color)
end
function highlight_plane(
        start::Observable{Point2f}, width::Float32, height::Observable{Float32},
        line_count::Integer, marker_count::Integer;
        line_width::Union{Float32, Observable{Float32}}=1.5f0,
        marker_width::Union{Float32, Observable{Float32}}=0.01f0,
        line_color=:blue, marker_color=:red)

    highlight_plane(start, Observable(width), height,
        line_count, marker_count, line_width=line_width, marker_width=marker_width,
        line_color=line_color, marker_color=marker_color)
end
function highlight_plane(
        start::Point2f, width::Float32, height::Float32,
        line_count::Integer, marker_count::Integer;
        line_width::Union{Float32, Observable{Float32}}=1.5f0,
        marker_width::Union{Float32, Observable{Float32}}=0.01f0,
        line_color=:blue, marker_color=:red)

    highlight_plane(Observable(start), Observable(width), Observable(height),
        line_count, marker_count, line_width=line_width, marker_width=marker_width,
        line_color=line_color, marker_color=marker_color)
end
function highlight_plane(
        start::Point2f, width::Observable{Float32}, height::Float32,
        line_count::Integer, marker_count::Integer;
        line_width::Union{Float32, Observable{Float32}}=1.5f0,
        marker_width::Union{Float32, Observable{Float32}}=0.01f0,
        line_color=:blue, marker_color=:red)

    highlight_plane(Observable(start), width, Observable(height),
        line_count, marker_count, line_width=line_width, marker_width=marker_width,
        line_color=line_color, marker_color=marker_color)
end
function highlight_plane(
        start::Point2f, width::Float32, height::Observable{Float32},
        line_count::Integer, marker_count::Integer;
        line_width::Union{Float32, Observable{Float32}}=1.5f0,
        marker_width::Union{Float32, Observable{Float32}}=0.01f0,
        line_color=:blue, marker_color=:red)

    highlight_plane(Observable(start), Observable(width), height,
        line_count, marker_count, line_width=line_width, marker_width=marker_width,
        line_color=line_color, marker_color=marker_color)
end
function highlight_plane(
        start::Point2f, width::Observable{Float32}, height::Observable{Float32},
        line_count::Integer, marker_count::Integer;
        line_width::Union{Float32, Observable{Float32}}=1.5f0,
        marker_width::Union{Float32, Observable{Float32}}=0.01f0,
        line_color=:blue, marker_color=:red)

    highlight_plane(Observable(start), width, height,
        line_count, marker_count, line_width=line_width, marker_width=marker_width,
        line_color=line_color, marker_color=marker_color)
end

"""
    show_complete(plane)

Complete a previously defined highlight operation for a plane surface in a Euclid diagram. It will have the markers non-moving.

# Arguments
- `plane::EuclidPlaneSurface2f`: The description of the highlight to show
"""
function show_complete(plane::EuclidPlaneSurface2f)
    for line in plane.lines
        show_complete(line)
    end
    for line in plane.straight_markers
        show_complete(line)
    end
    for line in plane.line_moves
        show_complete(line)
    end
end

"""
    hide(plane)

Hide highlights of a plane surface in a Euclid diagram

# Arguments
- `plane::EuclidPlaneSurface2f`: The description of the highlight to completely hide markers for
"""
function hide(plane::EuclidPlaneSurface2f)
    for line in plane.lines
        hide(line)
    end
    for line in plane.straight_markers
        hide(line)
    end
    for line in plane.line_moves
        hide(line)
    end
end

"""
    animate(plane, hide_until, max_at, min_at, t)

Animate highlighting a plane surface in a Euclid diagram

# Arguments
- `plane::EuclidPlaneSurface2f`: The plane surface to animate in the diagram
- `hide_until::AbstractFloat`: The time point to begin highlighting the line at
- `end_at::AbstractFloat`: The time point to finish going back to no more highlighting
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    plane::EuclidPlaneSurface2f, hide_until::AbstractFloat, end_at::AbstractFloat, t::AbstractFloat)

    for line in plane.lines
        animate(line, hide_until, hide_until+0.1f0, t, fade_start=end_at-0.1f0, fade_end=end_at)
    end
    for (i, move) in enumerate(plane.line_moves)
        animate(move, hide_until+0.1f0, end_at-0.1f0, t)
        for marker_move in plane.straight_markers[i].marker_moves
            marker_move.begin_at[] = Point2f0(plane.lines[i].extremityA[][1], marker_move.begin_at[][2])
        end
    end
    for marker in plane.straight_markers
        animate(marker, hide_until+0.1f0, end_at-0.1f0, t)
    end
end



