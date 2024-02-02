
export EuclidAngle, EuclidAngle2f, EuclidAngle3f, plane_angle, highlight, intersection,
    EuclidAngleRevealTransform, reveal,
    get_transformation_data, set_transformation_data, get_transformation_at_percent,
    EuclidAngleResizeTransform, resize,
    EuclidAngleColorShiftTransform, shift_color,
    EuclidAngleMoveTransform, move,
    EuclidAngleRotateTransform, rotate,
    EuclidAngleReflectTransform, reflect,
    EuclidAngleScaleTransform, scale,
    EuclidAngleShearTransform, shear

"""
    EuclidAngle

Describes an angle to be drawn and animated in Euclid diagrams
"""
mutable struct EuclidAngle{N}
    label::String
    data::Observable{EuclidSpaceAngle{N}}
end
EuclidAngle2f = EuclidAngle{2}
EuclidAngle3f = EuclidAngle{3}

"""
    plane_angle()

Sets up a new angle in a Euclid Diagram for drawing. Basing on theta will not give an angle that watches observables

# Arguments

"""
function plane_angle(label::String, angle::Observable{EuclidSpaceAngle2f})
    EuclidAngle2f(label, angle)
end
function plane_angle(label::String, angle::Observable{EuclidSpaceAngle3f})
    EuclidAngle3f(label, angle)
end
function plane_angle(label::String, angle::EuclidSpaceAngle2f)
    plane_angle(label, Observable(angle))
end
function plane_angle(label::String, angle::EuclidSpaceAngle3f)
    plane_angle(label, Observable(angle))
end


"""
    EuclidAngleRevealTransform

Representation of a transformation used to show or hide a EuclidAngle
"""
struct EuclidAngleRevealTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceAngle{N}}
    add_opacity::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidAngleRevealTransform, :base), EuclidTransformBase)

"""
    reveal(angle, add_opacity, start_time, end_time)

Create an animation transformation for showing (or hiding) a angle

# Arguments
- `angle::EuclidAngle`: The drawing angle to animate
- `add_opacity::Float32`: The amount of opacity to add to show the surface
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function reveal(angle::EuclidAngle, add_opacity::Float32,
    start_time::Float32, end_time::Float32)

    EuclidAngleRevealTransform(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, add_opacity, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidAngleRevealTransform
=#

function get_transformation_data(transform::EuclidAngleRevealTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidAngleRevealTransform, data::EuclidSpaceAngle)
    transform.data[] = data
end

function get_transformation_at_percent(
    transform::EuclidAngleRevealTransform, percent::Float32)

    transformation = changeopacity_angle(transform.add_opacity,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidAngleRevealTransform
=#

"""
    EuclidAngleResizeTransform

Representation of a transformation used to resize a EuclidLine
"""
struct EuclidAngleResizeTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceAngle{N}}
    add_width::Float32
    add_radius::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidAngleResizeTransform, :base), EuclidTransformBase)

"""
    resize(angle, add_width, add_radius, start_time, end_time)

Create an animation transformation for resizing an angle

