
export EuclidLine, EuclidLine2f, EuclidLine3f, line, highlight, intersection,
    EuclidLineRevealTransform, reveal,
    get_transformation_data, set_transformation_data, get_transformation_at_percent,
    EuclidLineResizeTransform, resize,
    EuclidLineColorShiftTransform, shift_color,
    EuclidLineMoveTransform, move,
    EuclidLineRotateTransform, rotate,
    EuclidLineReflectTransform, reflect,
    EuclidLineScaleTransform, scale,
    EuclidLineShearTransform, shear

"""
    EuclidLine{N}

Describes a line to be drawn and animated in Euclid diagrams
"""
struct EuclidLine{N}
    label::String
    data::Observable{EuclidSpaceLine{N}}
    linestyle
end
EuclidLine2f = EuclidLine{2}
EuclidLine3f = EuclidLine{3}

"""
    line(line[, width=1f0, color=:blue])
    line(extremityA, extremityB[, width=1f0, color=:blue])

Sets up a new line in a Euclid Diagram for drawing

# Arguments
- `label::String`: The text label representing the line; used as a hash lookup
- `theline::EuclidSpaceLine`: The line to create drawings for
- `extremityA::Point / EuclidSpacePoint`: The location of one extremity of the line to draw
- `extremityB::Point / EuclidSpacePoint`: The location of a second extremity of a line to draw
- `width::Union{Float32, Observable{Float32}}`: The width of the line to draw
- `color`: The color to draw the line with
- `linestyle`: The style to draw the line in
"""
function line(label::String, theline::Observable{EuclidSpaceLine2f}; linestyle=:solid)
    EuclidLine{2}(label, theline, linestyle)
end
function line(label::String, theline::Observable{EuclidSpaceLine3f}; linestyle=:solid)
    EuclidLine{3}(label, theline, linestyle)
end
function line(label::String, theline::EuclidSpaceLine2f; linestyle=:solid)
    line(label, Observable(theline), linestyle=linestyle)
end
function line(label::String, theline::EuclidSpaceLine3f; linestyle=:solid)
    line(label, Observable(theline), linestyle=linestyle)
end


"""
    EuclidLineRevealTransform

Representation of a transformation used to show or hide a EuclidLine
"""
struct EuclidLineRevealTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceLine{N}}
    add_opacity::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidLineRevealTransform, :base), EuclidTransformBase)

"""
    reveal(line, add_opacity, start_time, end_time)

Create an animation transformation for showing (or hiding) a line

# Arguments
- `line::EuclidLine`: The drawing line to animate
- `add_opacity::Float32`: The amount of opacity to add to show the line
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function reveal(line::EuclidLine, add_opacity::Float32,
        start_time::Float32, end_time::Float32)
    EuclidLineRevealTransform(EuclidTransformBase(line.label, start_time, end_time),
        line.data, add_opacity, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidLineRevealTransform
=#

function get_transformation_data(transform::EuclidLineRevealTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidLineRevealTransform, data::EuclidSpaceLine)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidLineRevealTransform, percent::Float32)
    transformation = changeopacity_line(transform.add_opacity,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidLineRevealTransform
=#

"""
    EuclidLineResizeTransform

Representation of a transformation used to resize a EuclidLine
"""
struct EuclidLineResizeTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceLine{N}}
    add_size::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidLineResizeTransform, :base), EuclidTransformBase)

"""
    resize(line, add_size, start_time, end_time)

Create an animation transformation for resizing a line

# Arguments
- `line::EuclidLine`: The drawing line to animate
- `add_size::Float32`: The amount of size to add to show the line
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function resize(line::EuclidLine, add_size::Float32,
        start_time::Float32, end_time::Float32)
    EuclidLineResizeTransform(EuclidTransformBase(line.label, start_time, end_time),
        line.data, add_size, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidLineResizeTransform
=#

function get_transformation_data(transform::EuclidLineResizeTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidLineResizeTransform, data::EuclidSpaceLine)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidLineResizeTransform, percent::Float32)
    transformation = changewidth_line(transform.add_size,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidLineResizeTransform
=#

"""
    EuclidLineColorShiftTransform

Representation of a transformation used to shift the color a EuclidLine
"""
struct EuclidLineColorShiftTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceLine{N}}
    color_shift::Point3f
    last_percent::Observable{Float32}
