
export EuclidSurface2fRotate, rotate, reset, show_complete, hide, animate

"""
    EuclidSurface2fRotate

Describes rotating a surface in a Euclid diagram
"""
mutable struct EuclidSurface2fRotate
    baseOn::EuclidSurface2f
    rotation::Observable{Float32}
    anchor::Observable{Point2f}
    vectors::Observable{Vector{Point2f}}
    rotate_clockwise::Bool
end

"""
    rotate(surface, rotation[, anchor=surface.from_points[][1], clockwise=true])

Set up a rotation of a line on the Euclid diagram

# Arguments
- `surface::EuclidSurface2f`: The surface to rotate in the diagram
- `rotation::Point2f`: The angle to rotate the surface in the diagram to
- `anchor::Point2f`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function rotate(surface::EuclidSurface2f, rotation::Observable{Float32};
                anchor::Union{Point2f, Observable{Point2f}}=surface.from_points[][1], clockwise::Bool=false)

    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    vectors = Observable([Point2f0(p - anchor) for p in surface.from_points[]])
    EuclidSurface2fRotate(surface, rotation, observable_anchor, vectors, clockwise)
end

"""
    rotate(surface, rotation[, anchor=surface.from_points[][1], clockwise=true])

Set up a rotation of a surface on the Euclid diagram

# Arguments
- `surface::EuclidSurface2f`: The surface to rotate in the diagram
- `rotation::Point2f`: The angle to rotate the surface in the diagram to
- `anchor::Point2f`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function rotate(surface::EuclidSurface2f, rotation::Float32;
                anchor::Union{Point2f, Observable{Point2f}}=surface.from_points[][1], clockwise::Bool=false)

    rotate(surface, Observable(rotation), anchor=anchor, clockwise=clockwise)
end

"""
    reset(rotate, rotation[, anchor=rotate.baseOn.from_points[][1], clockwise=rotate.rotate_clockwise])

Reset a rotation animation for a surface in a Euclid Diagram to new positions

# Arguments
- `rotate::EuclidSurface2fRotate`: The description of the rotation to reset
- `rotation::Union{Point2f, Observable{Point2f}}`: The angle to rotate the surface in the diagram to
- `anchor::Union{Point2f, Observable{Point2f}}`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function reset(rotate::EuclidSurface2fRotate, rotation::Union{Point2f, Observable{Point2f}};
                anchor::Union{Point2f, Observable{Point2f}}=rotate.baseOn.from_points[][1],
                clockwise::Bool=rotate.rotate_clockwise)

    observable_rotation = rotation isa Observable{Point2f} ? rotation : Observable(rotation)
    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    rotate.rotation = observable_rotation
    rotate.anchor = observable_anchor
    rotate.vectors = Observable([Point2f0(p - anchor) for p in surface.from_points[]])
    rotate.rotate_clockwise = clockwise
end

"""
    show_complete(rotate)

Complete a previously defined rotation operation for a surface in a Euclid diagram

# Arguments
- `rotate::EuclidSurface2fRotate`: The description of the rotation to finish rotating
"""
function show_complete(rotate::EuclidSurface2fRotate)
    clockwise_mod = rotate.rotate_clockwise ? -1 : 1
    θ = rotate.rotation[]
    anchor = rotate.anchor[]
    vectors = rotate.vectors[]
    new_points = [Point2f0(anchor +  [cos(θ) -sin(θ)*clockwise_mod; sin(θ)*clockwise_mod cos(θ)] * v)
                  for v in vectors]
    rotate.baseOn.from_points[] = new_points
end

"""
    hide(rotate)

Rotate a surface in a Euclid diagram back to its starting position

# Arguments
- `rotate::EuclidSurface2fRotate`: The description of the rotation to "undo"
"""
function hide(rotate::EuclidSurface2fRotate)
    anchor = rotate.anchor[]
    vectors = rotate.vectors[]
    new_points = [Point2f0(anchor + v) for v in vectors]
    rotate.baseOn.from_points[] = new_points
end

"""
    animate(rotate, begin_move, end_move, t)

Animate rotating a surface drawn in a Euclid diagram

# Arguments
- `rotate::EuclidSurface2fRotate`: The surface to animate in the diagram
- `begin_rotate::AbstractFloat`: The time point to begin rotating the surface at
- `end_rotate::AbstractFloat`: The time point to finish rotating the surface at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    rotate::EuclidSurface2fRotate,
    begin_rotate::AbstractFloat, end_rotate::AbstractFloat, t::AbstractFloat)

    anchor = rotate.anchor[]
    vectors = rotate.vectors[]
    clockwise_mod = rotate.rotate_clockwise ? -1 : 1

    perform(t, begin_rotate, end_rotate,
         () -> begin
            rotate.vectors[] = [Point2f0(p - anchor) for p in rotate.baseOn.from_points[]]
         end,
         () -> nothing) do
        on_t = ((t - begin_rotate)/(end_rotate - begin_rotate)) * rotate.rotation[]
        if on_t > 0
            new_points = [Point2f0(anchor + [cos(on_t) -sin(on_t)*clockwise_mod; sin(on_t)*clockwise_mod cos(on_t)] * v)
                          for v in vectors]
            rotate.baseOn.from_points[] = new_points
        else
            new_points = [Point2f0(anchor + v) for v in vectors]
            rotate.baseOn.from_points[] = new_points
        end
    end
end
