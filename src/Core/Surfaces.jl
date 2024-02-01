export EuclidSpaceSurface, EuclidSpaceSurface2f, EuclidSpaceSurface3f, euclidean_surface, EuclidSurfaceVector,
    EuclidSpaceSurfaceTransform, EuclidSpaceSurfaceMultiTransform, euclidean_surface_transform,
    compose, perform,
    points, extremities, extend, angle_from, vector,
    changeopacity_surface, shiftcolor_surface, move_surface, arcmove_surface, rotate_surface,
    reflect, scale, shear, intersections

"""
    EuclidSpaceSurface{N}

Describes a surface in Euclidean Space
"""
struct EuclidSpaceSurface{N}
    points::Vector{EuclidSpacePoint{N}}

    opacity::Float32
    color::RGB
end
EuclidSpaceSurface2f = EuclidSpaceSurface{2}
EuclidSpaceSurface3f = EuclidSpaceSurface{3}

"""
    EuclidSurfaceVector

Describes vectors from the points of a surface
"""
struct EuclidSurfaceVector{N}
    vectors::Vector{Point{N, Float32}}
end

"""
    EuclidSpaceSurfaceTransform

Describes a transformation to take on a Euclid Space Surface
"""
struct EuclidSpaceSurfaceTransform
    transforms::Vector{EuclidSpacePointTransform}

    add_opacity::Union{Float32, Nothing}
    shift_color::Union{Point3f, Nothing}
end

"""
    EuclidSpaceSurfaceMultiTransform

Describes a transformation to take on a Euclid Space Surface, based on a single point transformation
"""
struct EuclidSpaceSurfaceMultiTransform
    basedon::EuclidSpacePointTransform
end

"""
    euclidean_surface(points[, opacity=0f0, color=:blue])

Creates an object describing a surface in Euclidean Space

# Arguments
- `points`: The points of the surface to describe
- `opacity::Float32`: The opacity for the surface to show in
- `color`: The color for the surface to show in
"""
function euclidean_surface(points::Vector;
        opacity::Float32=0f0, color=:blue)
    EuclidSpaceSurface([euclidean_point(p) for p in points], opacity, get_color(color))
end
function euclidean_surface(surface::EuclidSpaceSurface;
        points::Vector=surface.points, opacity::Float32=surface.opacity, color=surface.color)
    EuclidSpaceSurface([euclidean_point(p) for p in points], opacity, get_color(color))
end

"""
    euclidean_surface_transform([transforms=[], add_opacity=nothing, shift_color=nothing])
    euclidean_surface_transform(transform)

Create a new euclidean surface transformation

# Arguments
- `transforms::Vector{EuclidSpacePointTransform}`: The transformation to take on each point; empty = none; default is none
- `add_opacity`: Magnitude to add to the opacity value of the point
- `shift_color`: Vector representing a shift in the color (R, G, B)
- `transform::EuclidSpacePointTransform`: Point transformation to take on all points
"""
function euclidean_surface_transform(;
        transforms::Vector{EuclidSpacePointTransform}=EuclidSpacePointTransform[],
        add_opacity::Union{Float32, Nothing}=nothing,
        shift_color::Union{Point3f, Nothing}=nothing)
    EuclidSpaceSurfaceTransform(transforms, add_opacity, shift_color)
end
function euclidean_surface_transform(transform::EuclidSpacePointTransform)
    EuclidSpaceSurfaceMultiTransform(transform)
end

"""
    compose(t1, t2)

Compose 2 euclidean surface transformations into a single transformation

# Arguments
- `t1`: The first transformation to apply
- `t2`: The transformation to apply after the first is applied
"""
function compose(t1::EuclidSpaceSurfaceTransform, t2::EuclidSpaceSurfaceTransform)
    transforms = vcat(t1.transforms, t2.transforms)
    add_opacity = t1.add_opacity
    shift_color = t1.shift_color

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

    euclidean_surface_transform(transforms=transforms, add_opacity=add_opacity,
        shift_color=shift_color)
end
function compose(t1::EuclidSpaceSurfaceMultiTransform, t2::EuclidSpaceSurfaceMultiTransform)
    euclidean_surface_transform(compose(t1.basedon, t2.basedon))
