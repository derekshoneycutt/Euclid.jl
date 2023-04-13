
export fix_angle, vector_angle, angle_between

struct EuclidAngleObservables
    vec_θs
    θ_use
    θ_start
    θ_end
    norm_1
    norm_2
    draw_at
    θ
    angle_range
end

"""
    get_angle_measure_observables(cener, pointA, pointB, larger, angle_rad)

Gets the angle measurements used to draw an angle in Euclid diagrams

# Arguments
- `center::Observable{Point2f}` : The center point of the angle
- `pointA::Observable{Point2f}` : The point of the first extended extremity of the angle
- `pointB::Observable{Point2f}` : The point of the second extended extremity of the angle
- `larger::Bool` : Whether to get measures for the larger angle, or default to the smaller
- `angle_rad::Union{Float32, Observable{Float32}}` : The percent of the angle radiation to draw, as percent of smallest extended line
"""
function get_angle_measure_observables(
        center::Observable{Point2f}, pointA::Observable{Point2f}, pointB::Observable{Point2f},
        larger::Bool, angle_rad::Union{Float32, Observable{Float32}})

    vec_θs = @lift(sort([fix_angle(vector_angle($center, $pointA)),
    fix_angle(vector_angle($center, $pointB))]))

    θ_use = @lift((($vec_θs)[2] - ($vec_θs)[1] <= π) ⊻ larger ? 1 : 2)

    θ_start = @lift(($vec_θs)[$θ_use])
    θ_end = @lift($θ_use == 2 ? ($vec_θs)[1] + 2π : ($vec_θs)[2])

    norm_1 = @lift(norm($pointA - $center))
    norm_2 = @lift(norm($pointB - $center))
    draw_at = angle_rad isa Observable{Float32} ?
                @lift(min($norm_1, $norm_2) * $angle_rad) :
                @lift(min($norm_1, $norm_2) * angle_rad)

    rangle = round(π/2f0, digits=4)
    θ = @lift(round(fix_angle(angle_between($pointA - $center, $pointB - $center)), digits=4))
    angle_range = @lift($θ == rangle && !larger ?
                        [Point2f0([cos($θ_start); sin($θ_start)]*√((($draw_at)^2)/2) + $center),
                         Point2f0([cos($θ_start+π/4); sin($θ_start+π/4)]*$draw_at + $center),
                         Point2f0([cos($θ_end); sin($θ_end)]*√((($draw_at)^2)/2) + $center)] :
                        [Point2f0([cos(t); sin(t)]*$draw_at + $center) for t in $θ_start:(π/180):$θ_end])

    EuclidAngleObservables(vec_θs, θ_use, θ_start, θ_end, norm_1, norm_2, draw_at, θ, angle_range)
end

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