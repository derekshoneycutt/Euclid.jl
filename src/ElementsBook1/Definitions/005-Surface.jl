
export EuclidSurface, EuclidSurface2f, EuclidSurface3f, surface,
    EuclidSurfaceRevealTransform, reveal,
    get_transformation_data, set_transformation_data, get_transformation_at_percent,
    EuclidSurfaceColorShiftTransform, shift_color,
    EuclidSurfaceMoveTransform, move,
    EuclidSurfaceRotateTransform, rotate,
    EuclidSurfaceReflectTransform, reflect,
    EuclidSurfaceScaleTransform, scale,
    EuclidSurfaceShearTransform, shear

"""
    EuclidSurface{N}

Describes a surface to be drawn and animated in Euclid diagrams
"""
mutable struct EuclidSurface{N}
    label::String
    data::Observable{EuclidSpaceSurface{N}}
end
EuclidSurface2f = EuclidSurface{2}
EuclidSurface3f = EuclidSurface{3}

"""
    surface(surface[, width=1f0, color=:blue])
    surface(extremityA, extremityB[, width=1f0, color=:blue])

Sets up a new surface in a Euclid Diagram for drawing

# Arguments
- `label::String`: The text label representing the surface; used as a hash lookup
- `thesurface::EuclidSpaceSurface`: The surface to create drawings for
- `opacity::Float32`: The opacity to draw the surface with
- `color`: The color to draw the surface within
"""
function surface(label::String, thesurface::Observable{EuclidSpaceSurface2f})
    EuclidSurface{2}(label, thesurface)
end
function surface(label::String, thesurface::Observable{EuclidSpaceSurface3f})
    EuclidSurface{3}(label, thesurface)
end
function surface(label::String, thesurface::EuclidSpaceSurface2f)
    surface(label, Observable(thesurface))
end
function surface(label::String, thesurface::EuclidSpaceSurface3f)
    surface(label, Observable(thesurface))
end


"""
    EuclidSurfaceRevealTransform

Representation of a transformation used to show or hide a EuclidSurface
"""
struct EuclidSurfaceRevealTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceSurface{N}}
    add_opacity::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidSurfaceRevealTransform, :base), EuclidTransformBase)

"""
    reveal(surface, add_opacity, start_time, end_time)

Create an animation transformation for showing (or hiding) a surface

# Arguments
- `surface::EuclidSurface`: The drawing surface to animate
- `add_opacity::Float32`: The amount of opacity to add to show the surface
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function reveal(surface::EuclidSurface, add_opacity::Float32,
    start_time::Float32, end_time::Float32)

    EuclidSurfaceRevealTransform(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, add_opacity, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidSurfaceRevealTransform
=#

function get_transformation_data(transform::EuclidSurfaceRevealTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidSurfaceRevealTransform, data::EuclidSpaceSurface)
    transform.data[] = data
end

function get_transformation_at_percent(
    transform::EuclidSurfaceRevealTransform, percent::Float32)

    transformation = changeopacity_surface(transform.add_opacity,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidSurfaceRevealTransform
=#

"""
    EuclidSurfaceColorShiftTransform

Representation of a transformation used to shift the color a EuclidSurface
"""
struct EuclidSurfaceColorShiftTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceSurface{N}}
    color_shift::Point3f
    last_percent::Observable{Float32}
end
@forward((EuclidSurfaceColorShiftTransform, :base), EuclidTransformBase)

"""
    shift_color(surface, color_shift, start_time, end_time)

Create an animation transformation for changing the color of a surface