end

"""
    perform(surface, transform)

Get a new surface based on a previously defined transformation on a euclidean surface

# Arguments
- `surface`: The surface to perform the transformation on
- `transform`: The transformation to perform
"""
function perform(surface::EuclidSpaceSurface2f, transform::EuclidSpaceSurfaceTransform)
    transformed = length(transform.transforms) > 0 ?
        [perform(transform.transforms[i], p) for (i, p) in enumerate(surface.points)] :
        [p for p in surface.points]
    opacity = surface.opacity
    color = surface.color
    if transform.add_opacity !== nothing
        opacity = opacity + transform.add_opacity
    end
    if transform.shift_color !== nothing
        color = shift_color(color, transform.shift_color)
    end
    euclidean_surface(transformed, opacity=opacity, color=color)
end
function perform(surface::EuclidSpaceSurface2f, transform::EuclidSpaceSurfaceMultiTransform)
    transformed = reduce(hcat, surface.points)
    if transform.basedon.mult_left !== nothing
        transformed = transform.basedon.mult_left * transformed
    end
    if transform.basedon.mult_right !== nothing
        transformed = transformed * transform.basedon.mult_right
    end
    if transform.basedon.add_after !== nothing
        transformed = transformed +
            repeat(transform.basedon.add_after, inner=(1,size(surface.points, 1)))
    end
    transformed = [Point2f(p) for p in eachcol(transformed)]

    opacity = surface.opacity
    color = surface.color
    if transform.add_opacity !== nothing
        opacity = opacity + transform.add_opacity
    end
    if transform.shift_color !== nothing
        color = shift_color(color, transform.shift_color)
    end

    euclidean_surface(transformed, opacity=opacity, color=color)
end
function perform(surface::EuclidSpaceSurface3f, transform::EuclidSpaceSurfaceTransform)
    transformed = length(transform.transforms) > 0 ?
        [perform(transform.transforms[i], p) for (i, p) in enumerate(surface.points)] :
        [p for p in surface.points]
    opacity = surface.opacity
    color = surface.color
    if transform.add_opacity !== nothing
        opacity = opacity + transform.add_opacity
    end
    if transform.shift_color !== nothing
        color = shift_color(color, transform.shift_color)
    end
    euclidean_surface(transformed, opacity=opacity, color=color)
end
function perform(surface::EuclidSpaceSurface3f, transform::EuclidSpaceSurfaceMultiTransform)
    transformed = reduce(hcat, surface.points)
    if transform.basedon.mult_left !== nothing
        transformed = transform.basedon.mult_left * transformed
    end
    if transform.basedon.mult_right !== nothing
        transformed = transformed * transform.basedon.mult_right
    end
    if transform.basedon.add_after !== nothing
        transformed = transformed +
            repeat(transform.basedon.add_after, inner=(1,size(surface.points, 1)))
    end
    transformed = [Point3f(p) for p in eachcol(transformed)]

    opacity = surface.opacity
    color = surface.color
    if transform.add_opacity !== nothing
        opacity = opacity + transform.add_opacity
    end
    if transform.shift_color !== nothing
        color = shift_color(color, transform.shift_color)
    end

    euclidean_surface(transformed, opacity=opacity, color=color)
end

"""
    points(surface)

Get new points representing the points of a surface. Defaults to direct copies of the definition from the surface.

# Arguments
- `surface::EuclidSpaceSurface`: The surface to get the points of
"""
function points(surface::EuclidSpaceSurface)
    [euclidean_point(p) for p in surface.points]
end

"""
    extremities(surface)

Get lines representing the extremities of a surface.

# Arguments
- `surface::EuclidSpaceSurface`: The surface to get the extremities of
"""
function extremities(surface::EuclidSpaceSurface;
        width::Float32=0f0, opacity::Float32=0f0, color=:blue)
    count = length(surface.points)
    [
        euclidean_line(p, surface.points[i < count ? i + 1 : 1],
            width=width, opacity=opacity, color=color)
        for (i, p) in enumerate(surface.points)
    ]
end

