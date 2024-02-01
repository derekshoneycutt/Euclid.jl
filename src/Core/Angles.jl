export EuclidSpaceAngle, EuclidSpaceAngle2f, EuclidSpaceAngle3f, EuclidAngleVector,
    EuclidSpaceAngleTransform, euclidean_angle, euclidean_angle_transform,
    compose, perform, lines, vector,
    changeradius_angle, changewidth_angle, changeopacity_angle, shiftcolor_angle,
    move_angle, arcmove_angle, rotate_angle, reflect, scale, shear

"""
    vector_angles(vector)

Get the 3D rotation angles of a vector

# Arguments:
- `vector::Point3f`: The vector to get angles for
"""
function vector_angles(vector::Point3f)
    θ = acos(vector[3] / norm(vector))
    θ = (vector[2] >= 0 ? 1 : -1) * (θ == 0f0 && vector[1] < 0 ? π : θ)
    ϕ = atan(vector[2], vector[1])

    (θ, ϕ)
end


"""
    EuclidSpaceAngle{N}

Describes an angle in Euclidean Space
"""
struct EuclidSpaceAngle{N}
    intersect::EuclidSpacePoint{N}
    vectorA::Point{N, Float32}
    vectorB::Point{N, Float32}

    angle::Float32

    radius::Float32
    width::Float32
    opacity::Float32
    color::RGB
end
EuclidSpaceAngle2f = EuclidSpaceAngle{2}
EuclidSpaceAngle3f = EuclidSpaceAngle{3}

"""
    EuclidAngleVector

Describes vectors for angle objects in Euclidean Space
"""
struct EuclidAngleVector{N}
    intersect::Point{N, Float32}
    vectorA::Point{N, Float32}
    vectorB::Point{N, Float32}
end

"""
    EuclidSpaceAngleTransform

Describes a transformation to take on a Euclid Space Angle
"""
struct EuclidSpaceAngleTransform
    intersect::Union{EuclidSpacePointTransform, Nothing}
    vectorA::Union{EuclidMatrixTransformation, Nothing}
    vectorB::Union{EuclidMatrixTransformation, Nothing}

    add_radius::Union{Float32, Nothing}
    add_width::Union{Float32, Nothing}
    add_opacity::Union{Float32, Nothing}
    shift_color::Union{Point3f, Nothing}
end


"""
    euclidean_angle(intersect, vectorA, vectorB[, radius=0f0, width=0f0, opacity=0f0, color=:blue])

Creates an object describing an angle in Euclidean Space

# Arguments
- `intersect`: The point of intersection at the center of the angle
- `vectorA`: The vector describing line A of the angle, as a vector from intersect
- `vectorB`: The vector describing line B of the angle, as a vector from intersect
- `radius::Float32`: The radius of the angle to describe
- `width::Float32`: The width of the angle to describe
- `opacity::Float32`: The opacity for the angle to show in
- `color`: The color for the angle to show in
"""
function euclidean_angle(intersect::EuclidSpacePoint2f, vectorA::Point2f, vectorB::Point2f;
        radius::Float32=0f0, width::Float32=0f0, opacity::Float32=0f0, color=:steelblue)
    A = Point2f(normalize(vectorA))
    B = Point2f(normalize(vectorB))

    θ = acos((A ⋅ B) / (norm(A) * norm(B)))

    EuclidSpaceAngle2f(intersect, A, B, θ, radius, width, opacity, get_color(color))
end
function euclidean_angle(intersect::EuclidSpacePoint3f, vectorA::Point3f, vectorB::Point3f;
        radius::Float32=0f0, width::Float32=0f0, opacity::Float32=0f0, color=:steelblue)
    A = Point3f(normalize(vectorA))
    B = Point3f(normalize(vectorB))

    θ = acos((A ⋅ B) / (norm(A) * norm(B)))

    EuclidSpaceAngle3f(intersect, A, B, θ, radius, width, opacity, get_color(color))
end
function euclidean_angle(orig::EuclidSpaceAngle2f;
        intersect::EuclidSpacePoint2f=orig.intersect, vectorA::Point2f=orig.vectorA,
        vectorB::Point2f=orig.vectorB, radius::Float32=orig.radius, width::Float32=orig.width,
        opacity::Float32=orig.opacity, color=orig.color)
    euclidean_angle(intersect, vectorA, vectorB, radius=radius, width=width,
        opacity=opacity, color=get_color(color))
