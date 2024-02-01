export EuclidMatrixTransformation, euclidean_matrix_transform, compose, perform,
    rotation_matrix, rotate, reflect, scale, shear

"""
    EuclidMatrixTransformation

Describes a matrix transformation on Euclid space objects
"""
struct EuclidMatrixTransformation
    mult_left::Union{Matrix{Float32}, Nothing}
    mult_right::Union{Matrix{Float32}, Nothing}
    add_after::Union{Vector{Float32}, Nothing}
end

"""
    euclidean_matrix_transform([firstadd=nothing, mult_left=nothing, mult_right=nothing, thenadd=nothing])

Create a new euclidean matrix transformation

# Arguments
- `firstadd` : Vector to add at the beginning of the transformation
- `mult_left`: Transformation matrix to mulitply on the left side
- `mult_right`: Transformation matrix to multiply on the right side
- `thenadd`: Vector to add at the end of the transformation
"""
function euclidean_matrix_transform(;
        firstadd::Union{Vector{Float32}, Nothing}=nothing,
        mult_left::Union{Matrix{Float32}, Nothing}=nothing,
        mult_right::Union{Matrix{Float32}, Nothing}=nothing,
        thenadd::Union{Vector{Float32}, Nothing}=nothing)
    trueadd = firstadd
    if trueadd !== nothing
        if mult_left !== nothing
            trueadd = mult_left * trueadd
        end
        if mult_right !== nothing
            trueadd = trueadd * mult_right
        end
        if thenadd !== nothing
            trueadd = trueadd + thenadd
        end
    else
        trueadd = thenadd
    end

    EuclidMatrixTransformation(mult_left, mult_right, trueadd)
end

"""
    compose(t1, t2)

Compose 2 euclidean matrix transformations into a single transformation

# Arguments
- `t1`: The first transformation to apply
- `t2`: The transformation to apply after the first is applied
"""
function compose(t1::EuclidMatrixTransformation, t2::EuclidMatrixTransformation)
    mult_left = t1.mult_left
    mult_right = t1.mult_right
    thenadd = t1.add_after

    if mult_left !== nothing
        if t2.mult_left !== nothing
            mult_left = t2.mult_left * mult_left
        end
    else
        mult_left = t2.mult_left
    end
    if mult_right !== nothing
        if t2.mult_right !== nothing
            mult_right = mult_right * t2.mult_right
        end
    else
        mult_right = t2.mult_right
    end

    if thenadd !== nothing
        if t2.mult_left !== nothing
            thenadd = t2.mult_left * thenadd
        end
        if t2.mult_right !== nothing
            thenadd = thenadd * t2.mult_right
        end
        if t2.add_after !== nothing
            thenadd = thenadd + t2.add_after
        end
    else
        thenadd = t2.add_after
    end

    euclidean_matrix_transform(mult_left=mult_left, mult_right=mult_right,
        thenadd=thenadd)
end

"""
    perform(point, transform)

Get a new vector based on a previously defined matrix transformation

# Arguments
- `transform`: The transformation to perform
"""
function perform(point::Vector{Float32}, transform::EuclidMatrixTransformation)
    transformed = point
    if transform.mult_left !== nothing
        transformed = transform.mult_left * transformed
    end
    if transform.mult_right !== nothing
        transformed = transformed * transform.mult_right
    end
    if transform.add_after !== nothing
        transformed = transformed + transform.add_after
    end

    return transformed
end

"""
    rotation_matrix(θ[, axis=:twod])

Gets a rotation matrix for a given θ over a given axis

For 2D always use :twod axis. Otherwise, 3D axes are:
  :x, :y, :z, :xy, :yz, :xz, :xyz

# Arguments
- `θ::Float32`: Degree of rotation, in radians
- `axis::Symbol`: the axis to perform rotation; default is :twod for 2D rotations
"""
function rotation_matrix(θ::Float32; axis::Symbol=:twod)
    if axis != :twod && axis != :x && axis != :y && axis != :z &&
            axis != :xy && axis != :yz && axis != :xz && axis != :xyz
        throw("Axis of rotation must be specified as :twod, :x, :y, :z, :xy, :yz, :xz, or :xyz")
    end

    if axis == :twod
        [cos(θ) -sin(θ); sin(θ) cos(θ)]
    elseif axis == :x
        [1 0 0; 0 cos(θ) -sin(θ); 0 sin(θ) cos(θ)]
    elseif axis == :y
        [cos(θ) 0 sin(θ); 0 1 0; -sin(θ) 0 cos(θ)]
    elseif axis == :z
        [cos(θ) -sin(θ) 0; sin(θ) cos(θ) 0; 0 0 1]
    elseif axis == :xy
        [1 0 0; 0 cos(θ) -sin(θ); 0 sin(θ) cos(θ)] *
        [cos(θ) 0 sin(θ); 0 1 0; -sin(θ) 0 cos(θ)]
    elseif axis == :yz
        [cos(θ) 0 sin(θ); 0 1 0; -sin(θ) 0 cos(θ)] *
        [cos(θ) -sin(θ) 0; sin(θ) cos(θ) 0; 0 0 1]
    elseif axis == :xz
        [1 0 0; 0 cos(θ) -sin(θ); 0 sin(θ) cos(θ)] *
        [cos(θ) -sin(θ) 0; sin(θ) cos(θ) 0; 0 0 1]
    elseif axis == :xyz
        [1 0 0; 0 cos(θ) -sin(θ); 0 sin(θ) cos(θ)] *
        [cos(θ) 0 sin(θ); 0 1 0; -sin(θ) 0 cos(θ)] *
        [cos(θ) -sin(θ) 0; sin(θ) cos(θ) 0; 0 0 1]
    end
