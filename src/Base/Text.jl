
export EuclidText, EuclidText2f, EuclidText3f, text, show_complete, hide, animate

"""
    EuclidText2f

Describes text to be drawn in Euclid diagrams
"""
struct EuclidText{N}
    label::String
    text::String
    data::Observable{EuclidSpacePoint{N}}
end
EuclidText2f = EuclidText{2}
EuclidText3f = EuclidText{3}

"""
    text(label, text, at_spot)

Sets up a new text in a Euclid Diagram for drawing

# Arguments
- `label::String`: The label of the text; Used as a hash lookup
- `text::String`: The text to show
- `at_spot::EuclidSpacePoint`: The location of the point to draw
"""
function text(label::String, text::String, at_spot::Observable{EuclidSpacePoint2f})
    EuclidText{2}(label, text, at_spot)
end
function text(label::String, text::String, at_spot::Observable{EuclidSpacePoint3f})
    EuclidText{3}(label, text, at_spot)
end
function text(label::String, text::String, at_spot::EuclidSpacePoint2f)
    text(label, text, Observable(at_spot))
end
function text(label::String, text::String, at_spot::EuclidSpacePoint3f)
    text(label, text, Observable(at_spot))
end


"""
    EuclidTextRevealTransform

Representation of a transformation used to show or hide a EuclidText
"""
struct EuclidTextRevealTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpacePoint{N}}
    add_opacity::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidTextRevealTransform, :base), EuclidTransformBase)

"""
    reveal(text, add_opacity, start_time, end_time)

Create an animation transformation for showing (or hiding) a text

# Arguments
- `text::EuclidText`: The drawing text to animate
- `add_opacity::Float32`: The amount of opacity to add to show the text
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function reveal(text::EuclidText, add_opacity::Float32,
        start_time::Float32, end_time::Float32)
    EuclidTextRevealTransform(EuclidTransformBase(text.label, start_time, end_time),
        text.data, add_opacity, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidTextRevealTransform
=#

function get_transformation_data(transform::EuclidTextRevealTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidTextRevealTransform, data::EuclidSpacePoint)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidTextRevealTransform, percent::Float32)
    transformation = changeopacity_point(transform.add_opacity,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidTextRevealTransform
=#

"""
    EuclidTextResizeTransform

Representation of a transformation used to resize a EuclidText
"""
struct EuclidTextResizeTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpacePoint{N}}
    add_size::Float32
    last_percent::Observable{Float32}
end
@forward((EuclidTextResizeTransform, :base), EuclidTransformBase)

"""
    resize(text, add_size, start_time, end_time)

Create an animation transformation for resizing a text

# Arguments
- `text::EuclidText`: The drawing text to animate
- `add_size::Float32`: The amount of size to add to show the text
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function resize(text::EuclidText, add_size::Float32,
        start_time::Float32, end_time::Float32)
    EuclidTextResizeTransform(EuclidTransformBase(text.label, start_time, end_time),
        text.data, add_size, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidTextResizeTransform
=#

function get_transformation_data(transform::EuclidTextResizeTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidTextResizeTransform, data::EuclidSpacePoint)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidTextResizeTransform, percent::Float32)
    transformation = changesize_point(transform.add_size,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidTextResizeTransform
=#

"""
    EuclidTextColorShiftTransform

Representation of a transformation used to shift the color a EuclidText
"""
struct EuclidTextColorShiftTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpacePoint{N}}
    color_shift::Point3f
    last_percent::Observable{Float32}
end
@forward((EuclidTextColorShiftTransform, :base), EuclidTransformBase)

"""
    shift_color(text, color_shift, start_time, end_time)

Create an animation transformation for changing the color of a text

# Arguments
- `text::EuclidText`: The drawing text to animate
- `color_shift::Point3f`: The color shift to apply to the text
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function shift_color(text::EuclidText, color_shift::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidTextColorShiftTransform(EuclidTransformBase(text.label, start_time, end_time),
        text.data, color_shift, Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidTextColorShiftTransform
=#

function get_transformation_data(transform::EuclidTextColorShiftTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidTextColorShiftTransform, data::EuclidSpacePoint)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidTextColorShiftTransform, percent::Float32)
    transformation = shiftcolor_point(transform.color_shift,
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidTextColorShiftTransform
=#


"""
    highlight(text, color_shift, start_time, end_time[, add_size=0.02f0 or 0.03f0])