end
function euclidean_angle(orig::EuclidSpaceAngle3f;
        intersect::EuclidSpacePoint3f=orig.intersect, vectorA::Point3f=orig.vectorA,
        vectorB::Point3f=orig.vectorB, radius::Float32=orig.radius, width::Float32=orig.width,
        opacity::Float32=orig.opacity, color=orig.color)
    euclidean_angle(intersect, vectorA, vectorB, radius=radius, width=width,
        opacity=opacity, color=get_color(color))
end

"""
    euclidean_angle_transform([intersect=nothing, vectorA=nothing, vectorB=nothing, add_radius=nothing, add_width=nothing, add_opacity=nothing, shift_color=nothing])

Create a new euclidean angle transformation

# Arguments
- `intersect`: The transformation to take on the intersection point
- `vectorA`: The transformation to take on vector A alone
- `vectorB`: The transformation to take on vector B alone
- `add_radius`: Magnitude to add to the radius value of the point
- `add_width`: Magnitude to add to the width value of the point
- `add_opacity`: Magnitude to add to the opacity value of the point
- `shift_color`: Vector representing a shift in the color (R, G, B)
"""
function euclidean_angle_transform(;
        intersect::Union{EuclidSpacePointTransform, Nothing}=nothing,
        vectorA::Union{EuclidMatrixTransformation, Nothing}=nothing,
        vectorB::Union{EuclidMatrixTransformation, Nothing}=nothing,
        add_radius::Union{Float32, Nothing}=nothing,
        add_width::Union{Float32, Nothing}=nothing,
        add_opacity::Union{Float32, Nothing}=nothing,
        shift_color::Union{Point3f, Nothing}=nothing)
    EuclidSpaceAngleTransform(intersect, vectorA, vectorB, add_radius, add_width,
        add_opacity, shift_color)
end

"""
    compose(t1, t2)

Compose 2 euclidean angle transformations into a single transformation

# Arguments
- `t1`: The first transformation to apply
- `t2`: The transformation to apply after the first is applied
"""
function compose(t1::EuclidSpaceAngleTransform, t2::EuclidSpaceAngleTransform)
    intersect = t1.intersect
    vectorA = t1.vectorA
    vectorB = t1.vectorB
    add_radius = t1.add_radius
    add_width = t1.add_width
    add_opacity = t1.add_opacity
    shift_color = t1.shift_color

    if intersect !== nothing
        if t2.intersect !== nothing
            intersect = compose(intersect, t2.intersect)
        end
    else
        intersect = t2.intersect
    end
    if vectorA !== nothing
        if t2.vectorA !== nothing
            vectorA = compose(vectorA, t2.vectorA)
        end
    else
        vectorA = t2.vectorA
    end
    if vectorB !== nothing
        if t2.vectorB !== nothing
            vectorB = compose(vectorB, t2.vectorB)
        end
    else
        vectorB = t2.vectorB
    end

    if add_radius !== nothing
        if t2.add_radius !== nothing
            add_radius = add_radius + t2.add_radius
        end
    else
        add_radius = t2.add_radius
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

    euclidean_angle_transform(intersect=intersect, vectorA=vectorA, vectorB=vectorB,
        add_radius=add_radius, add_width=add_width, add_opacity=add_opacity,
        shift_color=shift_color)
end


"""
    perform(angle, transform)

Get a new angle based on a previously defined transformation on a euclidean angle

# Arguments
- `angle`: The angle to perform the transformation on
- `transform`: The transformation to perform
"""
function perform(angle::EuclidSpaceAngle{2}, transform::EuclidSpaceAngleTransform)
    intersect = angle.intersect
    vectorA = angle.vectorA
    vectorB = angle.vectorB
    radius = angle.radius
    width = angle.width
    opacity = angle.opacity
    color = angle.color
    if transform.intersect !== nothing
        intersect = perform(intersect, transform.intersect)
    end
    if transform.vectorA !== nothing
        vectorA = Point2f(perform(vectorA, transform.vectorA))
    end
    if transform.vectorB !== nothing
        vectorB = Point2f(perform(vectorB, transform.vectorB))
    end
    if transform.add_radius !== nothing
        radius = radius + transform.add_radius
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
    euclidean_angle(intersect, vectorA, vectorB,
        radius=radius, width=width, opacity=opacity, color=color)