end

"""
    rotate(points, center, θ[, axis=:x])

Transform a point or set of points by rotating it a given amount in radians

# Arguments
- `points`: The points to perform the transformation on
- `center`: The center point to rotate around
- `θ`: The degree of rotation, in radians
"""
function rotate(points::Vector{Point2f}, center::Point2f, θ::Float32)
    transform = rotation_matrix(θ)
    use_points = reduce(hcat, points)
    offset = repeat(center, inner=(1,size(points, 1)))

    moved = (transform * (use_points - offset)) + offset

    [Point2f(p) for p in eachcol(moved)]
end
function rotate(points::Vector{Point3f}, center::Point3f, θ::Float32; axis::Symbol=:x)
    if axis != :x && axis != :y && axis != :z
        throw("Axis of rotation for 3D points must be specified as :x, :y, or :z")
    end
    transform = rotation_matrix(θ, axis=axis)
    use_points = reduce(hcat, points)
    offset = repeat(center, inner=(1,size(points, 1)))

    moved = (transform * (use_points - offset)) + offset

    [Point3f(p) for p in eachcol(moved)]
end
function rotate(vector::Point2f, center::Point2f, θ::Float32)
    rotate([vector], center, θ)[1]
end
function rotate(vector::Point3f, center::Point3f, θ::Float32)
    rotate([vector], center, θ)[1]
end

"""
    reflect(points[, axis=:x, x_offset=0f0, y_offset=0f0, z_offset=0f0])

Transform points by doing a reflection across some axis

# Arguments
- `points`: The points to perform the transformation on
- `axis::Symbol`: The axis to reflect on; default is :x ; may be :x, :y, :diag, :negdiag, :origin
- 3D `axis` may be may be :xy, :yz, :xz, :diag, :negdiag, :altdiag, :origin
- `x_offset::Float32`: The offset of the reflection axis along the x-axis; default is 0f0
- `y_offset::Float32`: The offset of the reflection axis along the y-axis; default is 0f0
- `z_offset::Float32`: The offset of the reflection axis along the z-axis; default is 0f0
"""
function reflect(points::Vector{Point2f};
        axis::Symbol=:x, x_offset::Float32=0f0, y_offset::Float32=0f0)
    if axis != :x && axis != :y && axis != :diag && axis != :negdiag && axis != :origin
        throw("Unsupported axis for 2D reflection. Supported symbols: :x, :y, :diag, :negdiag, or :origin")
    end

    transform =
        if axis == :x
            [1 0; 0 -1]
        elseif axis == :y
            [-1 0; 0 1]
        elseif axis == :diag
            [0 1; 1 0]
        elseif axis == :negdiag
            [0 -1; -1 0]
        elseif axis == :origin
            [-1 0; 0 -1]
        end
    use_points = reduce(hcat, points)
    offset = repeat([x_offset; y_offset], inner=(1,size(points, 1)))

    moved = (transform * (use_points - offset)) + offset

    [Point2f(p) for p in eachcol(moved)]
