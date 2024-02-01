export EuclidSpaceLine, EuclidSpaceLine2f, EuclidSpaceLine3f, euclidean_line, EuclidLineVector,
    EuclidSpaceLineTransform, EuclidSpaceLineDualTransform, euclidean_line_transform,
    compose, perform,
    extremities, extend, angle_from, vector,
    changewidth_line, changeopacity_line, shiftcolor_line, move_line, arcmove_line, rotate_line,
    reflect, scale, shear, intersection

"""
    EuclidSpaceLine{N}

Describes a line in Euclidean Space
"""
struct EuclidSpaceLine{N}
    extremityA::EuclidSpacePoint{N}
    extremityB::EuclidSpacePoint{N}

    slope::Vector{Float32}
    intercept::Vector{Float32}

    width::Float32
    opacity::Float32
    color::RGB
end
EuclidSpaceLine2f = EuclidSpaceLine{2}
EuclidSpaceLine3f = EuclidSpaceLine{3}

"""
    EuclidLineVector

Describes vectors from the two extremities of a line
"""
struct EuclidLineVector{N}
    vectorA::Point{N, Float32}
    vectorB::Point{N, Float32}
end

"""
    EuclidSpaceLineTransform

Describes a transformation to take on a Euclid Space Line
"""
struct EuclidSpaceLineTransform
    extremityA::Union{EuclidSpacePointTransform, Nothing}
    extremityB::Union{EuclidSpacePointTransform, Nothing}

    add_width::Union{Float32, Nothing}
    add_opacity::Union{Float32, Nothing}
    shift_color::Union{Point3f, Nothing}
end

"""
    EuclidSpaceLineDualTransform

Describes a transformation to take on a Euclid Space Line, based on a single point transformation
"""
struct EuclidSpaceLineDualTransform
    basedon::EuclidSpacePointTransform
end