"""
    vector(source, target)

Gets a representation on vectors pointing from the points of surface source to surface target

# Arguments
- `souce`: The starting surface of the vector
- `target`: The target that the vector points to
"""
function vector(source::EuclidSpaceSurface2f, target::EuclidSpaceSurface2f)
    EuclidSurfaceVector(
        [Point2f(p - source.points[i]) for (i, p) in enumerate(target.points)])
end
function vector(source::EuclidSpaceSurface3f, target::EuclidSpaceSurface3f)
    EuclidSurfaceVector(
        [Point3f(p - source.points[i]) for (i, p) in enumerate(target.points)])
end

"""
    changeopacity_surface(add_opacity[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Surface to change the opacity to some degree

# Arguments
- `add_opacity::Float32`: The magnitude to change the opacity
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function changeopacity_surface(add_opacity::Float32;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = add_opacity * (percent_to - percent_from)
    euclidean_surface_transform(add_opacity=move)
end

"""
    shiftcolor_surface(color_shift[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Surface to change the color by some color shift vector

# Arguments
- `color_shift::Point3f`: The vector representing the color shift to perform
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function shiftcolor_surface(color_shift::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    move = color_shift .* (percent_to - percent_from)
    euclidean_surface_transform(shift_color=move)
end

"""
    move_surface(vector[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Surface to move it along some vector

# Arguments
- `vector`: The vector to move the surface along
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function move_surface(vector::Point2f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_surface_transform(
        move_point(vector, percent_from=percent_from, percent_to=percent_to))
end
function move_surface(vector::EuclidSurfaceVector{2};
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_surface_transform(
        transforms=[move_point(v, percent_from=percent_from, percent_to=percent_to)
            for v in vector.vectors])
end
function move_surface(vector::Point3f;
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_surface_transform(
        move_point(vector, percent_from=percent_from, percent_to=percent_to))
end
function move_surface(vector::EuclidSurfaceVector{3};
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_surface_transform(
        transforms=[move_point(v, percent_from=percent_from, percent_to=percent_to)
            for v in vector.vectors])
end

"""
    arcmove_surface(centers, radians[, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Surface to move it along arc paths

Note: This moves each point independently with separate center points and radians.
To statically move the surface, keeping it the same size, will need to do the math for the steps.

# Arguments
- `centers::Vector{Point}`: The center points of the rotation
- `radians::Vector{Float32}`: The radians to move about the arc for each point
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function arcmove_line(centers::Vector{Point2f}, radians::Vector{Float32};
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_surface_transform(
        transforms=[arcmove_point(center, radians[i],
            percent_from=percent_from, percent_to=percent_to)
            for (i, center) in centers])
end
function arcmove_line(centers::Vector{EuclidSpacePoint2f}, radians::Vector{Float32};
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_surface_transform(
        transforms=[arcmove_point(center, radians[i],
            percent_from=percent_from, percent_to=percent_to)
            for (i, center) in centers])
end
function arcmove_line(centers::Vector{Point3f}, radians::Vector{Float32};
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_surface_transform(
        transforms=[arcmove_point(center, radians[i],
            percent_from=percent_from, percent_to=percent_to)
            for (i, center) in centers])
end
function arcmove_line(centers::Vector{EuclidSpacePoint3f}, radians::Vector{Float32};
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    euclidean_surface_transform(
        transforms=[arcmove_point(center, radians[i],
            percent_from=percent_from, percent_to=percent_to)
            for (i, center) in centers])
end

"""
    rotate_surface(center, radians[, clockwise=false, percent_from=0f0, percent_to=1f0])
    rotate_surface(center, radians[, axis=:x, clockwise=false, percent_from=0f0, percent_to=1f0])

Get transformation for a Euclidean Space Surface to rotate it around some center point

# Arguments
- `center::Point`: The center point of the rotation
- `radians::Float32`: The radians to rotate
- `axis::Symbol`: For 3D, the axis to rotate about; must be :x, :y, or :z
- `clockwise::Bool`: Whether to rotate clockwise; default is false
- `percent_from::Float32`: The percent of the transformation already applied (0f0 = 0%, 1f0 = 100%)
- `percent_to::Float32`: The percent of the transformation to apply up to (0f0 = 0%, 1f0 = 100%)
"""
function rotate_surface(center::Point2f, radians::Float32;
        clockwise::Bool=false, percent_from::Float32=0f0, percent_to::Float32=1f0)
    clockwise_mod = clockwise ? -1 : 1
    euclidean_surface_transform(arcmove_point(center, radians * clockwise_mod,
            percent_from=percent_from, percent_to=percent_to))
end
function rotate_surface(center::EuclidSpacePoint2f, radians::Float32;
        clockwise::Bool=false, percent_from::Float32=0f0, percent_to::Float32=1f0)
    clockwise_mod = clockwise ? -1 : 1
    euclidean_surface_transform(arcmove_point(center, radians * clockwise_mod,
            percent_from=percent_from, percent_to=percent_to))
end
function rotate_surface(center::Point3f, radians::Float32;
        axis::Symbol=:x, clockwise::Bool=false,
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    clockwise_mod = clockwise ? -1 : 1
    euclidean_surface_transform(arcmove_point(center, radians * clockwise_mod,
            axis=axis, percent_from=percent_from, percent_to=percent_to))
end
function rotate_surface(center::EuclidSpacePoint3f, radians::Float32;
        axis::Symbol=:x, clockwise::Bool=false,
        percent_from::Float32=0f0, percent_to::Float32=1f0)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D lines must be specified as :x, :y, or :z")
    end
    clockwise_mod = clockwise ? -1 : 1
    euclidean_surface_transform(arcmove_point(center, radians * clockwise_mod,
            axis=axis, percent_from=percent_from, percent_to=percent_to))
end

"""
    reflect(surface[, axis=:x, x_offset=0f0, y_offset=0f0])

Get a copy of a surface that is moved by reflecting it about an axis

# Arguments
- `surface::EuclidSpaceSurface`: The surface to get a reflection of
- `axis::Symbol`: The axis to reflect on; default is :x ; may be :x, :y, :diag, :negdiag, :origin
- 3D `axis` may be may be :xy, :yz, :xz, :diag, :negdiag, :altdiag, :origin
- `x_offset::Float32`: The offset of the reflection axis along the x-axis; default is 0f0
- `y_offset::Float32`: The offset of the reflection axis along the y-axis; default is 0f0
- `z_offset::Float32`: The offset of the reflection axis along the z-axis; default is 0f0
"""
function reflect(surface::EuclidSpaceSurface2f;
        axis::Symbol=:x, x_offset::Float32=0f0, y_offset::Float32=0f0)
    moved = reflect(surface.points,
        axis=axis, x_offset=x_offset, y_offset=y_offset)
    moved_e = [euclidean_point(surface.points[i], definition=p)
        for (i,p) in enumerate(moved)]
    euclidean_surface(moved_e, points=moved_e)
end
function reflect(surface::EuclidSpaceSurface3f;
        axis::Symbol=:xy, x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    moved = reflect(surface.points,
        axis=axis, x_offset=x_offset, y_offset=y_offset, z_offset=z_offset)
    moved_e = [euclidean_point(surface.points[i], definition=p)
        for (i,p) in enumerate(moved)]
    euclidean_surface(moved_e, points=moved_e)
end

"""
    scale(surface, factor[, factory=factor, factorz=factor])

Scale a surface according to given factors

# Arguments
- `surface::EuclidSpaceSurface` : The Line to scale
- `factor::Float32`: The primary (x) factor to scale by
- `factory::Float32`: The y factor to scale by; defaults to the primary factor
- `factorz::Float32`: The z factor to scale by; defaults to the primary factor
"""
function scale(surface::EuclidSpaceSurface2f, factor::Float32;
        factory::Float32=factor)
    moved = scale(surface.points,
        factor, factory=factory)
    moved_e = [euclidean_point(surface.points[i], definition=p)
        for (i,p) in enumerate(moved)]
    euclidean_surface(moved_e, points=moved_e)
end
function scale(surface::EuclidSpaceSurface3f, factor::Float32;
        factory::Float32=factor, factorz::Float32=factor)
    moved = scale(surface.points, factor,
        factory=factory, factorz=factorz)
    moved_e = [euclidean_point(surface.points[i], definition=p)
        for (i,p) in enumerate(moved)]
    euclidean_surface(moved_e, points=moved_e)
end

"""
    shear(surface, factor[, direction=:ytox])

Get a copy of a surface that is sheared by some factor in one direction

# Arguments
- `surface::EuclidSpaceSurface`: The surface to get a sheared copy of
- `factor`: The shearing factor to apply
- `direction`: The direction of shearing to apply; defaults :ytox ; can be :ytox, :xtoy, :ztox, :ztoy, :xtoz, :ytoz
"""
function shear(surface::EuclidSpaceSurface2f, factor::Float32; direction::Symbol=:ytox)
    moved = shear(surface.points, factor,
        direction=direction)
    moved_e = [euclidean_point(surface.points[i], definition=p)
        for (i,p) in enumerate(moved)]
    euclidean_surface(moved_e, points=moved_e)
end
function shear(surface::EuclidSpaceSurface3f, factor::Float32; direction::Symbol=:ytox)
    moved = shear(surface.points, factor,
        direction=direction)
    moved_e = [euclidean_point(surface.points[i], definition=p)
        for (i,p) in enumerate(moved)]
    euclidean_surface(moved_e, points=moved_e)
end

"""
    intersections(surface1, surface2)
    intersections(surface, line)

Get a list of all intersections between 2 surfaces, or a surface and a line
"""
function intersections(surface1::EuclidSpaceSurface, surface2::EuclidSpaceSurface;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    extrems1 = extremities(surface1)
    extrems2 = extremities(surface2)

    possible_intersects = [
        (line1, line2, intersection(line1, line2, size=size, opacity=opacity, color=color))
        for line1 in extrems1
        for line2 in extrems2
    ]

    intersects = reduce(possible_intersects, init=[]) do vec, current
        line1 = current[1]
        line2 = current[2]
        intersect = current[3]
        if is_infinite(intersect)
            return vec
        else
            line1_A = line1.extremityA.definition[1] <= line1.extremityB.definition[1] ?
                line1.extremityA.definition[1] : line1.extremityB.definition[1]
            line1_B = line1.extremityA.definition[1] <= line1.extremityB.definition[1] ?
                line1.extremityB.definition[1] : line1.extremityA.definition[1]
            line2_A = line2.extremityA.definition[1] <= line2.extremityB.definition[1] ?
                line2.extremityA.definition[1] : line2.extremityB.definition[1]
            line2_B = line2.extremityA.definition[1] <= line2.extremityB.definition[1] ?
                line2.extremityB.definition[1] : line2.extremityA.definition[1]
            if current[1] >= line1_A && current[1] <= line1_B &&
                    current[1] >= line2_A && current[1] <= line2_B
                return vcat(vec, intersect)
            else
                return vec
            end
        end
    end

    return intersects
end
function intersections(surface::EuclidSpaceSurface, line::EuclidSpaceLine;
        size::Float32=0f0, opacity::Float32=0f0, color=:blue)
    extrems = extremities(surface)

    possible_intersects = [
        (line1, intersection(line1, line, size=size, opacity=opacity, color=color))
        for line1 in extrems
    ]

    intersects = reduce(possible_intersects, init=[]) do vec, current
        line1 = current[1]
        intersect = current[2]
        if is_infinite(intersect)
            return vec
        else
            line1_A = line1.extremityA.definition[1] <= line1.extremityB.definition[1] ?
                line1.extremityA.definition[1] : line1.extremityB.definition[1]
            line1_B = line1.extremityA.definition[1] <= line1.extremityB.definition[1] ?
                line1.extremityB.definition[1] : line1.extremityA.definition[1]
            line2_A = line.extremityA.definition[1] <= line.extremityB.definition[1] ?
                line.extremityA.definition[1] : line.extremityB.definition[1]
            line2_B = line.extremityA.definition[1] <= line.extremityB.definition[1] ?
                line.extremityB.definition[1] : line.extremityA.definition[1]
            if current[1] >= line1_A && current[1] <= line1_B &&
                    current[1] >= line2_A && current[1] <= line2_B
                return vcat(vec, intersect)
            else
                return vec
            end
        end
    end

    return intersects
end
