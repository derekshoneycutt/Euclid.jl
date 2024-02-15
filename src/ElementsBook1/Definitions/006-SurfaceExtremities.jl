export extremities

"""
    extremities(surface, labels)

Get points representing the extremities of a given surface

# Arguments
- `surface::EuclidSurface{N}`: The surface to get the extremities of
- `labels::Vector{String}`: The labels for the extremities. Must be sized same as number of sides
"""
function extremities(surface::EuclidSurface2f, labels::Vector{String};
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    extrems = Observables.@map(extremities(&(surface.data), width=width, opacity=opacity, color=color))
    sides = length(extrems[])
    lines = [line(labels[i], Observables.@map((&extrems)[i])) for i in 1:sides]
    return lines
end
function extremities(surface::EuclidSurface3f, labels::Vector{String};
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    extrems = Observables.@map(extremities(&(surface.data), width=width, opacity=opacity, color=color))
    sides = length(extrems[])
    lines = [line(labels[i], Observables.@map((&extrems)[i])) for i in 1:sides]
    return lines
end

