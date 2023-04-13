
export EuclidLine2fRotate, rotate, reset, show_complete, hide, animate

"""
    EuclidLine2fRotate

Describes rotating a line in a Euclid diagram
"""
mutable struct EuclidLine2fRotate
    baseOn::EuclidLine2f
    rotation::Observable{Float32}
    anchor::Observable{Point2f}
    vector_startA::Observable{Point2f}
    vector_startB::Observable{Point2f}
    rotate_clockwise::Bool
end

"""
    rotate(line, rotation[, anchor=line.extremityA, clockwise=false])

Set up a rotation of a line on the Euclid diagram

# Arguments
- `line::EuclidLine2f`: The line to rotate in the diagram
- `rotation::Point2f`: The angle to rotate the line in the diagram to
- `anchor::Point2f`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function rotate(line::EuclidLine2f, rotation::Observable{Float32};
                anchor::Union{Point2f, Observable{Point2f}}=line.extremityA, clockwise::Bool=false)

    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    vectorA = @lift(line.extremityA[] - $observable_anchor)
    vectorB = @lift(line.extremityB[] - $observable_anchor)
    EuclidLine2fRotate(line, rotation, observable_anchor, vectorA, vectorB, clockwise)
end

"""
    rotate(line, rotation[, anchor=line.extremityA, clockwise=false])

Set up a rotation of a line on the Euclid diagram

# Arguments
- `line::EuclidLine2f`: The line to rotate in the diagram
- `rotation::Point2f`: The angle to rotate the line in the diagram to
- `anchor::Point2f`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function rotate(line::EuclidLine2f, rotation::Float32;
                anchor::Union{Point2f, Observable{Point2f}}=line.extremityA, clockwise::Bool=false)

    rotate(line, Observable(rotation), anchor=anchor, clockwise=clockwise)
end

"""
    reset(rotate, rotation[, anchor=rotate.baseOn.extremityA, clockwise=rotate.rotate_clockwise])

Reset a rotation animation for a line in a Euclid Diagram to new positions

# Arguments
- `rotate::EuclidLine2fRotate`: The description of the rotation to reset
- `rotation::Union{Point2f, Observable{Point2f}}`: The angle to rotate the line in the diagram to
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
end

"""
    show_complete(rotate)

Complete a previously defined rotation operation for a line in a Euclid diagram

# Arguments
- `rotate::EuclidLine2fRotate`: The description of the rotation to finish rotating
"""
function show_complete(rotate::EuclidLine2fRotate)
    clockwise_mod = rotate.rotate_clockwise ? -1 : 1
    θ = rotate.rotation[]
    vectorA = rotate.vector_startA[]
    vectorB = rotate.vector_startB[]
    norm_vA = norm(vectorA)
    norm_vB = norm(vectorB)
    uA = vectorA / norm_vA
    uB = vectorB / norm_vB
    x,y = rotate.anchor[] + [cos(θ) -sin(θ)*clockwise_mod; sin(θ)*clockwise_mod cos(θ)] * uA * norm_vA
    rotate.baseOn.extremityA[] = Point2f0(x,y)
    x,y = rotate.anchor[] + [cos(θ) -sin(θ)*clockwise_mod; sin(θ)*clockwise_mod cos(θ)] * uB * norm_vB
    rotate.baseOn.extremityB[] = Point2f0(x,y)
end

"""
    hide(rotate)

Rotate a line in a Euclid diagram back to its starting position

# Arguments
- `rotate::EuclidLine2fRotate`: The description of the rotation to "undo"
"""
function hide(rotate::EuclidLine2fRotate)
    x,y = rotate.vector_startA[] + rotate.anchor[]
    rotate.baseOn.extremityA[] = Point2f0(x,y)
    x,y = rotate.vector_startB[] + rotate.anchor[]
    rotate.baseOn.extremityB[] = Point2f0(x,y)
end

"""
    animate(rotate, begin_move, end_move, t)

Animate rotating a line drawn in a Euclid diagram

# Arguments
- `rotate::EuclidLine2fRotate`: The line to animate in the diagram
- `begin_rotate::AbstractFloat`: The time point to begin rotating the line at
- `end_rotate::AbstractFloat`: The time point to finish rotating the line at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    rotate::EuclidLine2fRotate,
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
            x,y = rotate.anchor[] + [cos(on_t) -sin(on_t)*clockwise_mod; sin(on_t)*clockwise_mod cos(on_t)] * uA * norm_vA
            rotate.baseOn.extremityA[] = Point2f0(x,y)
            x,y = rotate.anchor[] + [cos(on_t) -sin(on_t)*clockwise_mod; sin(on_t)*clockwise_mod cos(on_t)] * uB * norm_vB
            rotate.baseOn.extremityB[] = Point2f0(x,y)
        else
            x,y = vectorA + rotate.anchor[]
            rotate.baseOn.extremityA[] = Point2f0(x,y)
            x,y = vectorB + rotate.anchor[]
            rotate.baseOn.extremityB[] = Point2f0(x,y)
        end
    end
end
