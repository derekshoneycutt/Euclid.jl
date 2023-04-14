
export EuclidLineRotate, EuclidLine2fRotate, EuclidLine3fRotate, rotate, reset, show_complete, hide, animate

"""
    EuclidLineRotate

Describes rotating a line in a Euclid diagram
"""
mutable struct EuclidLineRotate{N}
    baseOn::EuclidLine{N}
    rotation::Observable{Float32}
    anchor::Observable{Point{N, Float32}}
    vector_startA::Observable{Point{N, Float32}}
    vector_startB::Observable{Point{N, Float32}}
    rotate_clockwise::Bool
    axis::Symbol
end
EuclidLine2fRotate = EuclidLineRotate{2}
EuclidLine3fRotate = EuclidLineRotate{3}

"""
    rotate(line, rotation[, anchor=line.extremityA, clockwise=false])

Set up a rotation of a line on the Euclid diagram

# Arguments
- `line::EuclidLine`: The line to rotate in the diagram
- `rotation::Float32`: The angle to rotate the line in the diagram to
- `axis::Symbol` : In 3D lines, the axis of rotation (:x, :y, :z)
- `anchor::Point`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function rotate(line::EuclidLine2f, rotation::Observable{Float32};
                anchor::Union{Point2f, Observable{Point2f}}=line.extremityA, clockwise::Bool=false)

    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    vectorA = @lift(line.extremityA[] - $observable_anchor)
    vectorB = @lift(line.extremityB[] - $observable_anchor)
    EuclidLine2fRotate(line, rotation, observable_anchor, vectorA, vectorB, clockwise, :twod)
end
function rotate(line::EuclidLine2f, rotation::Float32;
                anchor::Union{Point2f, Observable{Point2f}}=line.extremityA, clockwise::Bool=false)

    rotate(line, Observable(rotation), anchor=anchor, clockwise=clockwise)
end
function rotate(line::EuclidLine3f, rotation::Observable{Float32}, axis::Symbol;
                anchor::Union{Point3f, Observable{Point3f}}=line.extremityA, clockwise::Bool=false)

    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    vectorA = @lift(line.extremityA[] - $observable_anchor)
    vectorB = @lift(line.extremityB[] - $observable_anchor)
    EuclidLine3fRotate(line, rotation, observable_anchor, vectorA, vectorB, clockwise, axis)
end
function rotate(line::EuclidLine3f, rotation::Float32, axis::Symbol;
                anchor::Union{Point3f, Observable{Point3f}}=line.extremityA, clockwise::Bool=false)

    rotate(line, Observable(rotation), axis, anchor=anchor, clockwise=clockwise)
end

"""
    reset(rotate, rotation[, anchor=rotate.baseOn.extremityA, clockwise=rotate.rotate_clockwise])

Reset a rotation animation for a line in a Euclid Diagram to new positions

# Arguments
- `rotate::EuclidLine2fRotate`: The description of the rotation to reset
- `rotation::Union{Point2f, Observable{Point2f}}`: The angle to rotate the line in the diagram to
- `axis::Symbol` : In 3D lines, the axis of rotation (:x, :y, :z)
- `anchor::Union{Point2f, Observable{Point2f}}`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function reset(rotate::EuclidLine2fRotate, rotation::Union{Point2f, Observable{Point2f}};
                anchor::Union{Point2f, Observable{Point2f}}=rotate.baseOn.extremityA,
                clockwise::Bool=rotate.rotate_clockwise)

    observable_rotation = rotation isa Observable{Point2f} ? rotation : Observable(rotation)
    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    vectorA = @lift(rotate.baseOn.extremityA[] - $observable_anchor)
    vectorB = @lift(rotate.baseOn.extremityB[] - $observable_anchor)
    rotate.rotation = observable_rotation
    rotate.anchor = observable_anchor
    rotate.vector_startA = vectorA
    rotate.vector_startB = vectorB
    rotate.rotate_clockwise = clockwise
    rotate
end
function reset(rotate::EuclidLine3fRotate, rotation::Union{Point3f, Observable{Point3f}}, axis::Symbol;
                anchor::Union{Point3f, Observable{Point3f}}=rotate.baseOn.extremityA,
                clockwise::Bool=rotate.rotate_clockwise)

    observable_rotation = rotation isa Observable{Point2f} ? rotation : Observable(rotation)
    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    vectorA = @lift(rotate.baseOn.extremityA[] - $observable_anchor)
    vectorB = @lift(rotate.baseOn.extremityB[] - $observable_anchor)
    rotate.rotation = observable_rotation
    rotate.anchor = observable_anchor
    rotate.vector_startA = vectorA
    rotate.vector_startB = vectorB
    rotate.rotate_clockwise = clockwise
    rotate.axis = axis
    rotate
end

"""
    show_complete(rotate)

Complete a previously defined rotation operation for a line in a Euclid diagram

# Arguments
- `rotate::EuclidLineRotate`: The description of the rotation to finish rotating
"""
function show_complete(rotate::EuclidLineRotate)
    clockwise_mod = rotate.rotate_clockwise ? -1 : 1
    θ = rotate.rotation[]
    vectorA = rotate.vector_startA[]
    vectorB = rotate.vector_startB[]
    norm_vA = norm(vectorA)
    norm_vB = norm(vectorB)
    uA = vectorA / norm_vA
    uB = vectorB / norm_vB

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
    rotate.baseOn.extremityA[] = (rotate.anchor[] + rotation_matrix * uA * norm_vA)
    rotate.baseOn.extremityB[] = (rotate.anchor[] + rotation_matrix * uB * norm_vB)
end

"""
    hide(rotate)

Rotate a line in a Euclid diagram back to its starting position

# Arguments
- `rotate::EuclidLineRotate`: The description of the rotation to "undo"
"""
function hide(rotate::EuclidLineRotate)
    rotate.baseOn.extremityA[] = rotate.vector_startA[] + rotate.anchor[]
    rotate.baseOn.extremityB[] = rotate.vector_startB[] + rotate.anchor[]
end

"""
    animate(rotate, begin_move, end_move, t)

Animate rotating a line drawn in a Euclid diagram

# Arguments
- `rotate::EuclidLineRotate`: The line to animate in the diagram
- `begin_rotate::AbstractFloat`: The time point to begin rotating the line at
- `end_rotate::AbstractFloat`: The time point to finish rotating the line at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    rotate::EuclidLineRotate,
    begin_rotate::AbstractFloat, end_rotate::AbstractFloat, t::AbstractFloat)

    vectorA = rotate.vector_startA[]
    vectorB = rotate.vector_startB[]
    norm_vA = norm(vectorA)
    norm_vB = norm(vectorB)
    uA = vectorA / norm_vA
    uB = vectorB / norm_vB
    clockwise_mod = rotate.rotate_clockwise ? -1 : 1

    perform(t, begin_rotate, end_rotate,
         () -> begin
            rotate.vector_startA[] = rotate.baseOn.extremityA[] - rotate.anchor[]
            rotate.vector_startB[] = rotate.baseOn.extremityB[] - rotate.anchor[]
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
            rotate.baseOn.extremityA[] = (rotate.anchor[] + rotation_matrix * uA * norm_vA)
            rotate.baseOn.extremityB[] = (rotate.anchor[] + rotation_matrix * uB * norm_vB)
        else
            rotate.baseOn.extremityA[] = vectorA + rotate.anchor[]
            rotate.baseOn.extremityB[] = vectorB + rotate.anchor[]
        end
    end
end
