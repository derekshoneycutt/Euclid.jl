
export EuclidPoint, EuclidPoint2f, EuclidPoint3f, point, highlight,
    EuclidPointRevealTransform, reveal,
    get_transformation_data, set_transformation_data, get_transformation_at_percent,
    EuclidPointResizeTransform, resize,
    EuclidPointColorShiftTransform, shift_color,
    EuclidPointMoveTransform, move

"""
    EuclidPoint{N}

Describes a point to be drawn and animated in Euclid diagrams
"""
struct EuclidPoint{N}
    label::String
    data::Observable{EuclidSpacePoint{N}}
    showtext::Bool
end
EuclidPoint2f = EuclidPoint{2}
EuclidPoint3f = EuclidPoint{3}

"""
    point(label, at_spot[, showtext=true])

Sets up a new point in a Euclid Diagram for drawing

# Arguments
- `label::String`: The text label to draw on the point; Also used as a hash lookup
- `at_spot::EuclidSpacePoint`: The location of the point to draw
- `showtext::Bool`: Whether or not to show the text label; if false, just shows the point only
"""
function point(label::String, at_spot::Observable{EuclidSpacePoint2f}; showtext=true)
    EuclidPoint{2}(label, at_spot, showtext)
end
function point(label::String, at_spot::Observable{EuclidSpacePoint3f}; showtext=true)
    EuclidPoint{3}(label, at_spot, showtext)
end
function point(label::String, at_spot::EuclidSpacePoint2f; showtext=true)
    point(label, Observable(at_spot), showtext=showtext)
end
function point(label::String, at_spot::EuclidSpacePoint3f; showtext=true)
    point(label, Observable(at_spot), showtext=showtext)
end

"""
    EuclidPointRevealTransform

Representation of a transformation used to show or hide a EuclidPoint
"""
struct EuclidPointRevealTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpacePoint{N}}
    add_opacity::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidPointRevealTransform, :base), EuclidTransformBase)

"""
    reveal(point, add_opacity, start_time, end_time)

Create an animation transformation for showing (or hiding) a point

# Arguments
- `point::EuclidPoint`: The drawing point to animate
- `add_opacity::Float32`: The amount of opacity to add to show the point
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function reveal(point::EuclidPoint, add_opacity::Float32,
        start_time::Float32, end_time::Float32)
    EuclidPointRevealTransform(EuclidTransformBase(point.label, start_time, end_time),
        point.data, add_opacity, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidPointRevealTransform
=#

function get_transformation_data(transform::EuclidPointRevealTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidPointRevealTransform, data::EuclidSpacePoint)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidPointRevealTransform, percent::Float32)
    transformation = changeopacity_point(transform.add_opacity,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidPointRevealTransform
=#

"""
    EuclidPointResizeTransform

Representation of a transformation used to resize a EuclidPoint
"""
struct EuclidPointResizeTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpacePoint{N}}
    add_size::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidPointResizeTransform, :base), EuclidTransformBase)

"""
    resize(point, add_size, start_time, end_time)

Create an animation transformation for resizing a point

# Arguments
- `point::EuclidPoint`: The drawing point to animate
- `add_size::Float32`: The amount of size to add to show the point
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function resize(point::EuclidPoint, add_size::Float32,
        start_time::Float32, end_time::Float32)
    EuclidPointResizeTransform(EuclidTransformBase(point.label, start_time, end_time),
        point.data, add_size, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidPointResizeTransform
=#

function get_transformation_data(transform::EuclidPointResizeTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidPointResizeTransform, data::EuclidSpacePoint)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidPointResizeTransform, percent::Float32)
    transformation = changesize_point(transform.add_size,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidPointResizeTransform
=#

"""
    EuclidPointColorShiftTransform

Representation of a transformation used to shift the color a EuclidPoint
"""
struct EuclidPointColorShiftTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpacePoint{N}}
    color_shift::Point3f
    last_percent::Observable{Float32}
