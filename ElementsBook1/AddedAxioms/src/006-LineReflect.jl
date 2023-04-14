
export EuclidLineReflect, EuclidLine2fReflect, EuclidLine3fReflect, reflect, reset, show_complete, hide, animate

"""
    EuclidLineReflect

Describes reflecting a line in a Euclid diagram
"""
mutable struct EuclidLineReflect{N}
    baseOn::EuclidLine{N}
    axis_offset_x::Observable{Float32}
    axis_offset_y::Observable{Float32}
    axis_offset_z::Observable{Float32}
    start_atA::Observable{Point{N, Float32}}
    start_atB::Observable{Point{N, Float32}}
    axis::Symbol
end
EuclidLine2fReflect = EuclidLineReflect{2}
EuclidLine3fReflect = EuclidLineReflect{3}

"""
    reflect(line, rotation[, axis_offset=0f0])

Set up a reflection of a line on the Euclid diagram.

This always reflects on the x-axis. Combine with rotation for other reflections.

# Arguments
- `line::EuclidLine2f`: The line to reflect in the diagram
- `axis::Symbol` : The axis to reflect across;
    2D can be :x, :y, :diag, :negdiag, or :origin;
    3D can be :xy, :xz, :yz, :diag3, :negdiag3, :altdiag3, or :origin3
- `axis_offset::Union{Float32,Observable{Float32}}`: The position of the axis to reflect across
"""
function reflect(line::EuclidLine2f;
                 axis::Symbol=:x,
                 axis_offset_x::Union{Float32,Observable{Float32}}=0f0,
                 axis_offset_y::Union{Float32,Observable{Float32}}=0f0)

    if axis != :x && axis != :y && axis != :diag && axis != :negdiag && axis != :origin
        throw("Unsupported axis for 2D reflection. Supported symbols: :x, :y, :diag, or :negdiag")
    end
    reflect_offset_x = axis_offset_x isa Observable{Float32} ? axis_offset_x : Observable(axis_offset_x)
    reflect_offset_y = axis_offset_y isa Observable{Float32} ? axis_offset_y : Observable(axis_offset_y)
    EuclidLine2fReflect(line, reflect_offset_x, reflect_offset_y, Observable(0f0), Observable(line.extremityA[]), Observable(line.extremityA[]), axis)
end
function reflect(line::EuclidLine3f;
                 axis::Symbol=:xy,
                 axis_offset_x::Union{Float32,Observable{Float32}}=0f0,
                 axis_offset_y::Union{Float32,Observable{Float32}}=0f0,
                 axis_offset_z::Union{Float32,Observable{Float32}}=0f0)

    if axis != :xy && axis != :yz && axis != :xz &&
            axis != :diag3 && axis != :negdiag3 && axis != :altdiag3 && axis != :origin3
        throw("Unsupported axis for 3D reflection. Supported symbols: :xy, :xz, :yz,  :diag3, :negdiag3, :altdiag3, or :origin3")
    end
    reflect_offset_x = axis_offset_x isa Observable{Float32} ? axis_offset_x : Observable(axis_offset_x)
    reflect_offset_y = axis_offset_y isa Observable{Float32} ? axis_offset_y : Observable(axis_offset_y)
    reflect_offset_z = axis_offset_z isa Observable{Float32} ? axis_offset_z : Observable(axis_offset_z)
    EuclidLine3fReflect(line, reflect_offset_x, reflect_offset_y, reflect_offset_z, Observable(line.extremityA[]), Observable(line.extremityA[]), axis)
end

"""
    reset(reflect[, x_axis=0f0])

Reset a rotation animation for a line in a Euclid Diagram to new positions

# Arguments
- `reflect::EuclidLineReflect`: The description of the reflection to reset
- `axis::Symbol` : The axis to reflect across;
    2D can be :x, :y, :diag, :negdiag, or :origin;
    3D can be :xy, :xz, :yz,  :diag3, :negdiag3, :altdiag3, or :origin3
- `axis_offset::Union{Float32,Observable{Float32}}`: The position of the x-axis to reflect on
"""
function reset(reflect::EuclidLine2fReflect; axis::Symbol=reflect.axis, axis_offset::Union{Float32,Observable{Float32}}=reflect.reflect_x)

    if axis != :x && axis != :y && axis != :diag && axis != :negdiag && axis != :origin
        throw("Unsupported axis for 2D reflection. Supported symbols: :x, :y, :diag, or :negdiag")
    end
    reflect.start_atA[] = reflect.baseOn.extremityA[]
    reflect.start_atB[] = reflect.baseOn.extremityB[]
    if axis_offset isa Observable{Float32}
        reflect.axis_offset = axis_offset
    else
        reflect.axis_offset[] = axis_offset
    end
    reflect.axis = axis
end
function reset(reflect::EuclidLine3fReflect; axis::Symbol=reflect.axis, axis_offset::Union{Float32,Observable{Float32}}=reflect.reflect_x)

    if axis != :xy && axis != :yz && axis != :xz &&
            axis != :diag3 && axis != :negdiag3 && axis != :altdiag3 && axis != :origin3
        throw("Unsupported axis for 3D reflection. Supported symbols: :xy, :xz, :yz,  :diag3, :negdiag3, :altdiag3, or :origin3")
    end
    reflect.start_atA[] = reflect.baseOn.extremityA[]
    reflect.start_atB[] = reflect.baseOn.extremityB[]
    if axis_offset isa Observable{Float32}
        reflect.axis_offset = axis_offset
    else
        reflect.axis_offset[] = axis_offset
    end
    reflect.axis = axis
