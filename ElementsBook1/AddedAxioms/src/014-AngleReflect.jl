
export EuclidAngle2fReflect, reflect, reset, show_complete, hide, animate

"""
    EuclidAngle2fReflect

Describes reflecting a plane angle in a Euclid diagram
"""
mutable struct EuclidAngle2fReflect
    baseOn::EuclidAngle2f
    reflect_x::Observable{Float32}
    start_atA::Observable{Point2f}
    start_atB::Observable{Point2f}
    start_atC::Observable{Point2f}
end

"""
    reflect(angle, rotation[, x_axis=0f0])

Set up a reflection of a plane angle on the Euclid diagram.

This always reflects on the x-axis. Combine with rotation for other reflections.

# Arguments
- `angle::EuclidAngle2f`: The plane angle to reflect in the diagram
- `x_axis::Union{Float32,Observable{Float32}}`: The position of the x-axis to reflect on
"""
function reflect(angle::EuclidAngle2f; x_axis::Union{Float32,Observable{Float32}}=0f0)

    reflect_x = x_axis isa Observable{Float32} ? x_axis : Observable(x_axis)
    EuclidAngle2fReflect(angle, reflect_x, Observable(angle.extremityA[]), Observable(angle.extremityA[]), Observable(angle.point[]))
end

"""
    reset(reflect[, x_axis=0f0])

Reset a rotation animation for a plane angle in a Euclid Diagram to new positions

# Arguments
- `reflect::EuclidAngle2fReflect`: The description of the reflection to reset
- `x_axis::Union{Float32,Observable{Float32}}`: The position of the x-axis to reflect on
"""
function reset(reflect::EuclidAngle2fReflect; x_axis::Union{Float32,Observable{Float32}}=reflect.reflect_x)

    reflect.start_atA[] = reflect.baseOn.extremityA[]
    reflect.start_atB[] = reflect.baseOn.extremityB[]
    reflect.start_atC[] = reflect.baseOn.point[]
    if x_axis isa Observable{Float32}
        reflect.reflect_x = x_axis
    else
        reflect.reflect_x[] = x_axis
    end
end

"""
    show_complete(reflect)

Complete a previously defined reflection operation for a plane angle in a Euclid diagram

# Arguments
- `reflect::EuclidAngle2fReflect`: The description of the reflection to finish rotating
"""
function show_complete(reflect::EuclidAngle2fReflect)
    reflect.baseOn.extremityA[] = [1 0; 0 -1] * reflect.start_atA[]
    reflect.baseOn.extremityB[] = [1 0; 0 -1] * reflect.start_atB[]
    reflect.baseOn.point[] = [1 0; 0 -1] * reflect.start_atC[]
end

"""
    hide(reflect)

Move a plane angle in a Euclid diagram back to its starting position

# Arguments
- `reflect::EuclidAngle2fReflect`: The description of the rotation to "undo"
"""
function hide(reflect::EuclidAngle2fReflect)
    reflect.baseOn.extremityA[] = reflect.start_atA[]
    reflect.baseOn.extremityB[] = reflect.start_atB[]
    reflect.baseOn.point[] = reflect.start_atC[]
end

"""
    animate(reflect, begin_move, end_move, t)

Animate reflecting a plane angle drawn in a Euclid diagram

# Arguments
- `reflect::EuclidAngle2fReflect`: The plane angle to animate in the diagram
- `begin_reflect::AbstractFloat`: The time point to begin reflecting the plane angle at
- `end_reflect::AbstractFloat`: The time point to finish reflecting the plane angle at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(reflect::EuclidAngle2fReflect,
                 begin_reflect::AbstractFloat, end_reflect::AbstractFloat, t::AbstractFloat)

    end_atA = ([1 0; 0 -1] * (reflect.start_atA[] - [0, reflect.reflect_x[]])) + [0, reflect.reflect_x[]]
    end_atB = ([1 0; 0 -1] * (reflect.start_atB[] - [0, reflect.reflect_x[]])) + [0, reflect.reflect_x[]]
    end_atC = ([1 0; 0 -1] * (reflect.start_atC[] - [0, reflect.reflect_x[]])) + [0, reflect.reflect_x[]]

    vA = end_atA - reflect.start_atA[]
    norm_vA = norm(vA)
    uA = vA / norm_vA
    vB = end_atB - reflect.start_atB[]
    norm_vB = norm(vB)
    uB = vB / norm_vB
    vC = end_atC - reflect.start_atC[]
    norm_vC = norm(vC)
    uC = vC / norm_vC

    perform(t, begin_reflect, end_reflect,
         () -> begin
            reflect.start_atA[] = reflect.baseOn.extremityA[]
            reflect.start_atB[] = reflect.baseOn.extremityB[]
            reflect.start_atC[] = reflect.baseOn.point[]
         end,
         () -> nothing) do
        on_t = (t - begin_reflect)/(end_reflect - begin_reflect)
        if on_t > 0
            x,y = reflect.start_atA[] + on_t * uA * norm_vA
            reflect.baseOn.extremityA[] = Point2f0(x,y)
            x,y = reflect.start_atB[] + on_t * uB * norm_vB
            reflect.baseOn.extremityB[] = Point2f0(x,y)
            x,y = reflect.start_atC[] + on_t * uC * norm_vC
            reflect.baseOn.point[] = Point2f0(x,y)
        else
            reflect.baseOn.extremityA[] = Point2f0(end_atA)
            reflect.baseOn.extremityB[] = Point2f0(end_atB)
            reflect.baseOn.point[] = Point2f0(end_atC)
        end
    end
end
