export EuclidSpacePoint, EuclidSpacePoint2f, EuclidSpacePoint3f, EuclidSpacePointTransform,
    euclidean_point, euclidean_point_transform,
    compose, perform,
    is_infinite, angle_from, vector,
    changesize_point, changeopacity_point, shiftcolor_point, move_point, arcmove_point,
    reflect, scale, shear

"""
    EuclidSpacePoint{N}

Describes a point associated to some size value in Euclidean Space
"""
struct EuclidSpacePoint{N}
    definition::Point{N, Float32}

    size::Float32
    opacity::Float32
    color::RGB
end
EuclidSpacePoint2f = EuclidSpacePoint{2}
EuclidSpacePoint3f = EuclidSpacePoint{3}

"""
    EuclidSpacePointTransform

Describes a transformation to take on a Euclid Space Point
"""
struct EuclidSpacePointTransform
    matrix::EuclidMatrixTransformation

    add_size::Union{Float32, Nothing}
    add_opacity::Union{Float32, Nothing}
    shift_color::Union{Point3f, Nothing}
end

"""
    euclidean_point(x, y[, size=0f0, opacity=0f0, color=:blue])
    euclidean_point(x, y, z[, size=0f0, opacity=0f0, color=:blue])
    euclidean_point(point[, size=0f0, opacity=0f0, color=:blue])

Shorthand for defining a euclidean point in space

# Arguments
- `x::Float32`: The X coordinate of the point
- `y::Float32`: The Y coordinate of the point
- `z::Float32`: The Z coordinate of the point
- `point::Point`: The point to create a euclidean point from
- `orig::EuclidSpacePoint`: The original point to copy into a new point
- `size::Float32`: The size for the point to take up in space
- `opacity::Float32`: The opacity for the point to show in
- `color`: The color for the point to show in
"""
function euclidean_point(x::Float32, y::Float32;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    EuclidSpacePoint2f(Point2f0(x, y), size, opacity, get_color(color))
end
function euclidean_point(x::Float32, y::Float32, z::Float32;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    EuclidSpacePoint3f(Point3f0(x, y, z), size, opacity, get_color(color))
end
function euclidean_point(point::Point2f;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    EuclidSpacePoint2f(point, size, opacity, get_color(color))
end
function euclidean_point(point::Point3f;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    EuclidSpacePoint3f(point, size, opacity, get_color(color))
end
function euclidean_point(orig::EuclidSpacePoint2f;
        definition::Point2f=orig.definition, size::Float32=orig.size,
        opacity::Float32=orig.opacity, color=orig.color)
    EuclidSpacePoint2f(definition, size, opacity, get_color(color))
end
function euclidean_point(orig::EuclidSpacePoint3f;
        definition::Point3f=orig.definition, size::Float32=orig.size,
        opacity::Float32=orig.opacity, color=orig.color)
    EuclidSpacePoint3f(definition, size, opacity, get_color(color))
end

"""
    euclidean_point_transform([firstadd=nothing, mult_left=nothing, mult_right=nothing, thenadd=nothing, add_size=nothing, add_opacity=nothing, shift_color=nothing]

Create a new euclidean point transformation

# Arguments
- `firstadd` : Vector to add at the beginning of the transformation
- `mult_left`: Transformation matrix to mulitply on the left side
- `mult_right`: Transformation matrix to multiply on the right side
- `thenadd`: Vector to add at the end of the transformation
- `add_size`: Magnitude to add to the size value of the point
- `add_opacity`: Magnitude to add to the opacity value of the point
- `shift_color`: Vector representing a shift in the color (R, G, B)
"""
function euclidean_point_transform(;
        firstadd::Union{Vector{Float32}, Nothing}=nothing,
        mult_left::Union{Matrix{Float32}, Nothing}=nothing,
        mult_right::Union{Matrix{Float32}, Nothing}=nothing,
        thenadd::Union{Vector{Float32}, Nothing}=nothing,
        add_size::Union{Float32, Nothing}=nothing,
        add_opacity::Union{Float32, Nothing}=nothing,
        shift_color::Union{Point3f, Nothing}=nothing)

    EuclidSpacePointTransform(
        euclidean_matrix_transform(firstadd=firstadd, mult_left=mult_left, mult_right=mult_right, thenadd=thenadd),
        add_size, add_opacity, shift_color)
end

"""
    compose(t1, t2)

Compose 2 euclidean point transformations into a single transformation

# Arguments
- `t1`: The first transformation to apply
- `t2`: The transformation to apply after the first is applied
"""
function compose(t1::EuclidSpacePointTransform, t2::EuclidSpacePointTransform)
    matrix = t1.matrix
    add_size = t1.add_size
    add_opacity = t1.add_opacity
    shift_color = t1.shift_color

    if matrix !== nothing
        if t2.matrix !== nothing
            matrix = compose(matrix, t2.matrix)
        end
    else
        matrix = t2.matrix
    end

    if add_size !== nothing
        if t2.add_size !== nothing
            add_size = add_size + t2.add_size
        end
    else
        add_size = t2.add_size
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

    euclidean_point_transform(mult_left=matrix.mult_left, mult_right=matrix.mult_right,
        thenadd=matrix.add_after, add_size=add_size, add_opacity=add_opacity,
        shift_color=shift_color)
end

"""
    perform(point, transform)

Get a new point based on a previously defined transformation on a euclidean point

# Arguments
- `transform`: The transformation to perform
"""
function perform(point::EuclidSpacePoint2f, transform::EuclidSpacePointTransform)
    transformed = point.definition
    size = point.size
    opacity = point.opacity
    color = point.color
    if transform.matrix !== nothing
        transformed = Point2f(perform(Vector{Float32}(transformed), transform.matrix))
    end
    if transform.add_size !== nothing
        size = size + transform.add_size
    end
    if transform.add_opacity !== nothing
        opacity = opacity + transform.add_opacity
    end
    if transform.shift_color !== nothing
        color = shift_color(color, transform.shift_color)
    end
    euclidean_point(transformed, size=size, opacity=opacity, color=color)
end
function perform(point::EuclidSpacePoint3f, transform::EuclidSpacePointTransform)
    transformed = point.definition
    size = point.size
    opacity = point.opacity
    color = point.color
    if transform.matrix !== nothing
        transformed = Point3f(perform(Vector{Float32}(transformed), transform.matrix))
    end
    if transform.add_size !== nothing
        size = size + transform.add_size
    end
    if transform.add_opacity !== nothing
        opacity = opacity + transform.add_opacity
    end
    if transform.shift_color !== nothing
        color = shift_color(color, transform.shift_color)
    end
    euclidean_point(transformed, size=size, opacity=opacity, color=color)
end

"""
    is_infinite(point)

Returns if a point contains an undefined/Inf dimension

# Arguments
- `point::EuclidSpacePoint` : The point to test if it has any Infs
"""
function is_infinite(point::EuclidSpacePoint)
    findfirst(f -> f == Inf, point.definition) !== nothing
end

"""
    angle_from(point, center)

Gets the angle, in radians, that one point is from another in Euclidean space

# Arguments
- `point::Point/EuclidSpacePoint`: The point to get the angle for
- `center::Point/EuclidSpacePoint`: The center point to get the angle from
"""
function angle_from(
        point::Point2f, center::Point2f)
    vec = point - center
    θ = atan(vec[2], vec[1])

    θ
end
function angle_from(
        point::Point3f, center::Point3f)
    vec = point - center
    θ = atan(vec[2], vec[1])
    ϕ = acos(vec[3] / norm(vec))

    (θ, ϕ)
end
function angle_from(
        point::EuclidSpacePoint2f, center::Point2f)
    angle_from(point.definition, center)
end
function angle_from(
        point::Point2f, center::EuclidSpacePoint2f)
    angle_from(point.definition, center)
end
function angle_from(
        point::EuclidSpacePoint2f, center::EuclidSpacePoint2f)
    angle_from(point.definition, center.definition)
end
function angle_from(
        point::EuclidSpacePoint3f, center::Point3f)
    angle_from(point.definition, center)
end
function angle_from(
        point::Point3f, center::EuclidSpacePoint3f)
    angle_from(point, center.definition)
end
function angle_from(
        point::EuclidSpacePoint3f, center::EuclidSpacePoint3f)
    angle_from(point.definition, center.definition)
end

"""
    vector(center, target)

Get a vector from 2 points. Returns Point2f

# Arguments
- `center`: The starting point of the vector
- `target`: The target that the vector points to
"""
function vector(center::EuclidSpacePoint2f, target::EuclidSpacePoint2f)
    Point2f(target.definition - center.definition)
end
function vector(center::EuclidSpacePoint2f, target::Point2f)
    Point2f(target - center.definition)
end
function vector(center::Point2f, target::EuclidSpacePoint2f)
    Point2f(target.definition - center)
end
function vector(center::Point2f, target::Point2f)
    Point2f(target - center)
end
function vector(center::EuclidSpacePoint3f, target::EuclidSpacePoint3f)
    Point3f(target.definition - center.definition)
end
function vector(center::EuclidSpacePoint3f, target::Point3f)
    Point3f(target - center.definition)
end
function vector(center::Point3f, target::EuclidSpacePoint3f)
    Point3f(target.definition - center)
end
function vector(center::Point3f, target::Point3f)
    Point3f(target - center)
end

"""
    changesize_point(add_size[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Point to change the size to some degree

# Arguments
- `add_size::Float32`: The magnitude to change the size
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changesize_point(add_size::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_size *  (percent_to - percent_from)
    euclidean_point_transform(add_size=move)
end

"""
    changeopacity_point(add_opacity[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Point to change the opacity to some degree

# Arguments
- `add_opacity::Float32`: The magnitude to change the opacity
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changeopacity_point(add_opacity::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_opacity * (percent_to - percent_from)
    euclidean_point_transform(add_opacity=move)
end

"""
    shiftcolor_point(add_opacity[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Point to change the color by some color shift vector

# Arguments
- `color_shift::Point3f`: The vector representing the color shift to perform
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function shiftcolor_point(color_shift::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = color_shift .* (percent_to - percent_from)
    euclidean_point_transform(shift_color=move)
end

"""
    move_point(vector[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Point to move it along some vector

# Arguments
- `vector::Point`: The vector to move the point along
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function move_point(vector::Point2f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)

    add_vec = Vector{Float32}(vector .* (percent_to - percent_from))
    euclidean_point_transform(thenadd=add_vec)
end
function move_point(vector::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)

    add_vec = Vector{Float32}(vector .* (percent_to - percent_from))
    euclidean_point_transform(thenadd=add_vec)
end

"""
    arcmove_point(center, radians[, axis=:x, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Point to move it along some arc path (polar/spherical)

# Arguments
- `center::Point`: The center point of the arc to move along
- `radians::Float32`: The radians to move about the arc
- `axis::Symbol`: For 3D, the axis to rotate about; must be :x, :y, or :z
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function arcmove_point(center::Point2f, radians::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    θ = radians * (percent_to - percent_from)
    transform = rotation_matrix(θ)
    euclidean_point_transform(firstadd=Vector{Float32}(-1 * center),
        mult_left=transform, thenadd=Vector{Float32}(center))
end
function arcmove_point(center::EuclidSpacePoint2f, radians::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    θ = radians * (percent_to - percent_from)
    transform = rotation_matrix(θ)
    euclidean_point_transform(firstadd=Vector{Float32}(-1 * center.definition),
        mult_left=transform, thenadd=Vector{Float32}(center.definition))
end
function arcmove_point(center::Point3f, radians::Float32;
        axis::Symbol=:x,
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D points must be specified as :x, :y, or :z")
    end
    θ = radians * (percent_to - percent_from)
    transform = rotation_matrix(θ, axis=axis)
    euclidean_point_transform(firstadd=Vector{Float32}(-1 * center),
        mult_left=transform, thenadd=Vector{Float32}(center))
end
function arcmove_point(center::EuclidSpacePoint3f, radians::Float32;
        axis::Symbol=:x,
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D points must be specified as :x, :y, or :z")
    end
    θ = radians * (percent_to - percent_from)
    transform = rotation_matrix(θ, axis=axis)
    euclidean_point_transform(firstadd=Vector{Float32}(-1 * center.definition),
        mult_left=transform, thenadd=Vector{Float32}(center.definition))
end

"""
    reflect(point, [axis=:x, x_offset=0f0, y_offset=0f0, z_offset=0f0])

Get a copy of a point that is reflected across some axis

# Arguments
- `point::EuclidSpacePoint`: The point to get a reflected copy of
- `axis::Symbol`: The axis to reflect on; default is :x ; may be :x, :y, :diag, :negdiag, :origin
- 3D `axis` may be may be :xy, :yz, :xz, :diag, :negdiag, :altdiag, :origin
- `x_offset::Float32`: The offset of the reflection axis along the x-axis; default is 0f0
- `y_offset::Float32`: The offset of the reflection axis along the y-axis; default is 0f0
- `z_offset::Float32`: The offset of the reflection axis along the z-axis; default is 0f0
"""
function reflect(point::EuclidSpacePoint2f;
        axis::Symbol=:x,
        x_offset::Float32=0f0, y_offset::Float32=0f0)
    moved = reflect(point.definition, axis=axis, x_offset=x_offset, y_offset=y_offset)
    euclidean_point(point, definition=moved)
end
function reflect(point::EuclidSpacePoint3f;
        axis::Symbol=:xy,
        x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    moved = reflect(point.definition,
        axis=axis, x_offset=x_offset, y_offset=y_offset, z_offset=z_offset)
    euclidean_point(point, definition=moved)
end

"""
    scale(point, factor[, factory=factor, factorz=factor])

Get a copy of a point that is scaled by some factor

# Arguments
- `point::EuclidSpacePoint`: The point to get a scaled copy of
- `factor::Float32`: The primary (x) factor to scale by
- `factory::Float32`: The y factor to scale by; defaults to the primary factor
- `factorz::Float32`: The z factor to scale by; defaults to the primary factor
"""
function scale(point::EuclidSpacePoint2f, factor::Float32;
        factory::Float32=factor)
    moved = scale(point.definition, factor, factory=factory)
    euclidean_point(point, definition=moved)
end
function scale(point::EuclidSpacePoint3f, factor::Float32;
        factory::Float32=factor, factorz::Float32=factor)
    moved = scale(point.definition, factor, factory=factory, factorz=factorz)
    euclidean_point(point, definition=moved)
end

"""
    shear(point, factor[, direction=:ytox])

Get a copy of a point that is sheared by some factor in one direction

# Arguments
- `point::EuclidSpacePoint`: The point to get a sheared copy of
- `factor`: The shearing factor to apply
- `direction`: The direction of shearing to apply; defaults :ytox ; can be :ytox, :xtoy, :ztox, :ztoy, :xtoz, :ytoz
"""
function shear(point::EuclidSpacePoint2f, factor::Float32; direction::Symbol=:ytox)
    moved = shear(point.definition, factor, direction=direction)
    euclidean_point(point, definition=moved)
end
function shear(point::EuclidSpacePoint3f, factor::Float32; direction::Symbol=:ytox)
    moved = shear(point.definition, factor, direction=direction)
    euclidean_point(point, definition=moved)
end
