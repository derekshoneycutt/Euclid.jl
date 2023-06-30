
export EuclidSurfaceReflect, EuclidSurface2fReflect, EuclidSurface3fReflect, reflect, reset, show_complete, hide, animate

"""
    EuclidSurfaceReflect

Describes reflecting a surface in a Euclid diagram
"""
mutable struct EuclidSurfaceReflect{N}
    baseOn::EuclidSurface{N}
    axis_offset_x::Observable{Float32}
    axis_offset_y::Observable{Float32}
    axis_offset_z::Observable{Float32}
    start_points::Observable{Vector{Point{N, Float32}}}
    axis::Symbol
end
EuclidSurface2fReflect = EuclidSurfaceReflect{2}
EuclidSurface3fReflect = EuclidSurfaceReflect{3}

"""
    reflect(surface, rotation[, x_axis=0f0])

Set up a reflection of a surface on the Euclid diagram.

This always reflects on the x-axis. Combine with rotation for other reflections.

# Arguments
- `surface::EuclidSurface`: The surface to reflect in the diagram
- `axis::Symbol` : The axis to reflect across;
    2D can be :x, :y, :diag, :negdiag, or :origin;
    3D can be :xy, :xz, :yz, :diag3, :negdiag3, :altdiag3, or :origin3
- `axis_offset_x::Union{Float32,Observable{Float32}}`: The position of the x axis to reflect across
- `axis_offset_y::Union{Float32,Observable{Float32}}`: The position of the y axis to reflect across
- `axis_offset_z::Union{Float32,Observable{Float32}}`: The position of the z axis to reflect across
"""
function reflect(surface::EuclidSurface2f;
                 axis::Symbol=:x,
                 axis_offset_x::Union{Float32,Observable{Float32}}=0f0,
                 axis_offset_y::Union{Float32,Observable{Float32}}=0f0)

    if axis != :x && axis != :y && axis != :diag && axis != :negdiag && axis != :origin
        throw("Unsupported axis for 2D reflection. Supported symbols: :x, :y, :diag, or :negdiag")
    end
    reflect_offset_x = axis_offset_x isa Observable{Float32} ? axis_offset_x : Observable(axis_offset_x)
    reflect_offset_y = axis_offset_y isa Observable{Float32} ? axis_offset_y : Observable(axis_offset_y)
    start_points = Observable([p for p in surface.from_points[]])
    EuclidSurface2fReflect(surface, reflect_offset_x, reflect_offset_y, Observable(0f0), start_points, axis)
end
function reflect(surface::EuclidSurface3f;
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
    EuclidSurface3fReflect(surface, reflect_offset_x, reflect_offset_y, reflect_offset_z, Observable(surface.from_points[]), axis)
end

"""
    reset(reflect[, x_axis=0f0])

Reset a rotation animation for a surface in a Euclid Diagram to new positions

# Arguments
- `reflect::EuclidSurfaceReflect`: The description of the reflection to reset
- `axis::Symbol` : The axis to reflect across;
    2D can be :x, :y, :diag, :negdiag, or :origin;
    3D can be :xy, :xz, :yz,  :diag3, :negdiag3, :altdiag3, or :origin3
- `axis_offset_x::Union{Float32,Observable{Float32}}`: The position of the x-axis to reflect on
- `axis_offset_y::Union{Float32,Observable{Float32}}`: The position of the y-axis to reflect on
- `axis_offset_z::Union{Float32,Observable{Float32}}`: The position of the z-axis to reflect on
"""
function reset(reflect::EuclidSurface2fReflect;
               axis::Symbol=reflect.axis,
               axis_offset_x::Union{Float32,Observable{Float32}}=reflect.axis_offset_x,
               axis_offset_y::Union{Float32,Observable{Float32}}=reflect.axis_offset_y)

    if axis != :x && axis != :y && axis != :diag && axis != :negdiag && axis != :origin
        throw("Unsupported axis for 2D reflection. Supported symbols: :x, :y, :diag, or :negdiag")
    end
    reflect.start_points[] = [p for p in surface.from_points[]]
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
function reset(reflect::EuclidSurface2fReflect;
               axis::Symbol=reflect.axis,
               axis_offset_x::Union{Float32,Observable{Float32}}=reflect.axis_offset_x,
               axis_offset_y::Union{Float32,Observable{Float32}}=reflect.axis_offset_y,
               axis_offset_z::Union{Float32,Observable{Float32}}=reflect.axis_offset_z)

    if axis != :xy && axis != :yz && axis != :xz &&
            axis != :diag3 && axis != :negdiag3 && axis != :altdiag3 && axis != :origin3
        throw("Unsupported axis for 3D reflection. Supported symbols: :xy, :xz, :yz,  :diag3, :negdiag3, :altdiag3, or :origin3")
    end
    reflect.start_points[] = [p for p in surface.from_points[]]
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
    if axis_offset_z isa Observable{Float32}
        reflect.axis_offset_z = axis_offset_z
    else
        reflect.axis_offset_z[] = axis_offset_z
    end
    reflect.axis = axis
end

"""
    show_complete(reflect)

Complete a previously defined reflection operation for a surface in a Euclid diagram

# Arguments
- `reflect::EuclidSurfaceReflect`: The description of the reflection to finish rotating
"""
function show_complete(reflect::EuclidSurfaceReflect)
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
    reflect.baseOn.from_points[] = [(reflect_matrix * (p - offset_matrix)) + offset_matrix
                                    for p in reflect.start_points[]]
end

"""
    hide(reflect)

Move a surface in a Euclid diagram back to its starting position

# Arguments
- `reflect::EuclidSurfaceReflect`: The description of the rotation to "undo"
"""
function hide(reflect::EuclidSurfaceReflect)
    reflect.baseOn.from_points[] = reflect.start_points[]
end

"""
    animate(reflect, begin_move, end_move, t)

Animate reflecting a surface drawn in a Euclid diagram

# Arguments
- `reflect::EuclidSurfaceReflect`: The surface to animate in the diagram
- `begin_reflect::AbstractFloat`: The time point to begin reflecting the surface at
- `end_reflect::AbstractFloat`: The time point to finish reflecting the surface at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    reflect::EuclidSurfaceReflect,
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
    end_at = [(reflect_matrix * (p - offset_matrix) + offset_matrix, p)
              for p in reflect.start_points[]]
    vectors = [(end_p - p, p) for (end_p, p) in end_at]

    perform(t, begin_reflect, end_reflect,
         () -> begin
            reflect.start_points[] = reflect.baseOn.from_points[]
         end,
         () -> nothing) do
        on_t = (t - begin_reflect)/(end_reflect - begin_reflect)
        if on_t > 0
            reflect.baseOn.from_points[] = [(p + on_t * v) for (v, p) in vectors]
        else
            reflect.baseOn.from_points[] = [(end_p) for (end_p, p) in end_at]
        end
    end
end