end
@forward((EuclidPointColorShiftTransform, :base), EuclidTransformBase)

"""
    shift_color(point, color_shift, start_time, end_time)

Create an animation transformation for changing the color of a point

# Arguments
- `point::EuclidPoint`: The drawing point to animate
- `color_shift::Point3f`: The color shift to apply to the point
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function shift_color(point::EuclidPoint, color_shift::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidPointColorShiftTransform(EuclidTransformBase(point.label, start_time, end_time),
        point.data, color_shift, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidPointColorShiftTransform
=#

function get_transformation_data(transform::EuclidPointColorShiftTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidPointColorShiftTransform, data::EuclidSpacePoint)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidPointColorShiftTransform, percent::Float32)
    transformation = shiftcolor_point(transform.color_shift,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidPointColorShiftTransform
=#


"""
    highlight(point, color_shift, start_time, end_time[, add_size=0.02f0 or 0.03f0])

Set up highlighting a single point in a Euclid diagram

# Arguments
- `point::EuclidPoint`: The point to highlight in the diagram
- `color_shift:Point3f`: Vector to shift the color of the point by to highlight it
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `add_size::Float32`: The amount to add to the width to highlight the point
"""
function highlight(point::EuclidPoint2f, color_shift::Point3f,
        start_time::Float32, end_time::Float32;
        add_size::Float32=0.02f0)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))
    [
        shift_color(point, color_shift, start_time, ptime(0.1)),
        resize(point, add_size, ptime(0.1), ptime(0.5)),
        resize(point, -add_size, ptime(0.5), ptime(0.9)),
        shift_color(point, Point3f(-1 * color_shift), ptime(0.9), end_time)
    ]
end
function highlight(point::EuclidPoint3f, color_shift::Point3f,
        start_time::Float32, end_time::Float32;
        add_size::Float32=0.03f0)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))
    [
        shift_color(point, color_shift, start_time, ptime(0.1)),
        resize(point, add_size, ptime(0.1), ptime(0.5)),
        resize(point, -add_size, ptime(0.5), ptime(0.9)),
        shift_color(point, Point3f(-1 * color_shift), ptime(0.9), end_time)
    ]
end


"""
    EuclidPointMoveTransform

Representation of a transformation used to move a EuclidPoint
"""
struct EuclidPointMoveTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpacePoint{N}}
    vector::Observable{Point{N, Float32}}
    last_percent::Observable{Float32}
end
@forward((EuclidPointMoveTransform, :base), EuclidTransformBase)

"""
    move(point, vector, start_time, end_time)

Create an animation transformation for moving a point

# Arguments
- `point::EuclidPoint`: The drawing point to animate
- `vector::Point`: The vector to move the point along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function move(point::EuclidPoint2f, vector::Observable{Point2f},
        start_time::Float32, end_time::Float32)
    EuclidPointMoveTransform{2}(EuclidTransformBase(point.label, start_time, end_time),
        point.data, vector, Observable(0f0))
end
function move(point::EuclidPoint2f, vector::Point2f,
        start_time::Float32, end_time::Float32)
    EuclidPointMoveTransform{2}(EuclidTransformBase(point.label, start_time, end_time),
        point.data, Observable(vector), Observable(0f0))
end
function move(point::EuclidPoint3f, vector::Observable{Point3f},
        start_time::Float32, end_time::Float32)
    EuclidPointMoveTransform{3}(EuclidTransformBase(point.label, start_time, end_time),
        point.data, vector, Observable(0f0))
end
function move(point::EuclidPoint3f, vector::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidPointMoveTransform{3}(EuclidTransformBase(point.label, start_time, end_time),
        point.data, Observable(vector), Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidPointMoveTransform
=#

function get_transformation_data(transform::EuclidPointMoveTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidPointMoveTransform, data::EuclidSpacePoint)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidPointMoveTransform, percent::Float32)
    transformation = move_point(transform.vector[],
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidPointMoveTransform
=#

