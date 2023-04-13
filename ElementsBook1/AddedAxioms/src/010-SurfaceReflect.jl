
export EuclidSurface2fReflect, reflect, reset, show_complete, hide, animate

"""
    EuclidSurface2fReflect

Describes reflecting a surface in a Euclid diagram
"""
mutable struct EuclidSurface2fReflect
    baseOn::EuclidSurface2f
    reflect_x::Observable{Float32}
    start_points::Observable{Vector{Point2f}}
end

"""
    reflect(surface, rotation[, x_axis=0f0])

Set up a reflection of a surface on the Euclid diagram.

This always reflects on the x-axis. Combine with rotation for other reflections.

# Arguments
- `surface::EuclidSurface2f`: The surface to reflect in the diagram
- `x_axis::Union{Float32,Observable{Float32}}`: The position of the x-axis to reflect on
"""
function reflect(surface::EuclidSurface2f; x_axis::Union{Float32,Observable{Float32}}=0f0)

    reflect_x = x_axis isa Observable{Float32} ? x_axis : Observable(x_axis)
    start_points = Observable([p for p in surface.from_points[]])
    EuclidSurface2fReflect(surface, reflect_x, start_points)
end

"""
    reset(reflect[, x_axis=0f0])

Reset a rotation animation for a surface in a Euclid Diagram to new positions

# Arguments
- `reflect::EuclidSurface2fReflect`: The description of the reflection to reset
- `x_axis::Union{Float32,Observable{Float32}}`: The position of the x-axis to reflect on
"""
function reset(reflect::EuclidSurface2fReflect; x_axis::Union{Float32,Observable{Float32}}=reflect.reflect_x)

    reflect.start_points[] = [p for p in surface.from_points[]]
    if x_axis isa Observable{Float32}
        reflect.reflect_x = x_axis
    else
        reflect.reflect_x[] = x_axis
    end
end

"""
    show_complete(reflect)

Complete a previously defined reflection operation for a surface in a Euclid diagram

# Arguments
- `reflect::EuclidSurface2fReflect`: The description of the reflection to finish rotating
"""
function show_complete(reflect::EuclidSurface2fReflect)
    new_points = [[1 0; 0 -1] * p for p in reflect.start_points[]]
    reflect.baseOn.from_points[] = new_points
end

"""
    hide(reflect)

Move a surface in a Euclid diagram back to its starting position

# Arguments
- `reflect::EuclidSurface2fReflect`: The description of the rotation to "undo"
"""
function hide(reflect::EuclidSurface2fReflect)
    reflect.baseOn.from_points[] = reflect.start_points[]
end

"""
    animate(reflect, begin_move, end_move, t)

Animate reflecting a surface drawn in a Euclid diagram

# Arguments
- `reflect::EuclidSurface2fReflect`: The surface to animate in the diagram
- `begin_reflect::AbstractFloat`: The time point to begin reflecting the surface at
- `end_reflect::AbstractFloat`: The time point to finish reflecting the surface at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    reflect::EuclidSurface2fReflect,
    begin_reflect::AbstractFloat, end_reflect::AbstractFloat, t::AbstractFloat)

    end_at = [([1 0; 0 -1] * (p - [0, reflect.reflect_x[]]) + [0, reflect.reflect_x[]], p)
              for p in reflect.start_points[]]
    vectors = [(end_p - p, p) for (end_p, p) in end_at]

    perform(t, begin_reflect, end_reflect,
         () -> begin
            reflect.start_points[] = reflect.baseOn.from_points[]
         end,
         () -> nothing) do
        on_t = (t - begin_reflect)/(end_reflect - begin_reflect)
        if on_t > 0
            new_points = [Point2f0(p + on_t * v) for (v, p) in vectors]
            reflect.baseOn.from_points[] = new_points
        else
            new_points = [Point2f0(end_p) for (end_p, p) in end_at]
            reflect.baseOn.from_points[] = new_points
        end
    end
end
