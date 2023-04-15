
export EuclidStraightLine, EuclidStraightLine2f, EuclidStraightLine3f, highlight_straight, show_complete, hide, animate

"""
    EuclidStraightLine

Describes highlighting a straight line as straight in a Euclid diagram
"""
mutable struct EuclidStraightLine{N}
    baseOn::EuclidLine{N}
    straight_markers::Vector{EuclidPoint{N}}
    marker_moves::Vector{EuclidPointMove{N}}
end
EuclidStraightLine2f = EuclidStraightLine{2}
EuclidStraightLine3f = EuclidStraightLine{3}


"""
    highlight_straight(line, markers[, width=2f0, color=:red])

Set up highlighting a single straight line in a Euclid diagram

# Arguments
- `line::EuclidLine`: The line to highlight in the diagram
- `markers::Integer`: The number of markers to use in highlighting
- `width::Union{Float32, Observable{Float32}}`: The width of the circles to draw the highlight
- `color`: The color to use in highlighting the line
"""
function highlight_straight(line::EuclidLine2f, markers::Integer;
                            width::Union{Float32, Observable{Float32}}=0.01f0,
                            color=:red)

    start_base = line.extremityA
    end_base = line.extremityB
    vector = @lift($end_base - $start_base)
    n_vec = @lift($vector / Float32(markers))
    marker_points = [
        point(@lift(Point2f($n_vec * (i - 1) + $start_base)),
              point_width=width, point_color=color,
              text_opacity=0f0, label="")
        for i in 1:markers]
    marker_moves = [
        move(p, @lift(Point2f($n_vec * i + $start_base)))
        for (i, p) in enumerate(marker_points)]

    EuclidStraightLine2f(line, marker_points, marker_moves)
end
function highlight_straight(line::EuclidLine3f, markers::Integer;
                            width::Union{Float32, Observable{Float32}}=0.01f0,
                            color=:red)

    start_base = line.extremityA
    end_base = line.extremityB
    vector = @lift($end_base - $start_base)
    n_vec = @lift($vector / Float32(markers))
    marker_points = [
        point(@lift(Point3f($n_vec * (i - 1) + $start_base)),
              point_width=width, point_color=color,
              text_opacity=0f0, label="")
        for i in 1:markers]
    marker_moves = [
        move(p, @lift(Point3f($n_vec * i + $start_base)))
        for (i, p) in enumerate(marker_points)]

    EuclidStraightLine3f(line, marker_points, marker_moves)
end

"""
    show_complete(line)

Complete a previously defined highlight operation for a straight line in a Euclid diagram. It will have the markers non-moving.

# Arguments
- `line::EuclidStraightLine`: The description of the highlight to show
"""
function show_complete(line::EuclidStraightLine)
    for marker in line.straight_markers
        show_complete(marker)
    end
    for move in line.marker_moves
        show_complete(move)
    end
end

"""
    hide(line)

Hide highlights of a straight line in a Euclid diagram

# Arguments
- `line::EuclidStraightLine`: The description of the highlight to completely hide markers for
"""
function hide(line::EuclidStraightLine)
    for move in line.marker_moves
        hide(move)
    end
    for marker in line.straight_markers
        hide(marker)
    end
end

"""
    animate(line, hide_until, max_at, min_at, t)

Animate highlighting a straight line in a Euclid diagram

# Arguments
- `line::EuclidStraightLine`: The line to animate in the diagram
- `hide_until::AbstractFloat`: The time point to begin highlighting the line at
- `end_at::AbstractFloat`: The time point to finish going back to no more highlighting
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    line::EuclidStraightLine, hide_until::AbstractFloat, end_at::AbstractFloat, t::AbstractFloat)

    for marker in line.straight_markers
        animate(marker, hide_until, hide_until+0.1f0, t, fade_start=end_at-0.1f0, fade_end=end_at)
    end
    for move in line.marker_moves
        animate(move, hide_until+0.1f0, end_at-0.1f0, t)
    end
end