end
@forward((EuclidLineColorShiftTransform, :base), EuclidTransformBase)

"""
    color(line, color_shift, start_time, end_time)

Create an animation transformation for changing the color of a line

# Arguments
- `line::EuclidLine`: The drawing line to animate
- `color_shift::Point3f`: The color shift to apply to the line
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function shift_color(line::EuclidLine, color_shift::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidLineColorShiftTransform(EuclidTransformBase(line.label, start_time, end_time),
        line.data, color_shift, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidLineColorShiftTransform
=#

function get_transformation_data(transform::EuclidLineColorShiftTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidLineColorShiftTransform, data::EuclidSpaceLine)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidLineColorShiftTransform, percent::Float32)
    transformation = shiftcolor_line(transform.color_shift,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidLineColorShiftTransform
=#


"""
    highlight(line, color_shift, start_time, end_time[, add_size=10f0 or 0.04f0])

Set up highlighting a single line in a Euclid diagram

# Arguments
- `line::EuclidLine`: The line to highlight in the Diagram
- `color_shift:Point3f`: Vector to shift the color of the line by to highlight it
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `add_size::Float32`: The amount to add to the width to highlight the line
"""
function highlight(line::EuclidLine2f, color_shift::Point3f,
        start_time::Float32, end_time::Float32;
        add_size::Float32=10f0)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))
    [shift_color(line, color_shift, start_time, ptime(0.1)),
     resize(line, add_size, ptime(0.1), ptime(0.5)),
     resize(line, -add_size, ptime(0.5), ptime(0.9)),
     shift_color(line, Point3f(-1 * color_shift), ptime(0.9), end_time)]
end
function highlight(line::EuclidLine3f, color_shift::Point3f,
        start_time::Float32, end_time::Float32;
        add_size::Float32=0.04f0)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))
    [shift_color(line, color_shift, start_time, ptime(0.1)),
     resize(line, add_size, ptime(0.1), ptime(0.5)),
     resize(line, -add_size, ptime(0.5), ptime(0.9)),
     shift_color(line, Point3f(-1 * color_shift), ptime(0.9), end_time)]
end

"""
    EuclidLineMoveTransform

Representation of a transformation used to move a EuclidLine
"""
struct EuclidLineMoveTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceLine{N}}
    vector::Observable{EuclidLineVector{N}}
    last_percent::Observable{Float32}
end
@forward((EuclidLineMoveTransform, :base), EuclidTransformBase)

"""
    move(line, vector, start_time, end_time)

Create an animation transformation for moving a line

# Arguments
- `line::EuclidLine`: The drawing line to animate
- `vector::Point`: The vector to move the line along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function move(line::EuclidLine2f, vector::Observable{EuclidLineVector{2}},
        start_time::Float32, end_time::Float32)
    EuclidLineMoveTransform{2}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, vector, Observable(0f0))
end
function move(line::EuclidLine3f, vector::Observable{EuclidLineVector{3}},
        start_time::Float32, end_time::Float32)
    EuclidLineMoveTransform{3}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, vector, Observable(0f0))
end
function move(line::EuclidLine2f, vector::Point2f,
        start_time::Float32, end_time::Float32)
    move(line, Observable(EuclidLineVector{2}(vector, vector)), start_time, end_time)
end
function move(line::EuclidLine2f, vector::EuclidLineVector{2},
        start_time::Float32, end_time::Float32)
    move(line, Observable(vector), start_time, end_time)