# Arguments
- `angle::EuclidAngle`: The drawing angle to animate
- `add_width::Float32`: The amount of width to add to show the angle
- `add_radius::Float32`: The amount of radius to add to show the angle
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function resize(angle::EuclidAngle, add_width::Float32, add_radius::Float32,
        start_time::Float32, end_time::Float32)
    EuclidAngleResizeTransform(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, add_width, add_radius, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidAngleResizeTransform
=#

function get_transformation_data(transform::EuclidAngleResizeTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidAngleResizeTransform, data::EuclidSpaceAngle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidAngleResizeTransform, percent::Float32)
    transformation = changesize_angle(transform.add_width, transform.add_radius,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidAngleResizeTransform
=#


"""
    EuclidAngleColorShiftTransform

Representation of a transformation used to shift the color a EuclidAngle
"""
struct EuclidAngleColorShiftTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceAngle{N}}
    color_shift::Point3f
    last_percent::Observable{Float32}
end
@forward((EuclidAngleColorShiftTransform, :base), EuclidTransformBase)

"""
    shift_color(angle, color_shift, start_time, end_time)

Create an animation transformation for changing the color of a angle

# Arguments
- `angle::EuclidAngle`: The drawing angle to animate
- `color_shift::Point3f`: The color shift to apply to the angle
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function shift_color(angle::EuclidAngle, color_shift::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidAngleColorShiftTransform(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, color_shift, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidAngleColorShiftTransform
=#

function get_transformation_data(transform::EuclidAngleColorShiftTransform)
    return transform.data[]
end

function set_transformation_data(
    transform::EuclidAngleColorShiftTransform, data::EuclidSpaceAngle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidAngleColorShiftTransform, percent::Float32)
    transformation = shiftcolor_angle(transform.color_shift,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidAngleColorShiftTransform
=#


"""
    highlight(angle, color_shift, start_time, end_time[, add_radius=0.04f0, add_width=add_radius])

Set up highlighting a single angle in a Euclid diagram

# Arguments
- `angle::EuclidAngle`: The angle to highlight in the Diagram
- `color_shift:Point3f`: Vector to shift the color of the angle by to highlight it
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `add_radius::Float32`: The amount to add to the radius to highlight the angle
- `add_width::Float32`: The amount to add to the width to highlight the angle
"""
function highlight(angle::EuclidAngle2f, color_shift::Point3f,
        start_time::Float32, end_time::Float32;
        add_radius::Float32=0.04f0)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))
    [shift_color(angle, color_shift, start_time, ptime(0.1)),
     resize(angle, 0f0, add_radius, ptime(0.1), ptime(0.5)),
     resize(angle, 0f0, -add_radius, ptime(0.5), ptime(0.9)),
     shift_color(angle, Point3f(-1 * color_shift), ptime(0.9), end_time)]
end
function highlight(angle::EuclidAngle3f, color_shift::Point3f,
        start_time::Float32, end_time::Float32;
        add_radius::Float32=0.04f0, add_width::Float32=add_radius)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))
    [shift_color(angle, color_shift, start_time, ptime(0.1)),
     resize(angle, add_width, add_radius, ptime(0.1), ptime(0.5)),
     resize(angle, -add_width, -add_radius, ptime(0.5), ptime(0.9)),
     shift_color(angle, Point3f(-1 * color_shift), ptime(0.9), end_time)]
end


"""
    EuclidAngleMoveTransform

Representation of a transformation used to move a EuclidAngle
"""
struct EuclidAngleMoveTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceAngle{N}}
    vector
    last_percent::Observable{Float32}
end
@forward((EuclidAngleMoveTransform, :base), EuclidTransformBase)

"""
    move(angle, vector, start_time, end_time)

Create an animation transformation for moving a angle

# Arguments
- `angle::EuclidAngle`: The drawing angle to animate
- `vector::Point`: The vector to move the angle along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function move(angle::EuclidAngle2f, vector::Point2f,
        start_time::Float32, end_time::Float32)
    EuclidAngleMoveTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, vector, Observable(0f0))
end
function move(angle::EuclidAngle2f, vector::EuclidAngleVector{2},
        start_time::Float32, end_time::Float32)
    EuclidAngleMoveTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, vector, Observable(0f0))
end
function move(angle::EuclidAngle3f, vector::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidAngleMoveTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, vector, Observable(0f0))
end
function move(angle::EuclidAngle2f, vector::EuclidAngleVector{3},
        start_time::Float32, end_time::Float32)
    EuclidAngleMoveTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, vector, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidAngleMoveTransform
=#

function get_transformation_data(transform::EuclidAngleMoveTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidAngleMoveTransform, data::EuclidSpaceAngle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidAngleMoveTransform, percent::Float32)
    transformation = move_angle(transform.vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidAngleMoveTransform
=#

"""
EuclidAngleRotateTransform

Representation of a transformation used to rotate a EuclidAngle
"""
struct EuclidAngleRotateTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceAngle{N}}
    center::Observable{Point{N, Float32}}
    radians::Float32
    clockwise::Bool
    axis::Symbol
    last_percent::Observable{Float32}
end
@forward((EuclidAngleRotateTransform, :base), EuclidTransformBase)