end
function reflect(points::Vector{Point3f};
        axis::Symbol=:xy, x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    if axis != :xy && axis != :yz && axis != :xz &&
            axis != :diag && axis != :negdiag && axis != :altdiag && axis != :origin
        throw("Unsupported axis for 3D reflection. Supported symbols: :xy, :xz, :yz, :diag, :negdiag, :altdiag, or :origin")
    end

    transform =
        if axis == :xy
            [1 0 0; 0 1 0; 0 0 -1]
        elseif axis == :yz
            [-1 0 0; 0 1 0; 0 0 1]
        elseif axis == :xz
            [1 0 0; 0 -1 0; 0 0 1]
        elseif axis == :diag
            [0 0 1; 0 1 0; 1 0 0]
        elseif axis == :negdiag
            [0 0 -1; 0 -1 0; -1 0 0]
        elseif axis == :altdiag
            [0 0 -1; 0 1 0; -1 0 0]
        elseif axis == :origin
            [-1 0 0; 0 -1 0; 0 0 -1]
        end
    use_points = reduce(hcat, points)
    offset = repeat([x_offset; y_offset; z_offset], inner=(1,size(points, 1)))

    moved = (transform * (use_points - offset)) + offset

    [Point3f(p) for p in eachcol(moved)]
end
function reflect(point::Point2f;
        axis::Symbol=:x, x_offset::Float32=0f0, y_offset::Float32=0f0)
    reflect([point], axis=axis, x_offset=x_offset, y_offset=y_offset)[1]
end
function reflect(point::Point3f;
        axis::Symbol=:xy, x_offset::Float32=0f0, y_offset::Float32=0f0, z_offset::Float32=0f0)
    reflect([point], axis=axis, x_offset=x_offset, y_offset=y_offset, z_offset=z_offset)[1]
end

"""
    scale(points, factor[, factory=factor, factorz=factor])

Transform points by scaling them in the coordinate system

# Arguments
- `points` : The points to scale
- `factor::Float32`: The primary (x) factor to scale by
- `factory::Float32`: The y factor to scale by; defaults to the primary factor
- `factorz::Float32`: The z factor to scale by; defaults to the primary factor
"""
function scale(points::Vector{Point2f}, factor::Float32; factory::Float32=factor)
    transform = [factor 0; 0 factory]
    use_points = reduce(hcat, points)

    moved = transform * use_points

    [Point2f(p) for p in eachcol(moved)]
end
function scale(points::Vector{Point3f}, factor::Float32;
        factory::Float32=factor, factorz::Float32=factor)
    transform = [factor 0 0; 0 factory 0; 0 0 factorz]
    use_points = reduce(hcat, points)

    moved = transform * use_points

    [Point3f(p) for p in eachcol(moved)]
end
function scale(point::Point2f, factor::Float32; factory::Float32=factor)
    scale([point], factor, factory=factory)[1]
end
function scale(point::Point3f, factor::Float32;
        factory::Float32=factor, factorz::Float32=factor)
    scale([point], factor, factory=factory, factorz=factorz)[1]
end

"""
    shear(points, factor[, direction=:ytox])

Transform points by shearing them in the coordinate system

# Arguments
- `points` : The points to shear
- `factor`: The shearing factor to apply
- `direction`: The direction of shearing to apply; defaults :ytox ; can be :ytox, :xtoy, :ztox, :ztoy, :xtoz, :ytoz
"""
function shear(points::Vector{Point2f}, factor::Float32; direction::Symbol=:ytox)
    transform =
        if direction == :ytox
            [1 factor; 0 1]
        elseif direction == :xtoy
            [1 0; factor 1]
        else
            throw("Unsupported direction to shear; For 2D must be :ytox or :xtoy")
        end
    use_points = reduce(hcat, points)

    moved = transform * use_points

    [Point2f(p) for p in eachcol(moved)]
end
function shear(points::Vector{Point3f}, factor::Float32; direction::Symbol=:ytox)
    transform =
        if direction == :ytox
            [1 factor 0; 0 1 0; 0 0 1]
        elseif direction == :ztox
            [1 0 factor; 0 1 0; 0 0 1]
        elseif direction == :xtoy
            [1 0 0; factor 1 0; 0 0 1]
        elseif direction == :ztoy
            [1 0 0; 0 1 factor; 0 0 1]
        elseif direction == :xtoz
            [1 0 0; 0 1 0; factor 0 1]
        elseif direction == :ytoz
            [1 0 0; 0 1 0; 0 factor 1]
        else
            throw("Unsupported direction to shear; For 3D must be :ytox, :ztox, :xtoy, :ztoy, :xtoz, or :ytoz")
        end
    use_points = reduce(hcat, points)

    moved = transform * use_points

    [Point3f(p) for p in eachcol(moved)]
end
function shear(point::Point2f, factor::Float32; direction::Symbol=:ytox)
    shear([point], factor, direction=direction)[1]
end
function shear(point::Point3f, factor::Float32; direction::Symbol=:ytox)
    shear([point], factor, direction=direction)[1]
end
