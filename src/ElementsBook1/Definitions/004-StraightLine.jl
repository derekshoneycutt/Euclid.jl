
export EuclidStraightLine, EuclidStraightLine2f, EuclidStraightLine3f, straight_line, highlight

"""
    EuclidStraightLine

Describes highlighting a straight line as straight in a Euclid diagram
"""
struct EuclidStraightLine{N}
    baseOn::EuclidLine{N}
    vector::Observable{Point{N, Float32}}
    markers::Vector{EuclidPoint{N}}
end
EuclidStraightLine2f = EuclidStraightLine{2}
EuclidStraightLine3f = EuclidStraightLine{3}


"""
    straight_line(line, markers[, width=2f0, color=:red])

Set up highlighting a single straight line in a Euclid diagram

# Arguments
- `line::EuclidLine`: The line to highlight in the diagram
- `markers::Integer`: The number of markers to use in highlighting
- `color`: The color to use in highlighting the line
"""
function straight_line(line::EuclidLine2f, markers::Integer; color=:red)

    start_base = Observables.@map(&(line.data).extremityA.definition)
    end_base = Observables.@map(&(line.data).extremityB.definition)
    n_vec = Observables.@map((&end_base - &start_base) / Float32(markers))
    marker_points = [
        point(line.label * string(i),
        Observables.@map(euclidean_point(&n_vec * (i - 1) + &start_base,
                size=0f0, color=color, opacity=1f0)), showtext=false)
        for i in 1:markers]

    EuclidStraightLine2f(line, n_vec, marker_points)
end
function straight_line(line::EuclidLine3f, markers::Integer; color=:red)

    start_base = Observables.@map(&(line.data).extremityA.definition)
    end_base = Observables.@map(&(line.data).extremityB.definition)
    n_vec = Observables.@map((&end_base - &start_base) / Float32(markers))
    marker_points = [
        point(line.label * string(i),
        Observables.@map(euclidean_point(&n_vec * (i - 1) + &start_base,
                size=0f0, color=color, opacity=1f0)), showtext=false)
        for i in 1:markers]

    EuclidStraightLine3f(line, n_vec, marker_points)
end

"""
    highlight(straight, add_size, start_time, end_time)

Highlight points along a straight line

# Arguments
- `straight::EuclidStraightLine`: The straight line figure defined
- `add_size::Float32`: The amount to add to the size of the points to highlight them
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function highlight(straight::EuclidStraightLine2f, add_size::Float32,
        start_time::Float32, end_time::Float32)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))

    transformations = [
        [
            resize(p, add_size, start_time, ptime(0.1)),
            move(p, straight.vector, ptime(0.1), ptime(0.5)),
            move(p, Observables.@map(Point2f(-1 * &(straight.vector))), ptime(0.5), ptime(0.9)),
            resize(p, -add_size, ptime(0.9), end_time)
        ]
        for (i, p) in enumerate(straight.markers)
    ]

    return vcat(transformations...)
end
function highlight(straight::EuclidStraightLine3f, add_size::Float32,
        start_time::Float32, end_time::Float32)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))

    transformations = [
        [
            resize(p, add_size, start_time, ptime(0.1)),
            move(p, straight.vector, ptime(0.1), ptime(0.5)),
            move(p, Observables.@map(Point3f(-1 * &(straight.vector))), ptime(0.5), ptime(0.9)),
            resize(p, -add_size, ptime(0.9), end_time)
        ]
        for p in straight.markers
    ]

    return vcat(transformations...)
end