# Arguments
- `surface::EuclidSurface`: The drawing surface to animate
- `color_shift::Point3f`: The color shift to apply to the surface
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function shift_color(surface::EuclidSurface, color_shift::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidSurfaceColorShiftTransform(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, color_shift, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidSurfaceColorShiftTransform
=#

function get_transformation_data(transform::EuclidSurfaceColorShiftTransform)
    return transform.data[]
end

function set_transformation_data(
    transform::EuclidSurfaceColorShiftTransform, data::EuclidSpaceSurface)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidSurfaceColorShiftTransform, percent::Float32)
    transformation = shiftcolor_surface(transform.color_shift,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidSurfaceColorShiftTransform
=#


"""
    EuclidSurfaceMoveTransform

Representation of a transformation used to move a EuclidSurface
"""
struct EuclidSurfaceMoveTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceSurface{N}}
    vector
    last_percent::Observable{Float32}
end
@forward((EuclidSurfaceMoveTransform, :base), EuclidTransformBase)

"""
    move(surface, vector, start_time, end_time)

Create an animation transformation for moving a surface

# Arguments
- `surface::EuclidSurface`: The drawing surface to animate
- `vector::Point`: The vector to move the surface along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function move(surface::EuclidSurface2f, vector::Point2f,
        start_time::Float32, end_time::Float32)
    EuclidSurfaceMoveTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, vector, Observable(0f0))
end
function move(surface::EuclidSurface2f, vector::EuclidSurfaceVector{2},
        start_time::Float32, end_time::Float32)
    EuclidSurfaceMoveTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, vector, Observable(0f0))
end
function move(surface::EuclidSurface3f, vector::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidSurfaceMoveTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, vector, Observable(0f0))
end
function move(surface::EuclidSurface2f, vector::EuclidSurfaceVector{3},
        start_time::Float32, end_time::Float32)
    EuclidSurfaceMoveTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, vector, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidSurfaceMoveTransform
=#

function get_transformation_data(transform::EuclidSurfaceMoveTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidSurfaceMoveTransform, data::EuclidSpaceSurface)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidSurfaceMoveTransform, percent::Float32)
    transformation = move_surface(transform.vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidSurfaceMoveTransform
=#

"""
EuclidSurfaceRotateTransform

Representation of a transformation used to rotate a EuclidSurface
"""
struct EuclidSurfaceRotateTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceSurface{N}}
    center::Observable{Point{N, Float32}}
    radians::Float32
    clockwise::Bool
    axis::Symbol
    last_percent::Observable{Float32}
end
@forward((EuclidSurfaceRotateTransform, :base), EuclidTransformBase)

"""
    rotate(surface, vector, start_time, end_time)

Create an animation transformation for rotating a surface

# Arguments
- `surface::EuclidSurface`: The drawing surface to animate
- `center::Point`: The center point to rotate around
- `radians::Float32`: The amount to rotate, in radians
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `clockwise::Bool`: Whether to rotate clockwise; default is false
"""
function rotate(surface::EuclidSurface2f, center::Observable{Point2f}, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidSurfaceRotateTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, center, radians, clockwise, :twod, Observable(0f0))
end
function rotate(surface::EuclidSurface2f, center::Point2f, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidSurfaceRotateTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(center), radians, clockwise, :twod, Observable(0f0))
end
function rotate(surface::EuclidSurface2f, center::Observable{EuclidSpacePoint2f}, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidSurfaceRotateTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observables.@map((&center).definition), radians, clockwise, :twod, Observable(0f0))
end
function rotate(surface::EuclidSurface2f, center::EuclidSpacePoint2f, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidSurfaceRotateTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(center.definition), radians, clockwise, :twod, Observable(0f0))
end
function rotate(surface::EuclidSurface2f, center::EuclidPoint2f, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidSurfaceRotateTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observables.@map(&(center.data).definition), radians, clockwise, :twod, Observable(0f0))
end
function rotate(surface::EuclidSurface3f, center::Observable{Point3f}, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D surfaces must be specified as :x, :y, or :z")
    end
    EuclidSurfaceRotateTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, center, radians, clockwise, axis, Observable(0f0))
end
function rotate(surface::EuclidSurface3f, center::Point3f, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D surfaces must be specified as :x, :y, or :z")
    end
    EuclidSurfaceRotateTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(center), radians, clockwise, axis, Observable(0f0))
end
function rotate(surface::EuclidSurface3f, center::Observable{EuclidSpacePoint3f}, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D surfaces must be specified as :x, :y, or :z")
    end
    EuclidSurfaceRotateTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observables.@map((&center).definition), radians, clockwise, axis, Observable(0f0))
end
function rotate(surface::EuclidSurface3f, center::EuclidSpacePoint3f, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D surfaces must be specified as :x, :y, or :z")
    end
    EuclidSurfaceRotateTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(center.definition), radians, clockwise, axis, Observable(0f0))
end
function rotate(surface::EuclidSurface3f, center::EuclidPoint3f, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D surfaces must be specified as :x, :y, or :z")
    end
    EuclidSurfaceRotateTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observables.@map(&(center.data).definition), radians, clockwise, axis, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidSurfaceRotateTransform
=#

function get_transformation_data(transform::EuclidSurfaceRotateTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidSurfaceRotateTransform, data::EuclidSpaceSurface)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidSurfaceRotateTransform, percent::Float32)
    transformation = rotate_surface(transform.center[], transform.radians,
        clockwise=transform.clockwise,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidSurfaceRotateTransform
=#


"""
    EuclidSurfaceReflectTransform

Representation of a transformation used to move a EuclidSurface to its reflection
"""
struct EuclidSurfaceReflectTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceSurface{N}}
    start_surface::Observable{Union{EuclidSpaceSurface{N}, Nothing}}
    offset::Point{N, Float32}
    axis::Symbol
    last_percent::Observable{Float32}
end
@forward((EuclidSurfaceReflectTransform, :base), EuclidTransformBase)

"""
    reflect(surface, vector, start_time, end_time)

Create an animation transformation for moving a surface to its reflection

# Arguments
- `surface::EuclidSurface`: The drawing surface to animate
- `vector::Point`: The vector to move the surface along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function reflect(surface::EuclidSurface2f, start_time::Float32, end_time::Float32;
        axis::Symbol=:x, x_offset::Float32=0f0, y_offset::Float32=0f0)
    EuclidSurfaceReflectTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(nothing),
        Point2f0(x_offset, y_offset), axis, Observable(0f0))