end
function move(line::EuclidLine3f, vector::Point3f,
        start_time::Float32, end_time::Float32)
    move(line, Observable(EuclidLineVector{3}(vector, vector)), start_time, end_time)
end
function move(line::EuclidLine3f, vector::EuclidLineVector{3},
        start_time::Float32, end_time::Float32)
    move(line, Observable(vector), start_time, end_time)
end


#=
    BEGIN draw_animated_transforms interface for EuclidLineMoveTransform
=#

function get_transformation_data(transform::EuclidLineMoveTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidLineMoveTransform, data::EuclidSpaceLine)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidLineMoveTransform, percent::Float32)
    transformation = move_line(transform.vector[],
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidLineMoveTransform
=#

"""
EuclidLineRotateTransform

Representation of a transformation used to rotate a EuclidLine
"""
struct EuclidLineRotateTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceLine{N}}
    center::Observable{Point{N, Float32}}
    radians::Float32
    clockwise::Bool
    axis::Symbol
    last_percent::Observable{Float32}
end
@forward((EuclidLineRotateTransform, :base), EuclidTransformBase)

"""
    rotate(line, vector, start_time, end_time)

Create an animation transformation for rotating a line

# Arguments
- `line::EuclidLine`: The drawing line to animate
- `center::Point`: The center point to rotate around
- `radians::Float32`: The amount to rotate, in radians
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `clockwise::Bool`: Whether to rotate clockwise; default is false
"""
function rotate(line::EuclidLine2f, center::Observable{Point2f}, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidLineRotateTransform{2}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, center, radians, clockwise, :twod, Observable(0f0))
end
function rotate(line::EuclidLine2f, center::Point2f, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidLineRotateTransform{2}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(center), radians, clockwise, :twod, Observable(0f0))
end
function rotate(line::EuclidLine2f, center::Observable{EuclidSpacePoint2f}, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidLineRotateTransform{2}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observables.@map((&center).definition),
        radians, clockwise, :twod, Observable(0f0))
end
function rotate(line::EuclidLine2f, center::EuclidSpacePoint2f, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidLineRotateTransform{2}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(center.definition), radians, clockwise, :twod, Observable(0f0))
end
function rotate(line::EuclidLine2f, center::EuclidPoint2f, radians::Float32,
        start_time::Float32, end_time::Float32; clockwise::Bool=false)
    EuclidLineRotateTransform{2}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observables.@map(&(center.data).definition),
        radians, clockwise, :twod, Observable(0f0))
end
function rotate(line::EuclidLine3f, center::Observable{Point3f}, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    EuclidLineRotateTransform{3}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, center, radians, clockwise, axis, Observable(0f0))
end
function rotate(line::EuclidLine3f, center::Point3f, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    EuclidLineRotateTransform{3}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(center), radians, clockwise, axis, Observable(0f0))
end
function rotate(line::EuclidLine3f, center::Observable{EuclidSpacePoint3f}, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    EuclidLineRotateTransform{3}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observables.@map((&center).definition),
        radians, clockwise, axis, Observable(0f0))
end
function rotate(line::EuclidLine3f, center::EuclidSpacePoint3f, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    EuclidLineRotateTransform{3}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(center.definition), radians, clockwise, axis, Observable(0f0))
end
function rotate(line::EuclidLine3f, center::EuclidPoint3f, radians::Float32,
        start_time::Float32, end_time::Float32; axis::Symbol=:x, clockwise::Bool=false)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    EuclidLineRotateTransform{3}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observables.@map(&(center.data).definition),
        radians, clockwise, axis, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidLineRotateTransform
=#

function get_transformation_data(transform::EuclidLineRotateTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidLineRotateTransform, data::EuclidSpaceLine)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidLineRotateTransform, percent::Float32)
    transformation = rotate_line(transform.center[], transform.radians,
        clockwise=transform.clockwise,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidLineRotateTransform
=#

"""
    EuclidLineReflectTransform

Representation of a transformation used to move a EuclidLine to its reflection
"""
struct EuclidLineReflectTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceLine{N}}
    start_line::Observable{Union{EuclidSpaceLine{N}, Nothing}}
    offset::Point{N, Float32}
    axis::Symbol
    last_percent::Observable{Float32}
