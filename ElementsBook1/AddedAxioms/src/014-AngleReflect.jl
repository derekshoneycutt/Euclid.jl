
export EuclidAngleReflect, EuclidAngle2fReflect, reflect, reset, show_complete, hide, animate

"""
    EuclidAngle2fReflect

Describes reflecting a plane angle in a Euclid diagram
"""
mutable struct EuclidAngleReflect{N}
    baseOn::EuclidAngle{N}
    axis_offset_x::Observable{Float32}
    axis_offset_y::Observable{Float32}
    axis_offset_z::Observable{Float32}
    start_atA::Observable{Point{N, Float32}}
    start_atB::Observable{Point{N, Float32}}
    start_atC::Observable{Point{N, Float32}}
    axis::Symbol
end
EuclidAngle2fReflect = EuclidAngleReflect{2}

"""
    reflect(angle, rotation[, x_axis=0f0])

Set up a reflection of a plane angle on the Euclid diagram.

This always reflects on the x-axis. Combine with rotation for other reflections.

# Arguments
- `angle::EuclidAngle2f`: The plane angle to reflect in the diagram
- `axis::Symbol` : The axis to reflect across;
    2D can be :x, :y, :diag, :negdiag, or :origin;
- `axis_offset_x::Union{Float32,Observable{Float32}}`: The position of the x axis to reflect across
- `axis_offset_y::Union{Float32,Observable{Float32}}`: The position of the y axis to reflect across
- `axis_offset_z::Union{Float32,Observable{Float32}}`: The position of the z axis to reflect across
"""
function reflect(angle::EuclidAngle2f;
                 axis::Symbol=:x,
                 axis_offset_x::Union{Float32,Observable{Float32}}=0f0,
                 axis_offset_y::Union{Float32,Observable{Float32}}=0f0)


    if axis != :x && axis != :y && axis != :diag && axis != :negdiag && axis != :origin
        throw("Unsupported axis for 2D reflection. Supported symbols: :x, :y, :diag, or :negdiag")
    end
    reflect_offset_x = axis_offset_x isa Observable{Float32} ? axis_offset_x : Observable(axis_offset_x)
    reflect_offset_y = axis_offset_y isa Observable{Float32} ? axis_offset_y : Observable(axis_offset_y)
    EuclidAngle2fReflect(angle, reflect_offset_x, reflect_offset_y, angle.extremityA, angle.extremityB, angle.point, axis)
end

"""
    reset(reflect[, x_axis=0f0])

Reset a rotation animation for a plane angle in a Euclid Diagram to new positions

# Arguments
- `reflect::EuclidAngle2fReflect`: The description of the reflection to reset
- `axis::Symbol` : The axis to reflect across;
    2D can be :x, :y, :diag, :negdiag, or :origin;
- `axis_offset_x::Union{Float32,Observable{Float32}}`: The position of the x-axis to reflect on
- `axis_offset_y::Union{Float32,Observable{Float32}}`: The position of the y-axis to reflect on
- `axis_offset_z::Union{Float32,Observable{Float32}}`: The position of the z-axis to reflect on
"""
function reset(reflect::EuclidAngle2fReflect;
               axis::Symbol=reflect.axis,
               axis_offset_x::Union{Float32,Observable{Float32}}=reflect.axis_offset_x,
               axis_offset_y::Union{Float32,Observable{Float32}}=reflect.axis_offset_y)

    if axis != :x && axis != :y && axis != :diag && axis != :negdiag && axis != :origin
        throw("Unsupported axis for 2D reflection. Supported symbols: :x, :y, :diag, or :negdiag")
    end
    if axis_offset_x isa Observable{Float32}
        reflect.axis_offset_x = axis_offset_x
    else
        reflect.axis_offset_x[] = axis_offset_x
    end
    if axis_offset_y isa Observable{Float32}
        reflect.axis_offset_y = axis_offset_y
    else
        reflect.axis_offset_y[] = axis_offset_y
    end
    reflect.axis = axis
end

"""
    show_complete(reflect)

Complete a previously defined reflection operation for a plane angle in a Euclid diagram

# Arguments
- `reflect::EuclidAngle2fReflect`: The description of the reflection to finish rotating
"""
function show_complete(reflect::EuclidAngle2fReflect)
    reflect_matrix =
        if reflect.axis == :x
            [1 0; 0 -1]
        elseif reflect.axis == :y
            [-1 0; 0 1]
        elseif reflect.axis == :diag
            [0 1; 1 0]
        elseif reflect.axis == :negdiag
            [0 -1; -1 0]
        elseif reflect.axis == :origin
            [-1 0; 0 -1]
        end
    offset_matrix =  [reflect.axis_offset_x[], reflect.axis_offset_y[]]

    reflect.baseOn.extremityA[] = (reflect_matrix * (reflect.start_atA[] - offset_matrix)) + offset_matrix
    reflect.baseOn.extremityB[] = (reflect_matrix * (reflect.start_atB[] - offset_matrix)) + offset_matrix
    reflect.baseOn.point[] = (reflect_matrix * (reflect.start_atC[] - offset_matrix)) + offset_matrix
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

    reflect_matrix =
        if reflect.axis == :x
            [1 0; 0 -1]
        elseif reflect.axis == :y
            [-1 0; 0 1]
        elseif reflect.axis == :diag
            [0 1; 1 0]
        elseif reflect.axis == :negdiag
            [0 -1; -1 0]
        elseif reflect.axis == :origin
            [-1 0; 0 -1]
        end
    offset_matrix =  [reflect.axis_offset_x[], reflect.axis_offset_y[]]
    end_atA = reflect_matrix * (reflect.start_atA[] - offset_matrix) + offset_matrix
    end_atB = reflect_matrix * (reflect.start_atB[] - offset_matrix) + offset_matrix
    end_atC = reflect_matrix * (reflect.start_atC[] - offset_matrix) + offset_matrix

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
            reflect.baseOn.extremityA[] = reflect.start_atA[] + on_t * uA * norm_vA
            reflect.baseOn.extremityB[] = reflect.start_atB[] + on_t * uB * norm_vB
            reflect.baseOn.point[] = reflect.start_atC[] + on_t * uC * norm_vC
        else
            reflect.baseOn.extremityA[] = end_atA
            reflect.baseOn.extremityB[] = end_atB
            reflect.baseOn.point[] = end_atC
        end
    end
end