"""
    rotate(angle, vector, start_time, end_time)

Create an animation transformation for rotating a angle

# Arguments
- `angle::EuclidAngle`: The drawing angle to animate
- `center::Point`: The center point to rotate around
- `radians::Float32`: The amount to rotate, in radians
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `clockwise::Bool`: Whether to rotate clockwise; default is false
"""
function rotate(angle::EuclidAngle2f, center::Observable{Point2f}, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidAngleRotateTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, center, radians, clockwise, :twod, Observable(0f0))
end
function rotate(angle::EuclidAngle2f, center::Point2f, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidAngleRotateTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(center), radians, clockwise, :twod, Observable(0f0))
end
function rotate(angle::EuclidAngle2f, center::Observable{EuclidSpacePoint2f}, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidAngleRotateTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, @lift(($center).definition), radians, clockwise, :twod, Observable(0f0))
end
function rotate(angle::EuclidAngle2f, center::EuclidSpacePoint2f, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidAngleRotateTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(center.definition), radians, clockwise, :twod, Observable(0f0))
end
function rotate(angle::EuclidAngle2f, center::EuclidPoint2f, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidAngleRotateTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, @lift($(center.data).definition), radians, clockwise, :twod, Observable(0f0))
end
function rotate(angle::EuclidAngle3f, center::Observable{Point3f}, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D angles must be specified as :x, :y, or :z")
    end
    EuclidAngleRotateTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, center, radians, clockwise, axis, Observable(0f0))
end
function rotate(angle::EuclidAngle3f, center::Point3f, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D angles must be specified as :x, :y, or :z")
    end
    EuclidAngleRotateTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(center), radians, clockwise, axis, Observable(0f0))
end
function rotate(angle::EuclidAngle3f, center::Observable{EuclidSpacePoint3f}, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D angles must be specified as :x, :y, or :z")
    end
    EuclidAngleRotateTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, @lift(($center).definition), radians, clockwise, axis, Observable(0f0))
end
function rotate(angle::EuclidAngle3f, center::EuclidSpacePoint3f, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D angles must be specified as :x, :y, or :z")
    end
    EuclidAngleRotateTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(center.definition), radians, clockwise, axis, Observable(0f0))