end
function perform(angle::EuclidSpaceAngle3f, transform::EuclidSpaceAngleTransform)
    intersect = angle.intersect
    vectorA = angle.vectorA
    vectorB = angle.vectorB
    radius = angle.radius
    width = angle.width
    opacity = angle.opacity
    color = angle.color
    if transform.intersect !== nothing
        intersect = perform(intersect, transform.intersect)
    end
    if transform.vectorA !== nothing
        vectorA = Point3f(perform(vectorA, transform.vectorA))
    end
    if transform.vectorB !== nothing
        vectorB = Point3f(perform(vectorB, transform.vectorB))
    end
    if transform.add_radius !== nothing
        radius = radius + transform.add_radius
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
    euclidean_angle(intersect, vectorA, vectorB,
        radius=radius, width=width, opacity=opacity, color=color)
end

"""
    lines(angle[, lengthA=1f0, lengthB=1f0, widthA=0f0, opacityA=0f0, colorA=:steelblue, widthB=0f0, opacityB=0f0, colorB=:khaki3])

Get lines described by an angle

# Arguments
- `angle`: The angle object to get lines for
- `lengthA`: The length of the line A to describe
- `lengthB`: The length of the line B to describe
- `widthA::Float32`: The width of the line A to describe
- `opacityA::Float32`: The opacity for the line A to show in
- `colorA`: The color for the line A to show in
- `widthB::Float32`: The width of the line B to describe
- `opacityB::Float32`: The opacity for the line B to show in
- `colorB`: The color for the line B to show in
"""
function lines(angle::EuclidSpaceAngle; lengthA::Float32=1f0, lengthB::Float32=1f0,
        widthA::Float32=0f0, opacityA::Float32=0f0, colorA=:steelblue,
        widthB::Float32=0f0, opacityB::Float32=0f0, colorB=:khaki3)
    return [
        euclidean_line(angle.intersect,
            euclidean_point(anlge.intersect,
                definition=(angle.intersect.definition + (angle.vectorA * lengthA))),
            width=widthA, opacity=opacityA, color=colorA),
        euclidean_line(angle.intersect,
            euclidean_point(anlge.intersect,
                definition=(angle.intersect.definition + (angle.vectorB * lengthB))),
            width=widthB, opacity=opacityB, color=colorB)
    ]
end

"""
    vector(source, target)

Gets a representation of a vector pointing from one angle intersection to another

# Arguments
- `souce`: The starting angle of the vector
- `target`: The target that the vector points to
"""
function vector(source::EuclidSpaceAngle2f, target::EuclidSpaceAngle2f)
    intvect = vector(source.intersect, target.intersect)
    vecA = target.vectorA - source.vectorA
    vecB = target.vectorB - source.vectorB
    EuclidAngleVector{2}(intvect, vecA, vecB)
end
function vector(source::EuclidSpaceAngle2f, target::Point2f)
    EuclidAngleVector{2}(vector(source.intersect, target), Point2f(0), Point2f(0))
end
function vector(source::EuclidSpaceAngle3f, target::EuclidSpaceAngle3f)
    intvect = vector(source.intersect, target.intersect)
    vecA = target.vectorA - source.vectorA
    vecB = target.vectorB - source.vectorB
    EuclidAngleVector{3}(intvect, vecA, vecB)
end
function vector(source::EuclidSpaceAngle3f, target::Point3f)
    EuclidAngleVector{3}(vector(source.intersect, target), Point3f(0), Point3f(0))
end

