
export EuclidAngle2fRotate, rotate, reset, show_complete, hide, animate

"""
    EuclidAngle2fRotate

Describes rotating a plane angle in a Euclid diagram
"""
mutable struct EuclidAngle2fRotate
    baseOn::EuclidAngle2f
    rotation::Observable{Float32}
    anchor::Observable{Point2f}
    vector_startA::Observable{Point2f}
    vector_startB::Observable{Point2f}
    vector_startC::Observable{Point2f}
    rotate_clockwise::Bool
end

"""
    rotate(angle, rotation[, anchor=angle.point, clockwise=false])

Set up a rotation of a plane angle on the Euclid diagram

# Arguments
- `angle::EuclidAngle2f`: The plane angle to rotate in the diagram
- `rotation::Point2f`: The angle to rotate the plane angle in the diagram to
- `anchor::Point2f`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function rotate(angle::EuclidAngle2f, rotation::Observable{Float32};
                anchor::Union{Point2f, Observable{Point2f}}=angle.point, clockwise::Bool=false)

    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    vectorA = @lift(angle.extremityA[] - $observable_anchor)
    vectorB = @lift(angle.extremityB[] - $observable_anchor)
    vectorC = @lift(angle.point[] - $observable_anchor)
    EuclidAngle2fRotate(angle, rotation, observable_anchor, vectorA, vectorB, vectorC, clockwise)
end

"""
    rotate(angle, rotation[, anchor=angle.point, clockwise=false])

Set up a rotation of a plane angle on the Euclid diagram

# Arguments
- `angle::EuclidAngle2f`: The plane angle to rotate in the diagram
- `rotation::Point2f`: The angle to rotate the plane angle in the diagram to
- `anchor::Point2f`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function rotate(angle::EuclidAngle2f, rotation::Float32;
                anchor::Union{Point2f, Observable{Point2f}}=angle.point, clockwise::Bool=false)

    rotate(angle, Observable(rotation), anchor=anchor, clockwise=clockwise)
end

"""
    reset(rotate, rotation[, anchor=rotate.baseOn.point, clockwise=rotate.rotate_clockwise])

Reset a rotation animation for a plane angle in a Euclid Diagram to new positions

# Arguments
- `rotate::EuclidAngle2fRotate`: The description of the rotation to reset
- `rotation::Union{Point2f, Observable{Point2f}}`: The angle to rotate the plane angle in the diagram to
- `anchor::Union{Point2f, Observable{Point2f}}`: The fixed anchor point to rotate about
- `clockwise::Bool`: Whether to perform clockwise rotation. Otherwise does counter-clockwise.
"""
function reset(rotate::EuclidAngle2fRotate, rotation::Union{Point2f, Observable{Point2f}};
                anchor::Union{Point2f, Observable{Point2f}}=rotate.baseOn.point,
                clockwise::Bool=rotate.rotate_clockwise)

    observable_rotation = rotation isa Observable{Point2f} ? rotation : Observable(rotation)
    observable_anchor = anchor isa Observable{Point2f} ? anchor : Observable(anchor)
    vectorA = @lift(rotate.baseOn.extremityA[] - $observable_anchor)
    vectorB = @lift(rotate.baseOn.extremityB[] - $observable_anchor)
    vectorC = @lift(rotate.baseOn.point[] - $observable_anchor)
    rotate.rotation = observable_rotation
    rotate.anchor = observable_anchor
    rotate.vector_startA = vectorA
    rotate.vector_startB = vectorB
    rotate.vector_startC = vectorC
    rotate.rotate_clockwise = clockwise
end

"""
    show_complete(rotate)

Complete a previously defined rotation operation for a plane angle in a Euclid diagram

# Arguments
- `rotate::EuclidAngle2fRotate`: The description of the rotation to finish rotating
"""
function show_complete(rotate::EuclidAngle2fRotate)
    clockwise_mod = rotate.rotate_clockwise ? -1 : 1
    θ = rotate.rotation[]
    vectorA = rotate.vector_startA[]
    vectorB = rotate.vector_startB[]
    vectorC = rotate.vector_startC[]
    x,y = rotate.anchor[] + [cos(θ) -sin(θ)*clockwise_mod; sin(θ)*clockwise_mod cos(θ)] * vectorA
    rotate.baseOn.extremityA[] = Point2f0(x,y)
    x,y = rotate.anchor[] + [cos(θ) -sin(θ)*clockwise_mod; sin(θ)*clockwise_mod cos(θ)] * vectorB
    rotate.baseOn.extremityB[] = Point2f0(x,y)
    x,y = rotate.anchor[] + [cos(θ) -sin(θ)*clockwise_mod; sin(θ)*clockwise_mod cos(θ)] * vectorC
    rotate.baseOn.point[] = Point2f0(x,y)
end

"""
    hide(rotate)

Rotate a plane angle in a Euclid diagram back to its starting position

# Arguments
- `rotate::EuclidAngle2fRotate`: The description of the rotation to "undo"
"""
function hide(rotate::EuclidAngle2fRotate)
    x,y = rotate.vector_startA[] + rotate.anchor[]
    rotate.baseOn.extremityA[] = Point2f0(x,y)
    x,y = rotate.vector_startB[] + rotate.anchor[]
    rotate.baseOn.extremityB[] = Point2f0(x,y)
    x,y = rotate.vector_startC[] + rotate.anchor[]
    rotate.baseOn.point[] = Point2f0(x,y)
end

"""
    animate(rotate, begin_move, end_move, t)

Animate rotating a plane angle drawn in a Euclid diagram

# Arguments
- `rotate::EuclidAngle2fRotate`: The plane angle to animate in the diagram
- `begin_rotate::AbstractFloat`: The time point to begin rotating the plane angle at
- `end_rotate::AbstractFloat`: The time point to finish rotating the plane angle at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    rotate::EuclidAngle2fRotate,
    begin_rotate::AbstractFloat, end_rotate::AbstractFloat, t::AbstractFloat)

    vectorA = rotate.vector_startA[]
    vectorB = rotate.vector_startB[]
    vectorC = rotate.vector_startC[]
    clockwise_mod = rotate.rotate_clockwise ? -1 : 1

    perform(t, begin_rotate, end_rotate,
         () -> begin
            rotate.vector_startA[] = rotate.baseOn.extremityA[] - rotate.anchor[]
            rotate.vector_startB[] = rotate.baseOn.extremityB[] - rotate.anchor[]
            rotate.vector_startC[] = rotate.baseOn.point[] - rotate.anchor[]
         end,
         () -> nothing) do
        on_t = ((t - begin_rotate)/(end_rotate - begin_rotate)) * rotate.rotation[]
        if on_t > 0
            rotate.baseOn.extremityA[] = Point2f0([cos(on_t) -sin(on_t)*clockwise_mod; sin(on_t)*clockwise_mod cos(on_t)] * vectorA + rotate.anchor[])
            rotate.baseOn.extremityB[] = Point2f0([cos(on_t) -sin(on_t)*clockwise_mod; sin(on_t)*clockwise_mod cos(on_t)] * vectorB + rotate.anchor[])
            rotate.baseOn.point[] = Point2f0([cos(on_t) -sin(on_t)*clockwise_mod; sin(on_t)*clockwise_mod cos(on_t)] * vectorC + rotate.anchor[])
        else
            rotate.baseOn.extremityA[] = Point2f0(vectorA + rotate.anchor[])
            rotate.baseOn.extremityB[] = Point2f0(vectorB + rotate.anchor[])
            rotate.baseOn.point[] = Point2f0(vectorC + rotate.anchor[])
        end
    end
end
