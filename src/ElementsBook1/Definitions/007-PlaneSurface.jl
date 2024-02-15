
export EuclidPlaneSurface, EuclidPlaneSurface2f, EuclidPlaneSurface3f, plane_surface, highlight

"""
    EuclidPlaneSurface

Describes highlighting a plane surface as plane in a Euclid diagram
"""
struct EuclidPlaneSurface{N}
    baseOn::EuclidSurface{N}
    vector::Observable{EuclidLineVector{N}}
    markers::Vector{EuclidLine{N}}
end
EuclidPlaneSurface2f = EuclidPlaneSurface{2}
EuclidPlaneSurface3f = EuclidPlaneSurface{3}


"""
    plane_surface(surface, markers[, width=2f0, color=:red])

Set up highlighting a single plane surface in a Euclid diagram

# Arguments
- `surface::EuclidSurface`: The surface to highlight in the diagram
- `markers::Integer`: The number of markers to use in highlighting
- `color`: The color to use in highlighting the surface
"""
function plane_surface(surface::EuclidSurface2f, markers::Integer; color=:palevioletred1)
    ngon = Observables.@map(length((&(surface.data)).points))
    topoint1 = Observables.@map(Int(floor(&ngon / 2)))
    topoint2 = Observables.@map(Int(ceil(&ngon / 2)) + 1)
    fromline = Observables.@map(
        euclidean_line((&(surface.data)).points[1], (&(surface.data)).points[&ngon]))
    toline = Observables.@map(
        euclidean_line((&(surface.data)).points[&topoint1], (&(surface.data)).points[&topoint2]))
    linevec = Observables.@map(vector(&fromline, &toline))
    n_vec = Observables.@map(
        EuclidLineVector((&linevec).vectorA / Float32(markers),
            (&linevec).vectorB / Float32(markers)))

    marker_lines = [
        line(surface.label * "_Plane" * string(i) * "_",
            Observables.@map(
                euclidean_line((&n_vec).vectorA * (i - 1) + (&(surface.data)).points[1].definition,
                    (&n_vec).vectorB * (i - 1) + (&(surface.data)).points[&ngon].definition,
                    width=0f0, color=color, opacity=1f0)))
        for i in 1:markers
    ]

    EuclidPlaneSurface2f(surface, n_vec, marker_lines)
end
function plane_surface(surface::EuclidSurface3f, markers::Integer; color=:palevioletred1)
    ngon = Observables.@map(length((&(surface.data)).points))
    topoint1 = Observables.@map(Int(floor(&ngon / 2)))
    topoint2 = Observables.@map(Int(ceil(&ngon / 2)) + 1)
    fromline = Observables.@map(
        euclidean_line((&(surface.data)).points[1], (&(surface.data)).points[&ngon]))
    toline = Observables.@map(
        euclidean_line((&(surface.data)).points[&topoint1], (&(surface.data)).points[&topoint2]))
    linevec = Observables.@map(vector(&fromline, &toline))
    n_vec = Observables.@map(
        EuclidLineVector((&linevec).vectorA / Float32(markers),
            (&linevec).vectorB / Float32(markers)))

    marker_lines = [
        line(surface.label * "_Plane" * string(i) * "_",
            Observables.@map(
                euclidean_line((&n_vec).vectorA * (i - 1) + (&(surface.data)).points[1].definition,
                    (&n_vec).vectorB * (i - 1) + (&(surface.data)).points[&ngon].definition,
                    width=0f0, color=color, opacity=1f0)))
        for i in 1:markers
    ]

    EuclidPlaneSurface3f(surface, n_vec, marker_lines)
end

"""
    highlight(plane, add_size, start_time, end_time)

Highlight straight lines along a plane surface

# Arguments
- `plane::EuclidStraightLine`: The plane surface figure defined
- `add_size::Float32`: The amount to add to the size of the lines to highlight them
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function highlight(plane::EuclidPlaneSurface2f, add_size::Float32,
        start_time::Float32, end_time::Float32)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))

    rev_vector = Observables.@map(
        EuclidLineVector(-1 * (&(plane.vector)).vectorA, -1 * (&(plane.vector)).vectorB))
    transformations = [
        [
            resize(p, add_size, start_time, ptime(0.1)),
            move(p, plane.vector, ptime(0.1), ptime(0.5)),
            move(p, rev_vector, ptime(0.5), ptime(0.9)),
            resize(p, -add_size, ptime(0.9), end_time)
        ]
        for (i, p) in enumerate(plane.markers)
    ]

    return vcat(transformations...)
end
function highlight(plane::EuclidPlaneSurface3f, add_size::Float32,
        start_time::Float32, end_time::Float32)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))

    rev_vector = Observables.@map(
        EuclidLineVector(-1 * (&(plane.vector)).vectorA, -1 * (&(plane.vector)).vectorB))
    transformations = [
        [
            resize(p, add_size, start_time, ptime(0.1)),
            move(p, plane.vector, ptime(0.1), ptime(0.5)),
            move(p, rev_vector, ptime(0.5), ptime(0.9)),
            resize(p, -add_size, ptime(0.9), end_time)
        ]
        for p in plane.markers
    ]

    return vcat(transformations...)
end