end
function rotate(angle::EuclidAngle3f, center::EuclidPoint3f, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D angles must be specified as :x, :y, or :z")
    end
    EuclidAngleRotateTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, @lift($(center.data).definition), radians, clockwise, axis, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidAngleRotateTransform
=#

function get_transformation_data(transform::EuclidAngleRotateTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidAngleRotateTransform, data::EuclidSpaceAngle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidAngleRotateTransform, percent::Float32)
    transformation = rotate_angle(transform.center[], transform.radians,
        clockwise=transform.clockwise,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidAngleRotateTransform
=#


"""
    EuclidAngleReflectTransform

Representation of a transformation used to move a EuclidAngle to its reflection
"""
struct EuclidAngleReflectTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceAngle{N}}
    start_angle::Observable{Union{EuclidSpaceAngle{N}, Nothing}}
    offset::Point{N, Float32}
    axis::Symbol
    last_percent::Observable{Float32}
end
@forward((EuclidAngleReflectTransform, :base), EuclidTransformBase)

"""
    reflect(angle, vector, start_time, end_time)

Create an animation transformation for moving a angle to its reflection

# Arguments
- `angle::EuclidAngle`: The drawing angle to animate
- `vector::Point`: The vector to move the angle along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function reflect(angle::EuclidAngle2f, start_time::Float32, end_time::Float32;
        axis::Symbol=:x, x_offset::Float32=0f0, y_offset::Float32=0f0)
    EuclidAngleReflectTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(nothing),
        Point2f0(x_offset, y_offset), axis, Observable(0f0))
end
function reflect(angle::EuclidAngle3f, start_time::Float32, end_time::Float32;
        axis::Symbol=:xy, x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    EuclidAngleReflectTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(nothing),
        Point3f0(x_offset, y_offset, z_offset), axis, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidAngleReflectTransform
=#

function get_transformation_data(transform::EuclidAngleReflectTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidAngleReflectTransform, data::EuclidSpaceAngle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidAngleReflectTransform{2}, percent::Float32)
    if transform.start_angle[] === nothing
        transform.start_angle[] = transform.data[]
    end
    reflect_to = reflect(transform.start_angle[], axis=transform.axis,
        x_offset=transform.offset[1], y_offset=transform.offset[2])
    reflect_vector = vector(transform.start_angle[], reflect_to)

    transformation = move_angle(reflect_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end
function get_transformation_at_percent(
        transform::EuclidAngleReflectTransform{3}, percent::Float32)
    if transform.start_angle[] === nothing
        transform.start_angle[] = transform.data[]
    end
    reflect_to = reflect(transform.start_angle[], axis=transform.axis,
        x_offset=transform.offset[1], y_offset=transform.offset[2],
        z_offset=transform.offset[3])
    reflect_vector = vector(transform.start_angle[], reflect_to)

    transformation = move_angle(reflect_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidAngleReflectTransform
=#


"""
    EuclidAngleScaleTransform

Representation of a transformation used to move a EuclidAngle to a scaled version
"""
struct EuclidAngleScaleTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceAngle{N}}
    start_angle::Observable{Union{EuclidSpaceAngle{N}, Nothing}}
    factors::Point{N, Float32}
    last_percent::Observable{Float32}
end
@forward((EuclidAngleScaleTransform, :base), EuclidTransformBase)

"""
    scale(angle, vector, start_time, end_time)

Create an animation transformation for moving a angle to its scaled version

# Arguments
- `angle::EuclidAngle`: The drawing angle to animate
- `factor::Float32`: The primary (x) factor to scale by
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `factory::Float32`: The y factor to scale by; defaults to the primary factor
- `factorz::Float32`: The z factor to scale by; defaults to the primary factor
"""
function scale(angle::EuclidAngle2f, factor::Float32, start_time::Float32, end_time::Float32;
        factory::Float32=factor)
    EuclidAngleScaleTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(nothing),
        Point2f0(factor, factory), Observable(0f0))
end
function scale(angle::EuclidAngle3f, factor::Float32, start_time::Float32, end_time::Float32;
        factory::Float32=factor, factorz::Float32=factor)
    EuclidAngleScaleTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(nothing),
        Point3f0(factor, factory, factorz), Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidAngleScaleTransform
=#

function get_transformation_data(transform::EuclidAngleScaleTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidAngleScaleTransform, data::EuclidSpaceAngle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidAngleScaleTransform{2}, percent::Float32)
    if transform.start_angle[] === nothing
        transform.start_angle[] = transform.data[]
    end
    scale_to = scale(transform.start_angle[], transform.factors[1],
        factory=transform.factors[2])
    scale_vector = vector(transform.start_angle[], scale_to)

    transformation = move_angle(scale_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end
function get_transformation_at_percent(
        transform::EuclidAngleScaleTransform{3}, percent::Float32)
    if transform.start_angle[] === nothing
        transform.start_angle[] = transform.data[]
    end
    scale_to = scale(transform.start_angle[], transform.factors[1],
        factory=transform.factors[2], factorz=transform.factors[3])
    scale_vector = vector(transform.start_angle[], scale_to)

    transformation = move_angle(scale_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidAngleScaleTransform
=#

"""
    EuclidAngleShearTransform

Representation of a transformation used to move a EuclidAngle to a sheared version
"""
struct EuclidAngleShearTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceAngle{N}}
    start_angle::Observable{Union{EuclidSpaceAngle{N}, Nothing}}
    factor::Float32
    direction::Symbol
    last_percent::Observable{Float32}
end
@forward((EuclidAngleShearTransform, :base), EuclidTransformBase)

"""
shear(angle, vector, start_time, end_time)

Create an animation transformation for moving a angle to its sheared version

# Arguments
- `angle::EuclidAngle`: The drawing angle to animate
- `factor::Float32`: The primary (x) factor to shear by
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `direction`: The direction of shearing to apply; defaults :ytox ; can be :ytox, :xtoy, :ztox, :ztoy, :xtoz, :ytoz
"""
function shear(angle::EuclidAngle2f, factor::Float32, start_time::Float32, end_time::Float32;
        direction::Symbol=:ytox)
    EuclidAngleShearTransform{2}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(nothing),
        factor, direction, Observable(0f0))
end
function shear(angle::EuclidAngle3f, factor::Float32, start_time::Float32, end_time::Float32;
        direction::Symbol=:ytox)
    EuclidAngleShearTransform{3}(EuclidTransformBase(angle.label, start_time, end_time),
        angle.data, Observable(nothing),
        factor, direction, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidAngleShearTransform
=#

function get_transformation_data(transform::EuclidAngleShearTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidAngleShearTransform, data::EuclidSpaceAngle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidAngleShearTransform{2}, percent::Float32)
    if transform.start_angle[] === nothing
        transform.start_angle[] = transform.data[]
    end
    shear_to = shear(transform.start_angle[], transform.factor,
        direction=transform.direction)
    shear_vector = vector(transform.start_angle[], shear_to)

    transformation = move_angle(shear_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end
function get_transformation_at_percent(
        transform::EuclidAngleShearTransform{3}, percent::Float32)
    if transform.start_angle[] === nothing
        transform.start_angle[] = transform.data[]
    end
    shear_to = shear(transform.start_angle[], transform.factor,
        direction=transform.direction)
    shear_vector = vector(transform.start_angle[], shear_to)

    transformation = move_angle(shear_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidAngleShearTransform
=#