"""
    euclidean_line(extremityA, extremityB[, width=0f0, opacity=0f0, color=:blue])

Creates an object describing a line in Euclidean Space

# Arguments
- `extremityA`: The primary extremity of the line to describe
- `extremityB`: The secondary extremity of the line to describe
- `width::Float32`: The width of the line to describe
- `opacity::Float32`: The opacity for the line to show in
- `color`: The color for the line to show in
"""
function euclidean_line(
        extremityA::EuclidSpacePoint2f, extremityB::EuclidSpacePoint2f;
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    m = (extremityB.definition[2] - extremityA.definition[2]) /
        (extremityB.definition[1] - extremityA.definition[1])
    b = extremityA.definition[2] - m * extremityA.definition[1]

    EuclidSpaceLine2f(extremityA, extremityB, [m], [b],
        width, opacity, get_color(color))
end
function euclidean_line(
        extremityA::EuclidSpacePoint3f, extremityB::EuclidSpacePoint3f;
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    v = extremityB.definition - extremityA.definition

    EuclidSpaceLine3f(extremityA, extremityB, v, extremityA.definition,
        width, opacity, get_color(color))
end
function euclidean_line(
        extremityA::Point2f, extremityB::Point2f;
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    euclidean_line(euclidean_point(extremityA), euclidean_point(extremityB),
        width=width, opacity=opacity, color=color)
end
function euclidean_line(
        extremityA::EuclidSpacePoint2f, extremityB::Point2f;
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    euclidean_line(extremityA, euclidean_point(extremityB),
        width=width, opacity=opacity, color=color)
end
function euclidean_line(
        extremityA::Point2f, extremityB::EuclidSpacePoint2f;
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    euclidean_line(euclidean_point(extremityA), extremityB,
        width=width, opacity=opacity, color=color)
end
function euclidean_line(
        extremityA::Point3f, extremityB::Point3f;
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    euclidean_line(euclidean_point(extremityA), euclidean_point(extremityB),
        width=width, opacity=opacity, color=color)
end
function euclidean_line(
        extremityA::EuclidSpacePoint3f, extremityB::Point3f;
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    euclidean_line(extremityA, euclidean_point(extremityB),
        width=width, opacity=opacity, color=color)
end
function euclidean_line(
        extremityA::Point3f, extremityB::EuclidSpacePoint3f;
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    euclidean_line(euclidean_point(extremityA), extremityB,
        width=width, opacity=opacity, color=color)
end
function euclidean_line(orig::EuclidSpaceLine2f;
        extremityA::EuclidSpacePoint2f=orig.extremityA,
        extremityB::EuclidSpacePoint2f=orig.extremityB,
        width::Float32=orig.width, opacity::Float32=orig.opacity,
        color=orig.color)
    euclidean_line(extremityA, extremityB, width=width, opacity=opacity, color=color)
end
function euclidean_line(orig::EuclidSpaceLine3f;
        extremityA::EuclidSpacePoint3f=orig.extremityA,
        extremityB::EuclidSpacePoint3f=orig.extremityB,
        width::Float32=orig.width, opacity::Float32=orig.opacity,
        color=orig.color)
    euclidean_line(extremityA, extremityB, width=width, opacity=opacity, color=color)
end

"""
    euclidean_line_transform([extremityA=nothing, extremityB=nothing, add_width=nothing, add_opacity=nothing, shift_color=nothing])
    euclidean_line_transform(transform)

Create a new euclidean line transformation

# Arguments
- `extremityA`: The transformation to take on extremity A
- `extremityB`: The transformation to take on extremity B
- `add_width`: Magnitude to add to the width value of the point
- `add_opacity`: Magnitude to add to the opacity value of the point
- `shift_color`: Vector representing a shift in the color (R, G, B)
- `transform::EuclidSpacePointTransform`: Point transformation to take on both extremities
"""
function euclidean_line_transform(;
        extremityA::Union{EuclidSpacePointTransform, Nothing}=nothing,
        extremityB::Union{EuclidSpacePointTransform, Nothing}=nothing,
        add_width::Union{Float32, Nothing}=nothing,
        add_opacity::Union{Float32, Nothing}=nothing,
        shift_color::Union{Point3f, Nothing}=nothing)
    EuclidSpaceLineTransform(extremityA, extremityB, add_width, add_opacity, shift_color)
end
function euclidean_line_transform(transform::EuclidSpacePointTransform)
    EuclidSpaceLineDualTransform(transform)
end

"""
    compose(t1, t2)

Compose 2 euclidean line transformations into a single transformation

# Arguments
- `t1`: The first transformation to apply
- `t2`: The transformation to apply after the first is applied
"""
function compose(t1::EuclidSpaceLineTransform, t2::EuclidSpaceLineTransform)
    extremityA = t1.extremityA
    extremityB = t1.extremityB
    add_width = t1.add_width
    add_opacity = t1.add_opacity
    shift_color = t1.shift_color

    if extremityA !== nothing
        if t2.extremityA !== nothing
            extremityA = compose(extremityA, t2.extremityA)
        end
    else
        extremityA = t2.extremityA
    end
    if extremityB !== nothing
        if t2.extremityB !== nothing
            extremityB = compose(extremityB, t2.extremityB)
        end
    else
        extremityB = t2.extremityB
    end

    if add_width !== nothing
        if t2.add_width !== nothing
            add_width = add_width + t2.add_width
        end
    else
        add_width = t2.add_width
    end
    if add_opacity !== nothing
        if t2.add_opacity !== nothing
            add_opacity = add_opacity + t2.add_opacity
        end
    else
        add_opacity = t2.add_opacity
    end
    if shift_color !== nothing
        if t2.shift_color !== nothing
            shift_color = shift_color + t2.shift_color
        end
    else
        shift_color = t2.shift_color
    end

    euclidean_line_transform(extremityA=extremityA, extremityB = extremityB,
        add_width=add_width, add_opacity=add_opacity,
        shift_color=shift_color)
end
function compose(t1::EuclidSpaceLineDualTransform, t2::EuclidSpaceLineDualTransform)
    euclidean_line_transform(compose(t1.basedon, t2.basedon))
end

"""
    perform(line, transform)

Get a new line based on a previously defined transformation on a euclidean line

# Arguments
- `line`: The line to perform the transformation on
- `transform`: The transformation to perform
"""
function perform(line::EuclidSpaceLine2f, transform::EuclidSpaceLineTransform)
    transformedA = line.extremityA
    transformedB = line.extremityB
    width = line.width
    opacity = line.opacity
    color = line.color
    if transform.extremityA !== nothing
        transformedA = perform(transformedA, transform.extremityA)
    end
    if transform.extremityB !== nothing
        transformedB = perform(transformedB, transform.extremityB)
    end
    if transform.add_width !== nothing
        width = width + transform.add_width
    end
    if transform.add_opacity !== nothing
        opacity = opacity + transform.add_opacity
    end
    if transform.shift_color !== nothing
        color = shift_color(color, transform.shift_color)
    end
    euclidean_line(transformedA, transformedB,
        width=width, opacity=opacity, color=color)
end
function perform(line::EuclidSpaceLine2f, transform::EuclidSpaceLineDualTransform)
    transformed = [line.extremityA.definition line.extremityB.definition]
    if transform.basedon.mult_left !== nothing
        transformed = transform.basedon.mult_left * transformed
    end
    if transform.basedon.mult_right !== nothing
        transformed = transformed * transform.basedon.mult_right
    end
    if transform.basedon.add_after !== nothing
        transformed = transformed + [transform.basedon.add_after transform.basedon.add_after]
    end
    transformedA = euclidean_point(line.extremityA, definition=Point2f(transformed[:,1]))
    transformedB = euclidean_point(line.extremityA, definition=Point2f(transformed[:,2]))

    width = line.width
    opacity = line.opacity
    color = line.color
    if transform.basedon.add_size !== nothing
        width = width + transform.basedon.add_size
    end
    if transform.basedon.add_opacity !== nothing
        opacity = opacity + transform.basedon.add_opacity
    end
    if transform.basedon.shift_color !== nothing
        color = shift_color(color, transform.basedon.shift_color)
    end
    euclidean_line(transformedA, transformedB,
        width=width, opacity=opacity, color=color)
end
function perform(line::EuclidSpaceLine3f, transform::EuclidSpaceLineTransform)
    transformedA = line.extremityA
    transformedB = line.extremityB
    width = line.width
    opacity = line.opacity
    color = line.color
    if transform.extremityA !== nothing
        transformedA = perform(transformedA, transform.extremityA)
    end
    if transform.extremityB !== nothing
        transformedB = perform(transformedB, transform.extremityB)
    end
    if transform.add_width !== nothing
        width = width + transform.add_width
    end
    if transform.add_opacity !== nothing
        opacity = opacity + transform.add_opacity
    end
    if transform.shift_color !== nothing
        color = shift_color(color, transform.shift_color)
    end
    euclidean_line(transformedA, transformedB,
        width=width, opacity=opacity, color=color)
end
function perform(line::EuclidSpaceLine3f, transform::EuclidSpaceLineDualTransform)
    transformed = [line.extremityA.definition line.extremityB.definition]
    if transform.basedon.mult_left !== nothing
        transformed = transform.basedon.mult_left * transformed
    end
    if transform.basedon.mult_right !== nothing
        transformed = transformed * transform.basedon.mult_right
    end
    if transform.basedon.add_after !== nothing
        transformed = transformed + [transform.basedon.add_after transform.basedon.add_after]
    end
    transformedA = euclidean_point(line.extremityA, definition=Point3f(transformed[:,1]))
    transformedB = euclidean_point(line.extremityA, definition=Point3f(transformed[:,2]))

    width = line.width
    opacity = line.opacity
    color = line.color
    if transform.basedon.add_size !== nothing
        width = width + transform.basedon.add_size
    end
    if transform.basedon.add_opacity !== nothing
        opacity = opacity + transform.basedon.add_opacity
    end
    if transform.basedon.shift_color !== nothing
        color = shift_color(color, transform.basedon.shift_color)
    end
    euclidean_line(transformedA, transformedB,
        width=width, opacity=opacity, color=color)
end

"""
    extremities(line)

Get new points representing the extremities of a line. Defaults to direct copies of the definition from the line.

returns a tuple of 2 EuclidSpacePoint representing the extremities

# Arguments
- `line::EuclidSpaceLine`: The line to get the extremities of
"""
function extremities(line::EuclidSpaceLine)
    (
        euclidean_point(line.extremityA),
        euclidean_point(line.extremityB)
    )
end

"""
    extend(line, distance[, fromextremity=:A])

Get a copy of the line extended out, starting from one extremity and going through the other when positive

# Arguments
- `line::EuclidSpaceLine`: The line to extend
- `distance::Float32`: The distance from the origin extremity to extend, in the direction of the other extremity
- `fromextremity::Symbol`: The extremity to start at; default is :A ; accepts :A or :B
"""
function extend(line::EuclidSpaceLine, distance::Float32;
        fromextremity::Symbol=:A)
    if fromextremity == :A
        v = line.extremityB - line.extremityA
        norm_v = norm(v)
        u = v / norm_v
        euclidean_line(line.extremityA, line.extremityA + distance * u, width=line.width)
    elseif fromextremity == :B
        v = line.extremityA - line.extremityB
        norm_v = norm(v)
        u = v / norm_v
        euclidean_line(line.extremityB + distance * u, line.extremityB, width=line.width)
    else
        throw("Unrecognized fromextremity; expecting :A or :B")
    end
end

"""
    angle_from(line[, direction=:AtoB])

Gets an angle that a line is in

# Arguments
- `line::EuclidSpaceLine`: The line to get the angle from
- `direction::Symbol`: The direction of the line to get the angle; :AtoB or :BtoA
"""
function angle_from(
        line::EuclidSpaceLine2f;
        direction::Symbol=:AtoB)
    if direction == :BtoA
        angle_from(line.extremityA, line.extremityB)
    elseif direction == :AtoB
        angle_from(line.extremityB, line.extremityA)
    else
        throw("Unrecognized symbol; expected :BtoA or :AtoB")
    end
end

"""
    vector(source, target)

Gets a representation on vectors pointing from the extremities of line source to line target

# Arguments
- `souce`: The starting line of the vector
- `target`: The target that the vector points to
"""
function vector(source::EuclidSpaceLine2f, target::EuclidSpaceLine2f)
    EuclidLineVector{2}(vector(source.extremityA, target.extremityA),
        vector(source.extremityB, target.extremityB))
end
function vector(source::EuclidSpaceLine3f, target::EuclidSpaceLine3f)
    EuclidLineVector{3}(vector(source.extremityA, target.extremityA),
        vector(source.extremityB, target.extremityB))
end

"""
    changewidth_line(add_width[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the size to some degree

# Arguments
- `add_width::Float32`: The magnitude to change the width
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changewidth_line(add_width::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_width *  (percent_to - percent_from)
    euclidean_line_transform(add_width=move)
end

"""
    changeopacity_line(add_opacity[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the opacity to some degree

# Arguments
- `add_opacity::Float32`: The magnitude to change the opacity
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changeopacity_line(add_opacity::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_opacity * (percent_to - percent_from)
    euclidean_line_transform(add_opacity=move)
end

"""
    shiftcolor_line(color_shift[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the color by some color shift vector

# Arguments
- `color_shift::Point3f`: The vector representing the color shift to perform
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function shiftcolor_line(color_shift::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = color_shift .* (percent_to - percent_from)
    euclidean_line_transform(shift_color=move)
end

"""
    move_line(vector[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to move it along some vector

# Arguments
- `vector`: The vector to move the line along
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function move_line(vector::Point2f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        move_point(vector, percent_from=percent_from, percent_to=percent_to))
end
function move_line(vector::EuclidLineVector{2};
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=move_point(vector.vectorA, percent_from=percent_from, percent_to=percent_to),
        extremityB=move_point(vector.vectorB, percent_from=percent_from, percent_to=percent_to))
end
function move_line(vector::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        move_point(vector, percent_from=percent_from, percent_to=percent_to))
end
function move_line(vector::EuclidLineVector{3};
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=move_point(vector.vectorA, percent_from=percent_from, percent_to=percent_to),
        extremityB=move_point(vector.vectorB, percent_from=percent_from, percent_to=percent_to))
end

"""
    arcmove_line(centerA, radiansA, centerB, radiansB[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to move it along arc paths

Note: This moves each point independently with separate center points and radians.
To statically move the line, keeping it the same size, will need to do the math for the steps.

# Arguments
- `centerA::Point`: The center point of the rotation for extremity A
- `radiansA::Float32`: The radians to move about the arc for extremity A
- `centerB::Point`: The center point of the rotation for extremity B
- `radiansB::Float32`: The radians to move about the arc for extremity B
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function arcmove_line(centerA::Point2f, radiansA::Float32, centerB::Point2f, radiansB::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=arcmove_point(centerA, radiansA,
            percent_from=percent_from, percent_to=percent_to),
        extremityB=arcmove_point(centerB, radiansB,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_line(centerA::EuclidSpacePoint2f, radiansA::Float32,
        centerB::EuclidSpacePoint2f, radiansB::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=arcmove_point(centerA, radiansA,
            percent_from=percent_from, percent_to=percent_to),
        extremityB=arcmove_point(centerB, radiansB,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_line(centerA::Point2f, radiansA::Float32,
        centerB::EuclidSpacePoint2f, radiansB::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=arcmove_point(centerA, radiansA,
            percent_from=percent_from, percent_to=percent_to),
        extremityB=arcmove_point(centerB, radiansB,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_line(centerA::EuclidSpacePoint2f, radiansA::Float32,
        centerB::Point2f, radiansB::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=arcmove_point(centerA, radiansA,
            percent_from=percent_from, percent_to=percent_to),
        extremityB=arcmove_point(centerB, radiansB,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_line(centerA::Point3f, radiansA::Float32, centerB::Point3f, radiansB::Float32;
        axis::Symbol=:x, percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=arcmove_point(centerA, radiansA, axis=axis,
            percent_from=percent_from, percent_to=percent_to),
        extremityB=arcmove_point(centerB, radiansB, axis=axis,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_line(centerA::EuclidSpacePoint3f, radiansA::Float32,
        centerB::EuclidSpacePoint3f, radiansB::Float32;
        axis::Symbol=:x, percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=arcmove_point(centerA, radiansA, axis=axis,
            percent_from=percent_from, percent_to=percent_to),
        extremityB=arcmove_point(centerB, radiansB,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_line(centerA::Point3f, radiansA::Float32,
        centerB::EuclidSpacePoint3f, radiansB::Float32;
        axis::Symbol=:x, percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=arcmove_point(centerA, radiansA, axis=axis,
            percent_from=percent_from, percent_to=percent_to),
        extremityB=arcmove_point(centerB, radiansB,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_line(centerA::EuclidSpacePoint3f, radiansA::Float32,
        centerB::Point3f, radiansB::Float32;
        axis::Symbol=:x, percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_line_transform(
        extremityA=arcmove_point(centerA, radiansA, axis=axis,
            percent_from=percent_from, percent_to=percent_to),
        extremityB=arcmove_point(centerB, radiansB,
            percent_from=percent_from, percent_to=percent_to))
end

"""
    rotate_line(center, radians[, clockwise=false, percent_from=0f0, percent_to=1f0])
    rotate_line(center, radians[, axis=:x, clockwise=false, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to rotate it around some center point

# Arguments
- `center::Point`: The center point of the rotation
- `radians::Float32`: The radians to rotate
- `axis::Symbol`: For 3D, the axis to rotate about; must be :x, :y, or :z
- `clockwise::Bool`: Whether to rotate clockwise; default is false
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function rotate_line(center::Point2f, radians::Float32;
        clockwise::Bool=false, percent_from::Float32=0f0, percent_to::Float32=1f0)
    clockwise_mod = clockwise ? -1 : 1
    euclidean_line_transform(arcmove_point(center, radians * clockwise_mod,
            percent_from=percent_from, percent_to=percent_to))
end
function rotate_line(center::EuclidSpacePoint2f, radians::Float32;
        clockwise::Bool=false, percent_from::Float32=0f0, percent_to::Float32=1f0)
    clockwise_mod = clockwise ? -1 : 1
    euclidean_line_transform(arcmove_point(center, radians * clockwise_mod,
            percent_from=percent_from, percent_to=percent_to))
end
function rotate_line(center::Point3f, radians::Float32;
        axis::Symbol=:x, clockwise::Bool=false,
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    clockwise_mod = clockwise ? -1 : 1
    euclidean_line_transform(arcmove_point(center, radians * clockwise_mod,
            axis=axis, percent_from=percent_from, percent_to=percent_to))
end
function rotate_line(center::EuclidSpacePoint3f, radians::Float32;
        axis::Symbol=:x, clockwise::Bool=false,
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    clockwise_mod = clockwise ? -1 : 1
    euclidean_line_transform(arcmove_point(center, radians * clockwise_mod,
            axis=axis, percent_from=percent_from, percent_to=percent_to))
end

"""
    reflect(line[, axis=:x, x_offset=0f0, y_offset=0f0])

Get a copy of a line that is moved by reflecting it about an axis

# Arguments
- `line::EuclidSpaceLine`: The line to get a reflection of
- `axis::Symbol`: The axis to reflect on; default is :x ; may be :x, :y, :diag, :negdiag, :origin
- 3D `axis` may be may be :xy, :yz, :xz, :diag, :negdiag, :altdiag, :origin
- `x_offset::Float32`: The offset of the reflection axis along the x-axis; default is 0f0
- `y_offset::Float32`: The offset of the reflection axis along the y-axis; default is 0f0
- `z_offset::Float32`: The offset of the reflection axis along the z-axis; default is 0f0
"""
function reflect(line::EuclidSpaceLine2f;
        axis::Symbol=:x, x_offset::Float32=0f0, y_offset::Float32=0f0)
    moved = reflect([line.extremityA.definition, line.extremityB.definition],
        axis=axis, x_offset=x_offset, y_offset=y_offset)
    movedA = euclidean_point(line.extremityA, definition=moved[1])
    movedB = euclidean_point(line.extremityB, definition=moved[2])
    euclidean_line(line, extremityA=movedA, extremityB=movedB)
end
function reflect(line::EuclidSpaceLine3f;
        axis::Symbol=:xy, x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    moved = reflect([line.extremityA.definition, line.extremityB.definition],
        axis=axis, x_offset=x_offset, y_offset=y_offset, z_offset=z_offset)
    movedA = euclidean_point(line.extremityA, definition=moved[1])
    movedB = euclidean_point(line.extremityB, definition=moved[2])
    euclidean_line(line, extremityA=movedA, extremityB=movedB)
end

"""
    scale(line, factor[, factory=factor, factorz=factor])

Scale a line according to given factors

# Arguments
- `line::EuclidSpaceLine` : The Line to scale
- `factor::Float32`: The primary (x) factor to scale by
- `factory::Float32`: The y factor to scale by; defaults to the primary factor
- `factorz::Float32`: The z factor to scale by; defaults to the primary factor
"""
function scale(line::EuclidSpaceLine2f, factor::Float32;
        factory::Float32=factor)
    moved = scale([line.extremityA.definition, line.extremityB.definition],
        factor, factory=factory)
    movedA = euclidean_point(line.extremityA, definition=moved[1])
    movedB = euclidean_point(line.extremityB, definition=moved[2])
    euclidean_line(line, extremityA=movedA, extremityB=movedB)
end
function scale(line::EuclidSpaceLine3f, factor::Float32;
        factory::Float32=factor, factorz::Float32=factor)
    moved = scale([line.extremityA.definition, line.extremityB.definition], factor,
        factory=factory, factorz=factorz)
    movedA = euclidean_point(line.extremityA, definition=moved[1])
    movedB = euclidean_point(line.extremityB, definition=moved[2])
    euclidean_line(line, extremityA=movedA, extremityB=movedB)
end

"""
    shear(line, factor[, direction=:ytox])

Get a copy of a line that is sheared by some factor in one direction

# Arguments
- `line::EuclidSpaceLine`: The line to get a sheared copy of
- `factor`: The shearing factor to apply
- `direction`: The direction of shearing to apply; defaults :ytox ; can be :ytox, :xtoy, :ztox, :ztoy, :xtoz, :ytoz
"""
function shear(line::EuclidSpaceLine2f, factor::Float32; direction::Symbol=:ytox)
    moved = shear([line.extremityA.definition, line.extremityB.definition], factor,
        direction=direction)
    movedA = euclidean_point(line.extremityA, definition=moved[1])
    movedB = euclidean_point(line.extremityB, definition=moved[2])
    euclidean_line(line, extremityA=movedA, extremityB=movedB)
end
function shear(line::EuclidSpaceLine3f, factor::Float32; direction::Symbol=:ytox)
    moved = shear([line.extremityA.definition, line.extremityB.definition], factor,
        direction=direction)
    movedA = euclidean_point(line.extremityA, definition=moved[1])
    movedB = euclidean_point(line.extremityB, definition=moved[2])
    euclidean_line(line, extremityA=movedA, extremityB=movedB)
end

"""
    intersection(line1, line2[, size=0f0])

Get a point where 2 lines intersect; may be an infinite point if lines are parallel--use is_infinite

# Arguments
- `line1::EuclidSpaceLine`: The first line
- `line2::EuclidSpaceLine`: The second line
- `size::Float32`: The size of the intersecting point; defaults to 0f0
- `opacity::Float32`: The opacity for the intersecting point to show in
- `color`: The color for the intersecting point to show in
"""
function intersection(
        line1::EuclidSpaceLine2f, line2::EuclidSpaceLine2f;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    m1 = line1.slope[1]
    m2 = line2.slope[1]
    b1 = line1.intercept[1]
    b2 = line2.intercept[1]

    x = (b1 - b2) / (m2 - m1)
    y = m1 * x + b1

    euclidean_point(x, y, size=size, opacity=opacity, color=color)
end
function intersection(
        line1::EuclidSpaceLine3f, line2::EuclidSpaceLine3f;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    v_a = line1.extremityB.definition - line1.extremityA.definition
    v_b = line2.extremityB.definition - line2.extremityA.definition
    v_c = line2.extremityA.definition - line1.extremityA.definition

    a_cross_b = v_a × v_b
    squarenorm = norm(a_cross_b)^2
    check_intersect = v_c ⋅ a_cross_b
    c_cross_b = v_c × v_b
    possible = check_intersect != 0f0 && squarenorm != 0f0 ? Inf : (c_cross_b ⋅ a_cross_b) / squarenorm

    intersection = Point3f(line1.extremityA.definition + (v_a .* possible))

    euclidean_point(intersection, size=size, opacity=opacity, color=color)
end