end
@forward((EuclidLineReflectTransform, :base), EuclidTransformBase)

"""
    reflect(line, vector, start_time, end_time)

Create an animation transformation for moving a line to its reflection

# Arguments
- `line::EuclidLine`: The drawing line to animate
- `vector::Point`: The vector to move the line along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function reflect(line::EuclidLine2f, start_time::Float32, end_time::Float32;
        axis::Symbol=:x, x_offset::Float32=0f0, y_offset::Float32=0f0)
    EuclidLineReflectTransform{2}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(nothing),
        Point2f0(x_offset, y_offset), axis, Observable(0f0))
end
function reflect(line::EuclidLine3f, start_time::Float32, end_time::Float32;
        axis::Symbol=:xy, x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    EuclidLineReflectTransform{3}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(nothing),
        Point3f0(x_offset, y_offset, z_offset), axis, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidLineReflectTransform
=#

function get_transformation_data(transform::EuclidLineReflectTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidLineReflectTransform, data::EuclidSpaceLine)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidLineReflectTransform{2}, percent::Float32)
    if transform.start_line[] === nothing
        transform.start_line[] = transform.data[]
    end
    reflect_to = reflect(transform.start_line[], axis=transform.axis,
        x_offset=transform.offset[1], y_offset=transform.offset[2])
    reflect_vector = vector(transform.start_line[], reflect_to)

    transformation = move_line(reflect_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end
function get_transformation_at_percent(
        transform::EuclidLineReflectTransform{3}, percent::Float32)
    if transform.start_line[] === nothing
        transform.start_line[] = transform.data[]
    end
    reflect_to = reflect(transform.start_line[], axis=transform.axis,
        x_offset=transform.offset[1], y_offset=transform.offset[2],
        z_offset=transform.offset[3])
    reflect_vector = vector(transform.start_line[], reflect_to)

    transformation = move_line(reflect_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidLineReflectTransform
=#


"""
    EuclidLineScaleTransform

Representation of a transformation used to move a EuclidLine to a scaled version
"""
struct EuclidLineScaleTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceLine{N}}
    start_line::Observable{Union{EuclidSpaceLine{N}, Nothing}}
    factors::Point{N, Float32}
    last_percent::Observable{Float32}
end
@forward((EuclidLineScaleTransform, :base), EuclidTransformBase)

"""
    scale(line, vector, start_time, end_time)

Create an animation transformation for moving a line to its scaled version

# Arguments
- `line::EuclidLine`: The drawing line to animate
- `factor::Float32`: The primary (x) factor to scale by
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `factory::Float32`: The y factor to scale by; defaults to the primary factor
- `factorz::Float32`: The z factor to scale by; defaults to the primary factor
"""
function scale(line::EuclidLine2f, factor::Float32, start_time::Float32, end_time::Float32;
        factory::Float32=factor)
    EuclidLineScaleTransform{2}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(nothing),
        Point2f0(factor, factory), Observable(0f0))
end
function scale(line::EuclidLine3f, factor::Float32, start_time::Float32, end_time::Float32;
        factory::Float32=factor, factorz::Float32=factor)
    EuclidLineScaleTransform{3}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(nothing),
        Point3f0(factor, factory, factorz), Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidLineScaleTransform
=#

function get_transformation_data(transform::EuclidLineScaleTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidLineScaleTransform, data::EuclidSpaceLine)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidLineScaleTransform{2}, percent::Float32)
    if transform.start_line[] === nothing
        transform.start_line[] = transform.data[]
    end
    scale_to = scale(transform.start_line[], transform.factors[1],
        factory=transform.factors[2])
    scale_vector = vector(transform.start_line[], scale_to)

    transformation = move_line(scale_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end
function get_transformation_at_percent(
        transform::EuclidLineScaleTransform{3}, percent::Float32)
    if transform.start_line[] === nothing
        transform.start_line[] = transform.data[]
    end
    scale_to = scale(transform.start_line[], transform.factors[1],
        factory=transform.factors[2], factorz=transform.factors[3])
    scale_vector = vector(transform.start_line[], scale_to)

    transformation = move_line(scale_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidLineScaleTransform
=#

"""
    EuclidLineShearTransform

