
export fix_angle, vector_angle, angle_between

"""
    fix_angle(θ)

Fix an angle so that it is always between 0 and 2π

# Arguments
- `θ`: The angle to fix
"""
fix_angle(θ) = begin
    ret = θ % 2f0π
    while ret < 0f0
        ret = ret + 2f0π
    end
    ret
end

"""
    vector_angle(A, B)

Get the angle of a vector at origin A, going to B

# Arguments
- `A::Point2`: The origin of the vector
- `B::Point2`: A point along the direction the vector is heading
"""
function vector_angle(A::Point2, B::Point2)
    v = B-A
    r = norm(v)
    θ = acos(v[1]/r)
    (v[2] >= 0 ? 1 : -1) * (θ == 0f0 && v[1] < 0 ? π : θ)
end


"""
    angle_between(A, B)

Get the angle between 2 vectors. Assumed to have same origin.

# Arguments
- `A::Point2`: The first vector
- `B::Point2`: The second vector
"""
function angle_between(A::Point2, B::Point2)
    dp = dot(A, B)
    normprod = norm(A)*norm(B)
    θ = acos(dp/normprod)
    (A[2] >= 0 ? 1 : -1) * (θ == 0f0 && A[1] < 0 ? π : θ)
end