end
function reflect(surface::EuclidSurface3f, start_time::Float32, end_time::Float32;
        axis::Symbol=:xy, x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    EuclidSurfaceReflectTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(nothing),
        Point3f0(x_offset, y_offset, z_offset), axis, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidSurfaceReflectTransform
=#

function get_transformation_data(transform::EuclidSurfaceReflectTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidSurfaceReflectTransform, data::EuclidSpaceSurface)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidSurfaceReflectTransform{2}, percent::Float32)
    if transform.start_surface[] === nothing
        transform.start_surface[] = transform.data[]
    end
    reflect_to = reflect(transform.start_surface[], axis=transform.axis,
        x_offset=transform.offset[1], y_offset=transform.offset[2])
    reflect_vector = vector(transform.start_surface[], reflect_to)

    transformation = move_surface(reflect_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end
function get_transformation_at_percent(
        transform::EuclidSurfaceReflectTransform{3}, percent::Float32)
    if transform.start_surface[] === nothing
        transform.start_surface[] = transform.data[]
    end
    reflect_to = reflect(transform.start_surface[], axis=transform.axis,
        x_offset=transform.offset[1], y_offset=transform.offset[2],
        z_offset=transform.offset[3])
    reflect_vector = vector(transform.start_surface[], reflect_to)

    transformation = move_surface(reflect_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidSurfaceReflectTransform
=#


"""
    EuclidSurfaceScaleTransform

Representation of a transformation used to move a EuclidSurface to a scaled version
"""
struct EuclidSurfaceScaleTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceSurface{N}}
    start_surface::Observable{Union{EuclidSpaceSurface{N}, Nothing}}
    factors::Point{N, Float32}
    last_percent::Observable{Float32}
end
@forward((EuclidSurfaceScaleTransform, :base), EuclidTransformBase)

"""
    scale(surface, vector, start_time, end_time)

Create an animation transformation for moving a surface to its scaled version

# Arguments
- `surface::EuclidSurface`: The drawing surface to animate
- `factor::Float32`: The primary (x) factor to scale by
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `factory::Float32`: The y factor to scale by; defaults to the primary factor
- `factorz::Float32`: The z factor to scale by; defaults to the primary factor
"""
function scale(surface::EuclidSurface2f, factor::Float32, start_time::Float32, end_time::Float32;
        factory::Float32=factor)
    EuclidSurfaceScaleTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(nothing),
        Point2f0(factor, factory), Observable(0f0))