Representation of a transformation used to move a EuclidLine to a sheared version
"""
struct EuclidLineShearTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceLine{N}}
    start_line::Observable{Union{EuclidSpaceLine{N}, Nothing}}
    factor::Float32
    direction::Symbol
    last_percent::Observable{Float32}
end
@forward((EuclidLineShearTransform, :base), EuclidTransformBase)

"""
shear(line, vector, start_time, end_time)

Create an animation transformation for moving a line to its sheared version

# Arguments
- `line::EuclidLine`: The drawing line to animate
- `factor::Float32`: The primary (x) factor to shear by
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `direction`: The direction of shearing to apply; defaults :ytox ; can be :ytox, :xtoy, :ztox, :ztoy, :xtoz, :ytoz
"""
function shear(line::EuclidLine2f, factor::Float32, start_time::Float32, end_time::Float32;
        direction::Symbol=:ytox)
    EuclidLineShearTransform{2}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(nothing),
        factor, direction, Observable(0f0))
end
function shear(line::EuclidLine3f, factor::Float32, start_time::Float32, end_time::Float32;
        direction::Symbol=:ytox)
    EuclidLineShearTransform{3}(EuclidTransformBase(line.label, start_time, end_time),
        line.data, Observable(nothing),
        factor, direction, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidLineShearTransform
=#

function get_transformation_data(transform::EuclidLineShearTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidLineShearTransform, data::EuclidSpaceLine)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidLineShearTransform{2}, percent::Float32)
    if transform.start_line[] === nothing
        transform.start_line[] = transform.data[]
    end
    shear_to = shear(transform.start_line[], transform.factor,
        direction=transform.direction)
    shear_vector = vector(transform.start_line[], shear_to)

    transformation = move_line(shear_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end
function get_transformation_at_percent(
        transform::EuclidLineShearTransform{3}, percent::Float32)
    if transform.start_line[] === nothing
        transform.start_line[] = transform.data[]
    end
    shear_to = shear(transform.start_line[], transform.factor,
        direction=transform.direction)
    shear_vector = vector(transform.start_line[], shear_to)

    transformation = move_line(shear_vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidLineShearTransform
=#

"""
    intersection(line1, line2)

Get the point of intersection of 2 lines, if present

# Arguments
- `line1::EuclidLine`: The first line to find intersection with
- `line2::EuclidLine`: The second line to find intersection with
- `label::String`: The label for the intersection point
- `showtext::Bool`: Whether to show the text for the point; default false
- `size::Float32`: Size of the point; default 0f0
- `opacity::Float32`: Opacity of the point; default 0f0
- `color`: Color of the point; default to the color of line1 at time of calling
"""
function intersection(line1::EuclidLine2f, line2::EuclidLine2f, label::String;
        showtext::Bool=false,
        size::Float32=0f0, opacity::Float32=0f0, color=line1.data[].color)
    A = point(label, Observables.@map(intersection(&(line1.data), &(line2.data),
        size=size, opacity=opacity, color=color)), showtext=showtext)
    return A
end
function intersection(line1::EuclidLine3f, line2::EuclidLine3f, label::String;
        showtext::Bool=false,
        size::Float32=0f0, opacity::Float32=0f0, color=line1.data[].color)
    A = point(label, Observables.@map(intersection(&(line1.data), &(line2.data),
        size=size, opacity=opacity, color=color)), showtext=showtext)
    return A
end
