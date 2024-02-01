export EuclidSpaceCircle, EuclidSpaceCircle2f, EuclidSpaceCircle3f, euclidean_circle,
    EuclidCircleVector, EuclidSpaceCircleTransform, euclidean_circle_transform,
    compose, transform,
    euclidean_surface, vector,
    changewidth_circle, changeopacity_circle, shiftcolor_circle, move_circle, arcmove_circle


"""
    EuclidSpaceCircle{N}

Describes a circle in Euclidean Space
"""
struct EuclidSpaceCircle{N}
    center::EuclidSpacePoint{N}
    radius::Float32
    normal::Point{N, Float32}

    startθ::Float32
    endθ::Float32

    width::Float32
    opacity::Float32
    color::RGB
end
EuclidSpaceCircle2f = EuclidSpaceCircle{2}
EuclidSpaceCircle3f = EuclidSpaceCircle{3}

"""
    EuclidCircleVector

Describes vectors from one circle to another
"""
struct EuclidCircleVector{N}
    cvector::Point{N, Float32}
    add_radius::Float32
    normal_vector::Point{N, Float32}
end

"""
    EuclidSpaceCircleTransform

Describes a transformation to take on a Euclid Space Circle
"""
struct EuclidSpaceCircleTransform
    center::Union{EuclidSpacePointTransform, Nothing}
    add_radius::Union{Float32, Nothing}
    normal::Union{Point, Nothing}

    add_start::Union{Float32, Nothing}
    add_end::Union{Float32, Nothing}

    add_width::Union{Float32, Nothing}
    add_opacity::Union{Float32, Nothing}
    shift_color::Union{Point3f, Nothing}
end