end
function scale(surface::EuclidSurface3f, factor::Float32, start_time::Float32, end_time::Float32;
        factory::Float32=factor, factorz::Float32=factor)
    EuclidSurfaceScaleTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(nothing),
        Point3f0(factor, factory, factorz), Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidSurfaceScaleTransform
=#

function get_transformation_data(transform::EuclidSurfaceScaleTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidSurfaceScaleTransform, data::EuclidSpaceSurface)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidSurfaceScaleTransform{2}, percent::Float32)
    if transform.start_surface[] === nothing
        transform.start_surface[] = transform.data[]
    end
    scale_to = scale(transform.start_surface[], transform.factors[1],
        factory=transform.factors[2])
    scale_vector = vector(transform.start_surface[], scale_to)

    transformation = move_surface(scale_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end
function get_transformation_at_percent(
        transform::EuclidSurfaceScaleTransform{3}, percent::Float32)
    if transform.start_surface[] === nothing
        transform.start_surface[] = transform.data[]
    end
    scale_to = scale(transform.start_surface[], transform.factors[1],
        factory=transform.factors[2], factorz=transform.factors[3])
    scale_vector = vector(transform.start_surface[], scale_to)

    transformation = move_surface(scale_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidSurfaceScaleTransform
=#

"""
    EuclidSurfaceShearTransform

Representation of a transformation used to move a EuclidSurface to a sheared version
"""
struct EuclidSurfaceShearTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceSurface{N}}
    start_surface::Observable{Union{EuclidSpaceSurface{N}, Nothing}}
    factor::Float32
    direction::Symbol
    last_percent::Observable{Float32}
end
@forward((EuclidSurfaceShearTransform, :base), EuclidTransformBase)

"""
shear(surface, vector, start_time, end_time)

Create an animation transformation for moving a surface to its sheared version

# Arguments
- `surface::EuclidSurface`: The drawing surface to animate
- `factor::Float32`: The primary (x) factor to shear by
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `direction`: The direction of shearing to apply; defaults :ytox ; can be :ytox, :xtoy, :ztox, :ztoy, :xtoz, :ytoz
"""
function shear(surface::EuclidSurface2f, factor::Float32, start_time::Float32, end_time::Float32;
        direction::Symbol=:ytox)
    EuclidSurfaceShearTransform{2}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(nothing),
        factor, direction, Observable(0f0))
end
function shear(surface::EuclidSurface3f, factor::Float32, start_time::Float32, end_time::Float32;
        direction::Symbol=:ytox)
    EuclidSurfaceShearTransform{3}(EuclidTransformBase(surface.label, start_time, end_time),
        surface.data, Observable(nothing),
        factor, direction, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidSurfaceShearTransform
=#

function get_transformation_data(transform::EuclidSurfaceShearTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidSurfaceShearTransform, data::EuclidSpaceSurface)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidSurfaceShearTransform{2}, percent::Float32)
    if transform.start_surface[] === nothing
        transform.start_surface[] = transform.data[]
    end
    shear_to = shear(transform.start_surface[], transform.factor,
        direction=transform.direction)
    shear_vector = vector(transform.start_surface[], shear_to)

    transformation = move_surface(shear_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end
function get_transformation_at_percent(
        transform::EuclidSurfaceShearTransform{3}, percent::Float32)
    if transform.start_surface[] === nothing
        transform.start_surface[] = transform.data[]
    end
    shear_to = shear(transform.start_surface[], transform.factor,
        direction=transform.direction)
    shear_vector = vector(transform.start_surface[], shear_to)

    transformation = move_surface(shear_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidSurfaceShearTransform
=#