"""
    changeradius_angle(add_radius[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Angle to change the radius to some degree

# Arguments
- `add_radius::Float32`: The magnitude to change the radius
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changeradius_angle(add_radius::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_radius *  (percent_to - percent_from)
    euclidean_angle_transform(add_radius=move)
end

"""
    changewidth_angle(add_width[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Angle to change the size to some degree

# Arguments
- `add_width::Float32`: The magnitude to change the width
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changewidth_angle(add_width::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_width *  (percent_to - percent_from)
    euclidean_angle_transform(add_width=move)
end

"""
    changesize_angle(add_width, add_radius[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Angle to change the width and radius to some degree

# Arguments
- `add_width::Float32`: The magnitude to change the width
- `add_radius::Float32`: The magnitude to change the radius
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changesize_angle(add_width::Float32, add_radius::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    width = add_width *  (percent_to - percent_from)
    radius = add_radius *  (percent_to - percent_from)
    euclidean_angle_transform(add_width=width, add_radius=radius)
end

"""
    changeopacity_angle(add_opacity[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Angle to change the opacity to some degree

# Arguments
- `add_opacity::Float32`: The magnitude to change the opacity
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changeopacity_angle(add_opacity::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_opacity * (percent_to - percent_from)
    euclidean_angle_transform(add_opacity=move)
end

"""
    shiftcolor_angle(color_shift[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Angle to change the color by some color shift vector

# Arguments
- `color_shift::Point3f`: The vector representing the color shift to perform
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function shiftcolor_angle(color_shift::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = color_shift .* (percent_to - percent_from)
    euclidean_angle_transform(shift_color=move)
end

"""
    move_angle(vector[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Angle to move it along some vector

# Arguments
- `vector::Point`: The vector to move the angle along
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function move_angle(vector::Point2f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_angle_transform(
        intersect=move_point(vector, percent_from=percent_from, percent_to=percent_to))
end
function move_angle(vector::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_angle_transform(
        intersect=move_point(vector, percent_from=percent_from, percent_to=percent_to))
end

"""
    arcmove_angle(vector[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Angle to move it along some arc

# Arguments
- `center::Point`: The center point of the arc to move along
- `radians::Float32`: The radians to move about the arc
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function arcmove_angle(center::Point2f, radians::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_angle_transform(
        intersect=arcmove_point(center, radians, percent_from=percent_from, percent_to=percent_to))
end
function arcmove_angle(center::Point3f, radians::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_angle_transform(
        intersect=arcmove_point(center, radians, percent_from=percent_from, percent_to=percent_to))
end

"""
    rotate_angle(center, radians[, clockwise=false, percent_from=0f0, percent_to=1f0])
    rotate_angle(center, radians[, axis=:x, clockwise=false, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Angle to rotate it around some center point

# Arguments
- `center::Point`: The center point of the rotation
- `radians::Float32`: The radians to rotate
- `axis::Symbol`: For 3D, the axis to rotate about; must be :x, :y, or :z
- `clockwise::Bool`: Whether to rotate clockwise; default is false
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function rotate_angle(center::Point2f, radians::Float32;
        clockwise::Bool=false, percent_from::Float32=0f0, percent_to::Float32=1f0)
    clockwise_mod = clockwise ? -1 : 1
    θ = clockwise_mod * radians * (percent_to - percent_from)
    transform = rotation_matrix(θ)
    vectransform = euclidean_matrix_transform(firstadd=Vector{Float32}(-1 * center),
        mult_left=transform, thenadd=Vector{Float32}(center))
    inttransform = euclidean_point_transform(firstadd=Vector{Float32}(-1 * center),
        mult_left=transform, thenadd=Vector{Float32}(center))
    euclidean_angle_transform(intersect=inttransform,
        vectorA=vectransform, vectorB=vectransform)
end
function rotate_angle(center::Point3f, radians::Float32;
        axis::Symbol=:x, clockwise::Bool=false,
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D angles must be specified as :x, :y, or :z")
    end
    clockwise_mod = clockwise ? -1 : 1
    θ = clockwise_mod * radians * (percent_to - percent_from)
    transform = rotation_matrix(θ, axis=axis)
    vectransform = euclidean_matrix_transform(firstadd=Vector{Float32}(-1 * center),
        mult_left=transform, thenadd=Vector{Float32}(center))
    inttransform = euclidean_point_transform(firstadd=Vector{Float32}(-1 * center),
        mult_left=transform, thenadd=Vector{Float32}(center))
    euclidean_angle_transform(intersect=inttransform,
        vectorA=vectransform, vectorB=vectransform)
end

"""
    reflect(angle[, axis=:x, x_offset=0f0, y_offset=0f0])

Get a copy of a angle that is moved by reflecting it about an axis

# Arguments
- `angle::EuclidSpaceAngle`: The angle to get a reflection of
- `axis::Symbol`: The axis to reflect on; default is :x ; may be :x, :y, :diag, :negdiag, :origin
- 3D `axis` may be may be :xy, :yz, :xz, :diag, :negdiag, :altdiag, :origin
- `x_offset::Float32`: The offset of the reflection axis along the x-axis; default is 0f0
- `y_offset::Float32`: The offset of the reflection axis along the y-axis; default is 0f0
- `z_offset::Float32`: The offset of the reflection axis along the z-axis; default is 0f0
"""
function reflect(angle::EuclidSpaceAngle2f;
        axis::Symbol=:x, x_offset::Float32=0f0, y_offset::Float32=0f0)
    moved = reflect([angle.intersect.definition, angle.vectorA, angle.vectorB],
        axis=axis, x_offset=x_offset, y_offset=y_offset)
    movedint = euclidean_point(angle.interxect, definition=moved[1])
    movedA = moved[2]
    movedB = moved[3]
    euclidean_angle(angle, intersect=movedint, vectorA=movedA, vectorB=movedB)
end
function reflect(angle::EuclidSpaceAngle3f;
        axis::Symbol=:xy, x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    moved = reflect([angle.intersect.definition, angle.vectorA, angle.vectorB],
        axis=axis, x_offset=x_offset, y_offset=y_offset, z_offset=z_offset)
    movedint = euclidean_point(angle.interxect, definition=moved[1])
    movedA = moved[2]
    movedB = moved[3]
    euclidean_angle(angle, intersect=movedint, vectorA=movedA, vectorB=movedB)
end

"""
    scale(angle, factor[, factory=factor, factorz=factor])

Scale a angle according to given factors

# Arguments
- `angle::EuclidSpaceAngle` : The Angle to scale
- `factor::Float32`: The primary (x) factor to scale by
- `factory::Float32`: The y factor to scale by; defaults to the primary factor
- `factorz::Float32`: The z factor to scale by; defaults to the primary factor
"""
function scale(angle::EuclidSpaceAngle2f, factor::Float32;
        factory::Float32=factor)
    moved = scale([aangle.intersect.definition, angle.vectorA, angle.vectorB],
        factor, factory=factory)
    movedint = euclidean_point(angle.interxect, definition=moved[1])
    movedA = moved[2]
    movedB = moved[3]
    euclidean_angle(angle, intersect=movedint, vectorA=movedA, vectorB=movedB)
end
function scale(angle::EuclidSpaceAngle3f, factor::Float32;
        factory::Float32=factor, factorz::Float32=factor)
    moved = scale([angle.intersect.definition, angle.vectorA, angle.vectorB], factor,
        factory=factory, factorz=factorz)
    movedint = euclidean_point(angle.interxect, definition=moved[1])
    movedA = moved[2]
    movedB = moved[3]
    euclidean_angle(angle, intersect=movedint, vectorA=movedA, vectorB=movedB)
end

"""
    shear(angle, factor[, direction=:ytox])

Get a copy of a angle that is sheared by some factor in one direction

# Arguments
- `angle::EuclidSpaceAngle`: The angle to get a sheared copy of
- `factor`: The shearing factor to apply
- `direction`: The direction of shearing to apply; defaults :ytox ; can be :ytox, :xtoy, :ztox, :ztoy, :xtoz, :ytoz
"""
function shear(angle::EuclidSpaceAngle2f, factor::Float32; direction::Symbol=:ytox)
    moved = shear([angle.intersect.definition, angle.vectorA, angle.vectorB],factor,
        direction=direction)
    movedint = euclidean_point(angle.interxect, definition=moved[1])
    movedA = moved[2]
    movedB = moved[3]
    euclidean_angle(angle, intersect=movedint, vectorA=movedA, vectorB=movedB)
end
function shear(angle::EuclidSpaceAngle3f, factor::Float32; direction::Symbol=:ytox)
    moved = shear([angle.intersect.definition, angle.vectorA, angle.vectorB], factor,
        direction=direction)
    movedint = euclidean_point(angle.interxect, definition=moved[1])
    movedA = moved[2]
    movedB = moved[3]
    euclidean_angle(angle, intersect=movedint, vectorA=movedA, vectorB=movedB)
end