"""
    euclidean_circle(center, radius[, normal, startθ, endθ, width=0f0, opacity=0f0, color=:blue])

Creates an object describing a circle in Euclidean Space

# Arguments
- `circle`: The center of the circle
- `radius`: The radius length of the circle
- `normal`: In 3D circles, the normal vector of the plane the circle is on
- `width::Float32`: The width of the circle to describe
- `opacity::Float32`: The opacity for the circle to show in
- `color`: The color for the circle to show in
"""
function euclidean_circle(
        center::EuclidSpacePoint2f, radius::Float32;
        startθ::Float32=0f0, endθ::Float32=startθ,
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    EuclidSpaceCircle2f(center, radius, center.definition,
        startθ, endθ, width, opacity, get_color(color))
end
function euclidean_circle(
        center::EuclidSpacePoint3f, radius::Float32;
        normal::Point3f=Point3f0(0,0,1),
        startθ::Float32=0f0, endθ::Float32=startθ,
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    EuclidSpaceCircle3f(center, radius, normal,
        startθ, endθ, width, opacity, get_color(color))
end
function euclidean_circle(
        center::Point2f, radius::Float32;
        startθ::Float32=0f0, endθ::Float32=startθ,
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    use_center = euclidean_point(center)
    EuclidSpaceCircle2f(use_center, radius, center,
        startθ, endθ, width, opacity, get_color(color))
end
function euclidean_circle(
        center::Point3f, radius::Float32;
        normal::Point3f=Point3f0(0,0,1),
        startθ::Float32=0f0, endθ::Float32=startθ,
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    use_center = euclidean_point(center)
    EuclidSpaceCircle3f(use_center, radius, normal,
        startθ, endθ, width, opacity, get_color(color))
end
function euclidean_circle(
        orig::EuclidSpaceCircle2f;
        center::EuclidSpacePoint2f=orig.center,
        radius::Float32=orig.radius,
        startθ::Float32=orig.startθ, endθ::Float32=orig.endθ,
        width::Float32=orig.width, opacity::Float32=orig.opacity,
        color=orig.color)
    EuclidSpaceCircle2f(center, radius, center.definition,
        startθ, endθ, width, opacity, get_color(color))
end
function euclidean_circle(
        orig::EuclidSpaceCircle3f;
        center::EuclidSpacePoint3f=orig.center,
        radius::Float32=orig.radius,
        normal::Point3f=orig.normal,
        startθ::Float32=orig.startθ, endθ::Float32=orig.endθ,
        width::Float32=orig.width, opacity::Float32=orig.opacity,
        color=orig.color)
    EuclidSpaceCircle3f(center, radius, normal,
        startθ, endθ, width, opacity, get_color(color))
end


"""
    euclidean_circle_transform([center=nothing, add_radius=nothing, normal=nothing, add_start=nothing, add_end=nothing, add_width=nothing, add_opacity=nothing, shift_color=nothing])

Create a new euclidean circle transformation

# Arguments
- `center`: The transformation to take on the center of the circle
- `add_radius`: The amount to add to the radius of the circle
- `normal`: Modification to add to the normal vector. Only effects 3D circles.
- `add_start`: Radians to add to the start θ of the circle
- `add_end`: Radians to add to the end θ of the circle
- `add_width`: Magnitude to add to the width value of the point
- `add_opacity`: Magnitude to add to the opacity value of the point
- `shift_color`: Vector representing a shift in the color (R, G, B)
"""
function euclidean_circle_transform(;
        center::Union{EuclidSpacePointTransform, Nothing}=nothing,
        add_radius::Union{Float32, Nothing}=nothing,
        normal::Union{Point, Nothing}=nothing,
        add_start::Union{Float32, Nothing}=nothing,
        add_end::Union{Float32, Nothing}=nothing,
        add_width::Union{Float32, Nothing}=nothing,
        add_opacity::Union{Float32, Nothing}=nothing,
        shift_color::Union{Float32, Nothing}=nothing)
    EuclidSpaceCircleTransform(center, add_radius, normal,
        add_start, add_end, add_width, add_opacity, shift_color)
end

"""
    compose(t1, t2)

Compose 2 euclidean circle transformations into a single transformation

# Arguments
- `t1`: The first transformation to apply
- `t2`: The transformation to apply after the first is applied
"""
function compose(t1::EuclidSpaceCircleTransform, t2::EuclidSpaceCircleTransform)
    center = t1.center
    add_radius = t1.add_radius
    normal = t1.normal
    add_start = t1.add_start
    add_end = t1.add_end
    add_width = t1.add_width
    add_opacity = t1.add_opacity
    shift_color = t1.shift_color

    if center !== nothing
        if t2.center !== nothing
            center = compose(center, t2.center)
        end
    else
        center = t2.center
    end
    if add_radius !== nothing
        if t2.add_radius !== nothing
            add_radius = add_radius + t2.add_radius
        end
    else
        add_radius = t2.add_radius
    end
    if normal !== nothing
        if t2.normal !== nothing
            normal = normal + t2.normal
        end
    else
        normal = t2.normal
    end

    if add_start !== nothing
        if t2.add_start !== nothing
            add_start = add_start + t2.add_start
        end
    else
        add_start = t2.add_start
    end
    if add_end !== nothing
        if t2.add_end !== nothing
            add_end = add_end + t2.add_end
        end
    else
        add_end = t2.add_end
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

    euclidean_circle_transform(
        center=center, add_radius=add_radius, normal=normal,
        add_start=add_start, add_end=add_end,
        add_width=add_width, add_opacity=add_opacity,
        shift_color=shift_color)
end

"""
    perform(circle, transform)

Get a new circle based on a previously defined transformation on a euclidean circle

# Arguments
- `circle`: The circle to perform the transformation on
- `transform`: The transformation to perform
"""
function perform(circle::EuclidSpaceCircle2f, transform::EuclidSpaceCircleTransform)
    center = circle.center
    radius = circle.radius
    startθ = circle.startθ
    endθ = circle.endθ
    width = circle.width
    opacity = circle.opacity
    color = circle.color
    if transform.center !== nothing
        center = perform(center, transform.center)
    end
    if transform.add_radius !== nothing
        radius = radius + transform.add_radius
    end
    if transform.add_start !== nothing
        startθ = startθ + transform.add_start
    end
    if transform.add_end !== nothing
        endθ = endθ + transform.add_end
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
    euclidean_circle(center, radius,
        startθ=startθ, endθ=endθ,
        width=width, opacity=opacity, color=color)
end
function perform(circle::EuclidSpaceCircle3f, transform::EuclidSpaceCircleTransform)
    center = circle.center
    radius = circle.radius
    normal = circle.normal
    startθ = circle.startθ
    endθ = circle.endθ
    width = circle.width
    opacity = circle.opacity
    color = circle.color
    if transform.center !== nothing
        center = perform(center, transform.center)
    end
    if transform.add_radius !== nothing
        radius = radius + transform.add_radius
    end
    if transform.normal !== nothing
        normal = normal + transform.add_normal
    end
    if transform.add_start !== nothing
        startθ = startθ + transform.add_start
    end
    if transform.add_end !== nothing
        endθ = endθ + transform.add_end
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
    euclidean_circle(center, radius,
        normal=normal,
        startθ=startθ, endθ=endθ,
        width=width, opacity=opacity, color=color)
end


"""
    euclidean_surface(circle[, points=60, opacity=0f0, color=:blue])

Get a surface described within a circle.

# Arguments
- `circle::EuclidSpaceCircle`: The circle to get a surface description from
- `points::Int`: The number of points to draw the circle from.
- `opacity::Float32`: The opacity of the surface to describe.
- `color`: The color of the surface to describe.
"""
function euclidean_surface(circle::EuclidSpaceCircle2f;
        points::Int=60, opacity::Float32=0f0, color=:blue)
    r = circle.radius
    center = circle.center.definition
    startθ = circle.startθ
    endθ = circle.endθ
    use_points = [
        Point2f0(r * cos(θ) + center[1], r * sin(θ) + center[2])
        for θ in startθ:(2π/points):endθ
    ]

    return euclidean_surface(use_points, opacity=opacity, color=color)
end
function euclidean_surface(circle::EuclidSpaceCircle3f;
        points::Int=60, opacity::Float32=0f0, color=:blue)
    r = circle.radius
    center = circle.center.definition
    normal = circle.normal
    nθ, nϕ = vector_angles(normal)
    startθ = circle.startθ
    endθ = circle.endθ
    use_points = [
        Point3f0(([r * cos(θ), r * sin(θ), 0]
            * (rotation_matrix(nθ, axis=:x) * rotation_matrix(nϕ, axis=:z)))
            + center)
        for θ in startθ:(2π/points):endθ
    ]

    return euclidean_surface(use_points, opacity=opacity, color=color)
end


"""
    diameter(circle, θ[, width=1f0 or 0.01f0, opacity=0f0, color=:blue])

Get a diameter of the given circle

# Arguments
- `circle::EuclidSpaceCircle` : Circle to get the diameter from
- `θ::Float32` : The angle to ge tthe diameter from
- `width::Float32` : Width of the diameter line
- `opacity::Float32` : Opacity of the diameter line
- `color` : Color of the diameter line
"""
function diameter(circle::EuclidSpaceCircle2f, θ::Float32;
        width::Float32=1f0, opacity::Float32=0f0, color=:blue)
    c = circle.center.definition
    r = circle.radius
    point1 = Point2f0(cos(θ), sin(θ)) * r + c
    point2 = Point2f0(cos(θ + π), sin(θ + π)) * r + c

    def = euclidean_line(point1, point2, width=width, color=color, opacity=opacity)

    return def
end
function diameter(circle::EuclidSpaceCircle3f, θ::Float32;
        width::Float32=1f0, opacity::Float32=0f0, color=:blue)
    c = circle.center.definition
    r = circle.radius
    normal = circle.normal

    nθ, nϕ = vector_angles(normal)
    T = [cos(nθ) -sin(nθ) 0; sin(nθ) cos(nθ) 0; 0 0 1] *
        [cos(nϕ) 0 sin(nϕ); 0 1 0; -sin(nϕ) 0 cos(nϕ)]

    point1 = Point3f0(T * [cos(θ), sin(θ), 0] * r + c)
    point2 = Point3f0(T * [cos(θ + π), sin(θ + π), 0] * r + c)

    def = euclidean_line(point1, point2, width=width, color=color, opacity=opacity)

    return def
end


"""
    vector(source, target)

Gets a representation on vectors pointing from a circle source to circle target

# Arguments
- `souce`: The starting circle of the vector
- `target`: The target that the vector points to
"""
function vector(source::EuclidSpaceCircle2f, target::EuclidSpaceCircle2f)
    EuclidCircleVector{2}(vector(source.center, target.center),
        target.radius - source.target, target.normal - source.normal)
end
function vector(source::EuclidSpaceCircle3f, target::EuclidSpaceCircle3f)
    EuclidCircleVector{3}(vector(source.center, target.center),
        target.radius - source.target, target.normal - source.normal)
end

"""
    changeradius_circle(add_radius[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the radius to some degree

# Arguments
- `add_radius::Float32`: The magnitude to change the radius
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changeradius_circle(add_radius::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_radius *  (percent_to - percent_from)
    euclidean_circle_transform(add_radius=move)
end

"""
    changenormal_circle(normal[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the normal vector to some degree

# Arguments
- `normal::Point3f0`: The vector to add to the normal
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changenormal_circle(normal::Point3f0;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = normal .*  (percent_to - percent_from)
    euclidean_circle_transform(normal=move)
end

"""
    changestart_circle(add_start[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the start θ to some degree

# Arguments
- `add_start::Float32`: The magnitude to change the start θ
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changestart_circle(add_start::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_start *  (percent_to - percent_from)
    euclidean_circle_transform(add_start=move)
end

"""
    changeend_circle(add_end[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the end θ to some degree

# Arguments
- `add_end::Float32`: The magnitude to change the end θ
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changeend_circle(add_end::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_end *  (percent_to - percent_from)
    euclidean_circle_transform(add_end=move)
end

"""
    changewidth_circle(add_width[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the size to some degree

# Arguments
- `add_width::Float32`: The magnitude to change the width
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changewidth_circle(add_width::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_width *  (percent_to - percent_from)
    euclidean_circle_transform(add_width=move)
end

"""
    changeopacity_circle(add_opacity[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the opacity to some degree

# Arguments
- `add_opacity::Float32`: The magnitude to change the opacity
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changeopacity_circle(add_opacity::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_opacity * (percent_to - percent_from)
    euclidean_circle_transform(add_opacity=move)
end

"""
    shiftcolor_circle(color_shift[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to change the color by some color shift vector

# Arguments
- `color_shift::Point3f`: The vector representing the color shift to perform
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function shiftcolor_circle(color_shift::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = color_shift .* (percent_to - percent_from)
    euclidean_circle_transform(shift_color=move)
end


"""
    move_circle(vector[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Line to move it along some vector

# Arguments
- `vector`: The vector to move the circle along
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function move_circle(vector::Point2f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_circle_transform(
        center=move_point(vector, percent_from=percent_from, percent_to=percent_to))
end
function move_circle(vector::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_circle_transform(
        center=move_point(vector, percent_from=percent_from, percent_to=percent_to))
end
function move_circle(vector::EuclidCircleVector;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_circle_transform(
        center=move_point(vector.cvector, percent_from=percent_from, percent_to=percent_to),
        add_radius=vector.add_radius,
        normal=vector.normal_vector)
end



"""
    arcmove_circle(center, radians[, axis=:x, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Circle to move it along some arc path (polar/spherical)

# Arguments
- `center::Point`: The center point of the arc to move along
- `radians::Float32`: The radians to move about the arc
- `axis::Symbol`: For 3D, the axis to rotate about; must be :x, :y, or :z
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function arcmove_circle(center::Point2f, radians::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_circle_transform(
        center=arcmove_point(center, radians,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_circle(center::EuclidSpacePoint2f, radians::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_circle_transform(
        center=arcmove_point(center, radians,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_circle(center::Point3f, radians::Float32;
        axis::Symbol=:x, percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_circle_transform(
        center=arcmove_point(center, radians, axis=axis,
            percent_from=percent_from, percent_to=percent_to))
end
function arcmove_circle(center::EuclidSpacePoint3f, radians::Float32;
        axis::Symbol=:x, percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_circle_transform(
        center=arcmove_point(center, radians, axis=axis,
            percent_from=percent_from, percent_to=percent_to))
end

"""
    reflect(circle, [axis=:x, x_offset=0f0, y_offset=0f0, z_offset=0f0])

Get a copy of a circle that is reflected across some axis

# Arguments
- `circle::EuclidSpaceCircle`: The circle to get a reflected copy of
- `axis::Symbol`: The axis to reflect on; default is :x ; may be :x, :y, :diag, :negdiag, :origin
- 3D `axis` may be may be :xy, :yz, :xz, :diag, :negdiag, :altdiag, :origin
- `x_offset::Float32`: The offset of the reflection axis along the x-axis; default is 0f0
- `y_offset::Float32`: The offset of the reflection axis along the y-axis; default is 0f0
- `z_offset::Float32`: The offset of the reflection axis along the z-axis; default is 0f0
"""
function reflect(circle::EuclidSpaceCircle2f;
        axis::Symbol=:x,
        x_offset::Float32=0f0, y_offset::Float32=0f0)
    moved = reflect(circle.center, axis=axis, x_offset=x_offset, y_offset=y_offset)
    euclidean_circle(circle, center=moved)
end
function reflect(circle::EuclidSpaceCircle3f;
        axis::Symbol=:xy,
        x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    moved = reflect(circle.center,
        axis=axis, x_offset=x_offset, y_offset=y_offset, z_offset=z_offset)
    euclidean_circle(circle, center=moved)
end

"""
    scale(circle, factor[, factory=factor, factorz=factor])

Get a copy of a circle that is scaled by some factor

# Arguments
- `circle::EuclidSpaceCircle`: The circle to get a scaled copy of
- `factor::Float32`: The primary (x) factor to scale by
- `factory::Float32`: The y factor to scale by; defaults to the primary factor
- `factorz::Float32`: The z factor to scale by; defaults to the primary factor
"""
function scale(circle::EuclidSpaceCircle2f, factor::Float32;
        factory::Float32=factor, scaleradius::Bool=false)
    moved = scale(circle.center, factor, factory=factory)
    useradius = circle.radius * (scaleradius ? factor : 1)
    euclidean_circle(circle, center=moved, radius=useradius)
end
function scale(circle::EuclidSpaceCircle3f, factor::Float32;
        factory::Float32=factor, factorz::Float32=factor, scaleradius::Bool=false)
    moved = scale(circle.center, factor, factory=factory, factorz=factorz)
    useradius = circle.radius * (scaleradius ? factor : 1)
    euclidean_circle(circle, center=moved, radius=useradius)
end

"""
    shear(circle, factor[, direction=:ytox])

Get a copy of a circle that is sheared by some factor in one direction

# Arguments
- `circle::EuclidSpaceCircle`: The circle to get a sheared copy of
- `factor`: The shearing factor to apply
- `direction`: The direction of shearing to apply; defaults :ytox ; can be :ytox, :xtoy, :ztox, :ztoy, :xtoz, :ytoz
"""
function shear(circle::EuclidSpaceCircle2f, factor::Float32; direction::Symbol=:ytox)
    moved = shear(circle.center, factor, direction=direction)
    euclidean_circle(circle, center=moved)
end
function shear(circle::EuclidSpaceCircle3f, factor::Float32; direction::Symbol=:ytox)
    moved = shear(circle.center, factor, direction=direction)
    euclidean_circle(circle, center=moved)
end



"""
    intersection(circle, line[, size=0f0, opacity=0f0, color=:blue])
    intersection(line, circle[, size=0f0, opacity=0f0, color=:blue])
    intersection(c1, c2[, size=0f0, opacity=0f0, color=:blue])

Get a point where a line intersects a circle or 2 circles intersect.
Returns an array of 0, 1, or 2 EuclidSpacePoint

# Arguments
- `circle::EuclidSpaceCircle`: The circle
- `line::EuclidSpaceLine`: The line
- `c1::EuclidSpaceCircle`: The first circle
- `c2::EuclidSpaceCircle`: The second circle
- `size::Float32`: The size of the intersecting point; defaults to 0f0
- `opacity::Float32`: The opacity for the intersecting point to show in
- `color`: The color for the intersecting point to show in
"""
function intersection(circle::EuclidSpaceCircle2f, line::EuclidSpaceLine2f;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    m = line.slope
    b = line.intercept
    center = circle.center
    radius = circle.radius

    quada = m^2 + 1
    quadb = 2 * (b*m - center[1] - center[2]*m)
    quadc = center[1]^2 + center[2]^2 - radius^2 + b^2 - 2*b*center[2]

    sqrtprt = quadb^2 - 4*quada*quadc
    denomprt = 2 * quada
    intersects = []
    if denompart ≉ 0
        x_1 = (-quadb + √sqrtprt) / denomprt
        x_2 = (-quadb - √sqrtprt) / denomprt
        y_1 = m * x_1 + b
        if x_1 ≈ x_2
            intersects = [Point2f0(x_1, y_1)]
        else
            y_2 = m * x_2 + b
            intersects = [Point2f0(x_1, y_1), Point2f0(x_2, y_2)]
        end
    end

    return [
        euclidean_point(p, size=size, opacity=opacity, color=color)
        for p in intersects
    ]
end
function intersection(circle::EuclidSpaceCircle3f, line::EuclidSpaceLine3f;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    # TODO : 3D circle and line intersections
end
function intersection(line::EuclidSpaceLine, circle::EuclidSpaceCircle;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    intersection(circle, line, size=size, opacity=opacity, color=color)
end

function intersection(c1::EuclidSpaceCircle2f, c2::EuclidSpaceCircle2f;
       size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    c1 = c1.center
    c2 = c2.center
    r1 = c1.radius
    r2 = c2.radius

    cv = c2 - c1
    d = norm(cv)

    intersects = []
    if d ≈ r1 + r2
        intersects = [Point2f0((c1 * r2  + c2 * r1) / (r1 + r2))]
    elseif d < r1 + r2
        if d ≈ r1 - r2
            intersects = [Point2f0((c1 - c2) * r2 / (r2 - r1))]
        elseif d > r1 - r2
            a = (r1^2 - r2^2 + d^2) / 2*d
            h = √(r1^2 - a^2)
            c = Point2f(c1 + ((a/d) .* cv))
            clockwise = [0 1; -1 0] * cv
            counterclockwise = [0 -1; 1 0] * cv
            intersects = [
                Point2f0(c - (h/d) * clockwise),
                Point2f0(c - (h/d) * counterclockwise)
            ]
        end
    end

    return [
        euclidean_point(p, size=size, opacity=opacity, color=color)
        for p in intersects
    ]
end
function intersection(c1::EuclidSpaceCircle3f, c2::EuclidSpaceCircle3f;
       size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    c1 = c1.center
    c2 = c2.center
    r1 = c1.radius
    r2 = c2.radius
    n1 = c1.normal
    n2 = c2.normal

    ncross = n1 × n2
    cv = c2 - c1
    d = norm(cv)

    intersects = []
    if ncross[1] ≉ 0 || ncross[2] ≉ 0 || ncross[3] ≉ 0
        # TODO  : Intersections not on same plane?!
    elseif cv ⋅ n1 ≈ 0
        if d ≈ r1 + r2
            intersects = [Point3f0((c1 * r2  + c2 * r1) / (r1 + r2))]
        elseif d < r1 + r2
            if d ≈ r1 - r2
                intersects = [Point3f0((c1 - c2) * r2 / (r2 - r1))]
            elseif d > r1 - r2
                cv_norm = normalize(cv)
                cv_mod = cv_norm × normalize(n1)
                q = d^2 + r2^2 - r1^2
                dx = 0.5 * q / d
                dy = 0.5 * √(4 * d^2 * r2^2 - q^2) / d
                intersects = [
                    Point3f0(c1 - (cv_norm * dx + cv_mod * dy)),
                    Point3f0(c1 - (cv_norm * dx - cv_mod * dy))
                ]
            end
        end
    end

    return [
        euclidean_point(p, size=size, opacity=opacity, color=color)
        for p in intersects
    ]
end
