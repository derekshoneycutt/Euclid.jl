
export EuclidSurfaceRotate, EuclidSurface2fRotate, EuclidSurface3fRotate, rotate, reset, show_complete, hide, animate

"""
    EuclidSurfaceRotate

Describes rotating a surface in a Euclid diagram
"""
mutable struct EuclidSurfaceRotate{N}
    baseOn::EuclidSurface{N}
    rotation::Observable{Float32}
    anchor::Observable{Point{N, Float32}}
    vectors::Observable{Vector{Point{N, Float32}}}
    rotate_clockwise::Bool
    axis::Symbol
end
EuclidSurface2fRotate = EuclidSurfaceRotate{2}
EuclidSurface3fRotate = EuclidSurfaceRotate{3}

"""
    rotate(surface, rotation[, anchor=surface.from_points[][1], clockwise=true])

Set up a rotation of a line on the Euclid diagram

# Arguments
- `surface::EuclidSurface`: The surface to rotate in the diagram
- `rotation::Point`: The angle to rotate the surface in the diagram to
- `axis::Symbol` : In 3D lines, the axis of rotation (:x, :y, :z)
- `anchor::Point`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function rotate(surface::EuclidSurface2f, rotation::Observable{Float32};
                anchor::Union{Point2f, Observable{Point2f}}=surface.from_points[][1], clockwise::Bool=false)

    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    vectors = Observable([Point2f0(p - anchor) for p in surface.from_points[]])
    EuclidSurface2fRotate(surface, rotation, observable_anchor, vectors, clockwise, :twod)
end
function rotate(surface::EuclidSurface3f, rotation::Observable{Float32}, axis::Symbol;
                anchor::Union{Point3f, Observable{Point3f}}=surface.from_points[][1], clockwise::Bool=false)

    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    observable_anchor = anchor isa Observable{Point3f} ? anchor : Observable(anchor)
    vectors = Observable([Point3f0(p - anchor) for p in surface.from_points[]])
    EuclidSurface3fRotate(surface, rotation, observable_anchor, vectors, clockwise, axis)
end
function rotate(surface::EuclidSurface2f, rotation::Float32;
                anchor::Union{Point2f, Observable{Point2f}}=surface.from_points[][1], clockwise::Bool=false)

    rotate(surface, Observable(rotation), anchor=anchor, clockwise=clockwise)
end
function rotate(surface::EuclidSurface3f, rotation::Float32, axis::Symbol;
                anchor::Union{Point3f, Observable{Point3f}}=surface.from_points[][1], clockwise::Bool=false)

    rotate(surface, Observable(rotation), axis, anchor=anchor, clockwise=clockwise)
end

"""
    reset(rotate, rotation[, anchor=rotate.baseOn.from_points[][1], clockwise=rotate.rotate_clockwise])

Reset a rotation animation for a surface in a Euclid Diagram to new positions

# Arguments
- `rotate::EuclidSurfaceRotate`: The description of the rotation to reset
- `rotation::Union{Point, Observable{Point}}`: The angle to rotate the surface in the diagram to
- `anchor::Union{Point, Observable{Point}}`: The fixed anchor point to rotate about
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
    rotate
end
function reset(rotate::EuclidSurface3fRotate, rotation::Union{Point3f, Observable{Point3f}}, axis::Symbol;
                anchor::Union{Point3f, Observable{Point3f}}=rotate.baseOn.from_points[][1],
                clockwise::Bool=rotate.rotate_clockwise)

    observable_rotation = rotation isa Observable{Point3f} ? rotation : Observable(rotation)
    observable_anchor = anchor isa Observable{Point3f} ? anchor : Observable(anchor)
    rotate.rotation = observable_rotation
    rotate.anchor = observable_anchor
    rotate.vectors = Observable([Point3f0(p - anchor) for p in surface.from_points[]])
    rotate.rotate_clockwise = clockwise
    rotate.axis = axis
    rotate
end

"""
    show_complete(rotate)

Complete a previously defined rotation operation for a surface in a Euclid diagram

# Arguments
- `rotate::EuclidSurfaceRotate`: The description of the rotation to finish rotating
"""
function show_complete(rotate::EuclidSurfaceRotate)
    clockwise_mod = rotate.rotate_clockwise ? -1 : 1
    θ = rotate.rotation[]
    anchor = rotate.anchor[]
    vectors = rotate.vectors[]

    rotation_matrix =
        if rotate.axis == :twod
            [cos(θ) -sin(θ)*clockwise_mod; sin(θ)*clockwise_mod cos(θ)]
        elseif rotate.axis == :x
            [1 0 0; 0 cos(θ) -sin(θ)*clockwise_mod; 0 sin(θ)*clockwise_mod cos(θ)]
        elseif rotate.axis == :y
            [cos(θ) 0 sin(θ)*clockwise_mod; 0 1 0; -sin(θ)*clockwise_mod 0 cos(θ)]
        elseif rotate.axis == :z
            [cos(θ) -sin(θ)*clockwise_mod 0; sin(θ)*clockwise_mod cos(θ) 0; 0 0 1]
        end
    new_points = [anchor + rotation_matrix * v
                  for v in vectors]
    rotate.baseOn.from_points[] = new_points
end

"""
    hide(rotate)

Rotate a surface in a Euclid diagram back to its starting position

# Arguments
- `rotate::EuclidSurfaceRotate`: The description of the rotation to "undo"
"""
function hide(rotate::EuclidSurfaceRotate)
    anchor = rotate.anchor[]
    vectors = rotate.vectors[]
    new_points = [anchor + v for v in vectors]
    rotate.baseOn.from_points[] = new_points
end

"""
    animate(rotate, begin_move, end_move, t)

Animate rotating a surface drawn in a Euclid diagram

# Arguments
- `rotate::EuclidSurfaceRotate`: The surface to animate in the diagram
- `begin_rotate::AbstractFloat`: The time point to begin rotating the surface at
- `end_rotate::AbstractFloat`: The time point to finish rotating the surface at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    rotate::EuclidSurfaceRotate,
    begin_rotate::AbstractFloat, end_rotate::AbstractFloat, t::AbstractFloat)

    anchor = rotate.anchor[]
    vectors = rotate.vectors[]
    clockwise_mod = rotate.rotate_clockwise ? -1 : 1

    perform(t, begin_rotate, end_rotate,
         () -> begin
            rotate.vectors[] = [p - anchor for p in rotate.baseOn.from_points[]]
         end,
         () -> nothing) do
        on_t = ((t - begin_rotate)/(end_rotate - begin_rotate)) * rotate.rotation[]
        if on_t > 0
            rotation_matrix =
                if rotate.axis == :twod
                    [cos(on_t) -sin(on_t)*clockwise_mod; sin(on_t)*clockwise_mod cos(on_t)]
                elseif rotate.axis == :x
                    [1 0 0; 0 cos(on_t) -sin(on_t)*clockwise_mod; 0 sin(on_t)*clockwise_mod cos(on_t)]
                elseif rotate.axis == :y
                    [cos(on_t) 0 sin(on_t)*clockwise_mod; 0 1 0; -sin(on_t)*clockwise_mod 0 cos(on_t)]
                elseif rotate.axis == :z
                    [cos(on_t) -sin(on_t)*clockwise_mod 0; sin(on_t)*clockwise_mod cos(on_t) 0; 0 0 1]
                end
            new_points = [anchor + rotation_matrix * v
                          for v in vectors]
            rotate.baseOn.from_points[] = new_points
        else
            new_points = [anchor + v for v in vectors]
            rotate.baseOn.from_points[] = new_points
        end
    end
end