end

"""
    show_complete(reflect)

Complete a previously defined reflection operation for a line in a Euclid diagram

# Arguments
- `reflect::EuclidLineReflect`: The description of the reflection to finish rotating
"""
function show_complete(reflect::EuclidLineReflect)
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
        elseif reflect.axis == :xy
            [1 0 0; 0 1 0; 0 0 -1]
        elseif reflect.axis == :yz
            [-1 0 0; 0 1 0; 0 0 1]
        elseif reflect.axis == :xz
            [1 0 0; 0 -1 0; 0 0 1]
        elseif reflect.axis == :diag3
            [0 0 1; 0 1 0; 1 0 0]
        elseif reflect.axis == :negdiag3
            [0 0 -1; 0 -1 0; -1 0 0]
        elseif reflect.axis == :altdiag3
            [0 0 -1; 0 1 0; -1 0 0]
        elseif reflect.axis == :origin3
            [-1 0 0; 0 -1 0; 0 0 -1]
        end
    offset_matrix =
        if reflect.axis == :x || reflect.axis == :y || reflect.axis == :diag || reflect.axis == :negdiag || reflect.axis == :origin
            [reflect.axis_offset_x[], reflect.axis_offset_y[]]
        elseif reflect.axis == :xy || reflect.axis == :yz || reflect.axis == :xz ||
                reflect.axis == :diag3 || reflect.axis == :negdiag3 || reflect.axis == :altdiag3 || reflect.axis == :origin3
            [reflect.axis_offset_x[], reflect.axis_offset_y[], reflect.axis_offset_z[]]
        end
    reflect.baseOn.extremityA[] = (reflect_matrix * (reflect.start_atA[] - offset_matrix)) + offset_matrix
    reflect.baseOn.extremityB[] = (reflect_matrix * (reflect.start_atB[] - offset_matrix)) + offset_matrix
end

"""
    hide(reflect)

Move a line in a Euclid diagram back to its starting position

# Arguments
- `reflect::EuclidLineReflect`: The description of the rotation to "undo"
"""
function hide(reflect::EuclidLineReflect)
    reflect.baseOn.extremityA[] = reflect.start_atA[]
    reflect.baseOn.extremityB[] = reflect.start_atB[]
end

"""
    animate(reflect, begin_move, end_move, t)

Animate reflecting a line drawn in a Euclid diagram

# Arguments
- `reflect::EuclidLineReflect`: The line to animate in the diagram
- `begin_reflect::AbstractFloat`: The time point to begin reflecting the line at
- `end_reflect::AbstractFloat`: The time point to finish reflecting the line at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    reflect::EuclidLineReflect,
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
        elseif reflect.axis == :xy
            [1 0 0; 0 1 0; 0 0 -1]
        elseif reflect.axis == :yz
            [-1 0 0; 0 1 0; 0 0 1]
        elseif reflect.axis == :xz
            [1 0 0; 0 -1 0; 0 0 1]
        elseif reflect.axis == :diag3
            [0 0 1; 0 1 0; 1 0 0]
        elseif reflect.axis == :negdiag3
            [0 0 -1; 0 -1 0; -1 0 0]
        elseif reflect.axis == :altdiag3
            [0 0 -1; 0 1 0; -1 0 0]
        elseif reflect.axis == :origin3
            [-1 0 0; 0 -1 0; 0 0 -1]
        end
    offset_matrix =
        if reflect.axis == :x || reflect.axis == :y || reflect.axis == :diag || reflect.axis == :negdiag || reflect.axis == :origin
            [reflect.axis_offset_x[], reflect.axis_offset_y[]]
        elseif reflect.axis == :xy || reflect.axis == :yz || reflect.axis == :xz ||
                reflect.axis == :diag3 || reflect.axis == :negdiag3 || reflect.axis == :altdiag3 || reflect.axis == :origin3
            [reflect.axis_offset_x[], reflect.axis_offset_y[], reflect.axis_offset_z[]]
        end
    end_atA = (reflect_matrix * (reflect.start_atA[] - offset_matrix)) + offset_matrix
    end_atB = (reflect_matrix * (reflect.start_atB[] - offset_matrix)) + offset_matrix

    vA = end_atA - reflect.start_atA[]
    norm_vA = norm(vA)
    uA = vA / norm_vA
    vB = end_atB - reflect.start_atB[]
    norm_vB = norm(vB)
    uB = vB / norm_vB

    perform(t, begin_reflect, end_reflect,
         () -> begin
            reflect.start_atA[] = reflect.baseOn.extremityA[]
            reflect.start_atB[] = reflect.baseOn.extremityB[]
         end,
         () -> nothing) do
        on_t = (t - begin_reflect)/(end_reflect - begin_reflect)
        if on_t > 0
            reflect.baseOn.extremityA[] = (reflect.start_atA[] + on_t * uA * norm_vA)
            reflect.baseOn.extremityB[] = (reflect.start_atB[] + on_t * uB * norm_vB)
        else
            reflect.baseOn.extremityA[] = end_atA
            reflect.baseOn.extremityB[] = end_atB
        end
    end
end
