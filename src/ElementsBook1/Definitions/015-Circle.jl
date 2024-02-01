export EuclidCircle, EuclidCircle2f, EuclidCircle3f, circle, highlight,
    EuclidCircleRevealTransform, reveal,
    get_transformation_data, set_transformation_data, get_transformation_at_percent,
    EuclidCircleColorShiftTransform, shift_color,
    EuclidCircleMoveTransform, move,
    EuclidCircleArcMoveTransform, arcmove

"""
    EuclidCircle{N}

Describes a circle to be drawn and animated in Euclid diagrams
"""
mutable struct EuclidCircle{N}
    label::String
    data::Observable{EuclidSpaceCircle{N}}
end
EuclidCircle2f = EuclidCircle{2}
EuclidCircle3f = EuclidCircle{3}


"""
    circle(center, radius[, startθ=0f0, endθ=2f0π, width=2f0, color=:blue, linestyle=:solid])

Sets up a new circle in a Euclid Diagram for drawing.

# Arguments
- `center::Point2f` : The center point of the circle
- `radius::Float32` : The radius of the circle to draw
- `startθ::Float32` : The starting angle; default is to draw whole circle
- `endθ::Float32` : The ending angle; default is to draw whole circle
- `width::Float32` : Width of the line to draw the circle
- `color` : Color of the circle to draw
- `linestyle` : The style of the line to draw for the circle
"""
function circle(label::String, data::Observable{EuclidSpaceCircle2f})
    EuclidCircle2f(label, data)
end
function circle(label::String, data::Observable{EuclidSpaceCircle3f})
    EuclidCircle3f(label, data)
end
function circle(label::String, data::EuclidSpaceCircle2f)
    circle(label, Observable(data))
end
function circle(label::String, data::EuclidSpaceCircle3f)
    circle(label, Observable(data))
end


"""
    EuclidCircleRevealTransform

Representation of a transformation used to show or hide a EuclidCircle
"""
struct EuclidCircleRevealTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceCircle{N}}
    add_opacity::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidCircleRevealTransform, :base), EuclidTransformBase)

"""
    reveal(circle, add_opacity, start_time, end_time)

Create an animation transformation for showing (or hiding) a circle

# Arguments
- `circle::EuclidCircle`: The drawing circle to animate
- `add_opacity::Float32`: The amount of opacity to add to show the circle
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function reveal(circle::EuclidCircle, add_opacity::Float32,
    start_time::Float32, end_time::Float32)

    EuclidCircleRevealTransform(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, add_opacity, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidCircleRevealTransform
=#

function get_transformation_data(transform::EuclidCircleRevealTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidCircleRevealTransform, data::EuclidSpaceCircle)
    transform.data[] = data
end

function get_transformation_at_percent(
    transform::EuclidCircleRevealTransform, percent::Float32)

    transformation = changeopacity_circle(transform.add_opacity,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidCircleRevealTransform
=#


"""
    EuclidCircleColorShiftTransform

Representation of a transformation used to shift the color a EuclidCircle
"""
struct EuclidCircleColorShiftTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceCircle{N}}
    color_shift::Point3f
    last_percent::Observable{Float32}
end
@forward((EuclidCircleColorShiftTransform, :base), EuclidTransformBase)

"""
    shift_color(circle, color_shift, start_time, end_time)

Create an animation transformation for changing the color of a circle

# Arguments
- `circle::EuclidCircle`: The drawing circle to animate
- `color_shift::Point3f`: The color shift to apply to the circle
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function shift_color(circle::EuclidCircle, color_shift::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidCircleColorShiftTransform(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, color_shift, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidCircleColorShiftTransform
=#

function get_transformation_data(transform::EuclidCircleColorShiftTransform)
    return transform.data[]
end

function set_transformation_data(
    transform::EuclidCircleColorShiftTransform, data::EuclidSpaceCircle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidCircleColorShiftTransform, percent::Float32)
    transformation = shiftcolor_circle(transform.color_shift,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidCircleColorShiftTransform
=#




"""
    EuclidCircleMoveTransform

Representation of a transformation used to move a EuclidCircle
"""
struct EuclidCircleMoveTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceCircle{N}}
    vector
    last_percent::Observable{Float32}
end
@forward((EuclidCircleMoveTransform, :base), EuclidTransformBase)

"""
    move(circle, vector, start_time, end_time)

Create an animation transformation for moving a circle

# Arguments
- `circle::EuclidCircle`: The drawing circle to animate
- `vector::Point`: The vector to move the circle along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function move(circle::EuclidCircle2f, vector::Point2f,
        start_time::Float32, end_time::Float32)
    EuclidCircleMoveTransform{2}(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, vector, Observable(0f0))
end
function move(circle::EuclidCircle2f, vector::EuclidCircleVector{2},
        start_time::Float32, end_time::Float32)
    EuclidCircleMoveTransform{2}(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, vector, Observable(0f0))
end
function move(circle::EuclidCircle3f, vector::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidCircleMoveTransform{3}(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, vector, Observable(0f0))
end
function move(circle::EuclidCircle2f, vector::EuclidCircleVector{3},
        start_time::Float32, end_time::Float32)
    EuclidCircleMoveTransform{3}(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, vector, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidCircleMoveTransform
=#

function get_transformation_data(transform::EuclidCircleMoveTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidCircleMoveTransform, data::EuclidSpaceCircle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidCircleMoveTransform, percent::Float32)
    transformation = move_circle(transform.vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidCircleMoveTransform
=#




"""
    EuclidCircleArcMoveTransform

Representation of a transformation used to move a EuclidCircle along an arc
"""
struct EuclidCircleArcMoveTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpaceCircle{N}}
    vector
    last_percent::Observable{Float32}
end
@forward((EuclidCircleArcMoveTransform, :base), EuclidTransformBase)

"""
    arcmove(circle, vector, start_time, end_time)

Create an animation transformation for moving a circle along an arc

# Arguments
- `circle::EuclidCircle`: The drawing circle to animate
- `vector::Point`: The vector to move the circle along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function arcmove(circle::EuclidCircle2f, vector::Point2f,
        start_time::Float32, end_time::Float32)
    EuclidCircleArcMoveTransform{2}(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, vector, Observable(0f0))
end
function arcmove(circle::EuclidCircle2f, vector::EuclidCircleVector{2},
        start_time::Float32, end_time::Float32)
    EuclidCircleArcMoveTransform{2}(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, vector, Observable(0f0))
end
function arcmove(circle::EuclidCircle3f, vector::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidCircleArcMoveTransform{3}(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, vector, Observable(0f0))
end
function arcmove(circle::EuclidCircle2f, vector::EuclidCircleVector{3},
        start_time::Float32, end_time::Float32)
    EuclidCircleArcMoveTransform{3}(EuclidTransformBase(circle.label, start_time, end_time),
        circle.data, vector, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidCircleArcMoveTransform
=#

function get_transformation_data(transform::EuclidCircleArcMoveTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidCircleArcMoveTransform, data::EuclidSpaceCircle)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidCircleArcMoveTransform, percent::Float32)
    transformation = arcmove_circle(transform.vector,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidCircleArcMoveTransform
=#