Set up highlighting a single text in a Euclid diagram

# Arguments
- `text::EuclidText`: The text to highlight in the diagram
- `color_shift:Point3f`: Vector to shift the color of the text by to highlight it
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
- `add_size::Float32`: The amount to add to the width to highlight the text
"""
function highlight(text::EuclidText2f, color_shift::Point3f,
        start_time::Float32, end_time::Float32;
        add_size::Float32=0.02f0)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))
    [
        shift_color(text, color_shift, start_time, ptime(0.1)),
        resize(text, add_size, ptime(0.1), ptime(0.5)),
        resize(text, -add_size, ptime(0.5), ptime(0.9)),
        shift_color(text, Point3f(-1 * color_shift), ptime(0.9), end_time)
    ]
end
function highlight(text::EuclidText3f, color_shift::Point3f,
        start_time::Float32, end_time::Float32;
        add_size::Float32=0.03f0)
    duration = end_time - start_time
    ptime(p) = Float32(start_time + (duration * p))
    [
        shift_color(text, color_shift, start_time, ptime(0.1)),
        resize(text, add_size, ptime(0.1), ptime(0.5)),
        resize(text, -add_size, ptime(0.5), ptime(0.9)),
        shift_color(text, Point3f(-1 * color_shift), ptime(0.9), end_time)
    ]
end


"""
    EuclidTextMoveTransform

Representation of a transformation used to move a EuclidText
"""
struct EuclidTextMoveTransform{N}
    base::EuclidTransformBase
    data::Observable{EuclidSpacePoint{N}}
    vector::Observable{Point{N, Float32}}
    last_percent::Observable{Float32}
end
@forward((EuclidTextMoveTransform, :base), EuclidTransformBase)

"""
    move(text, vector, start_time, end_time)

Create an animation transformation for moving a text

# Arguments
- `text::EuclidText`: The drawing text to animate
- `vector::Point`: The vector to move the text along
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function move(text::EuclidText2f, vector::Observable{Point2f},
        start_time::Float32, end_time::Float32)
    EuclidTextMoveTransform{2}(EuclidTransformBase(text.label, start_time, end_time),
        text.data, vector, Observable(0f0))
end
function move(text::EuclidText2f, vector::Point2f,
        start_time::Float32, end_time::Float32)
    EuclidTextMoveTransform{2}(EuclidTransformBase(text.label, start_time, end_time),
        text.data, Observable(vector), Observable(0f0))
end
function move(text::EuclidText3f, vector::Observable{Point3f},
        start_time::Float32, end_time::Float32)
    EuclidTextMoveTransform{3}(EuclidTransformBase(text.label, start_time, end_time),
        text.data, vector, Observable(0f0))
end
function move(text::EuclidText3f, vector::Point3f,
        start_time::Float32, end_time::Float32)
    EuclidTextMoveTransform{3}(EuclidTransformBase(text.label, start_time, end_time),
        text.data, Observable(vector), Observable(0f0))
end


#=
    BEGIN draw_animated_transforms interface for EuclidTextMoveTransform
=#

function get_transformation_data(transform::EuclidTextMoveTransform)
    return transform.data[]
end

function set_transformation_data(transform::EuclidTextMoveTransform, data::EuclidSpacePoint)
    transform.data[] = data
end

function get_transformation_at_percent(
        transform::EuclidTextMoveTransform, percent::Float32)
    transformation = move_point(transform.vector[],
        percent_from=transform.last_percent[], percent_to=percent)
    transform.last_percent[] = percent
    return transformation
end

#=
    END draw_animated_transforms interface for EuclidTextMoveTransform
=#


