
export fix_angle, vector_angle, angle_between

struct EuclidAngleObservables
    θ_start
    θ_end
    draw_at
    θ
    angle_range
end

struct EuclidAngleObtuseMarker
    point_begin
    point_end
end


function get_vecθs(center::Point2f, pointA::Point2f, pointB::Point2f)
    vector_angle_A = fix_angle(vector_angle(center, pointA))
    vector_angle_B = fix_angle(vector_angle(center, pointB))
    sort([vector_angle_A, vector_angle_B])
end

function get_start_end_θ(vec_θs)
    θ_use = (vec_θs[2] - vec_θs[1] <= π) ⊻ larger ? 1 : 2

    θ_start =vec_θs[θ_use]
    θ_end = θ_use == 2 ? vec_θs[1] + 2π : vec_θs[2]

    (θ_start, θ_end)
end

function get_drawing_angle(center::Point2f, pointA::Point2f, pointB::Point2f,
                           angle_rad::Float32)

    v_A = pointA - center
    v_B = pointB - center
    norm_A = norm(v_A)
    norm_B = norm(v_B)
    draw_at = min(norm_A, norm_B) * angle_rad

    θ = fix_angle(angle_between(v_A, v_B))

    (θ, draw_at)
end

function get_angle_rangle(θ, larger::Bool, θ_start, θ_end, draw_at, center)
    isapprox(θ, π/2, atol=0.0001) && !larger ?
        [Point2f0([cos(θ_start); sin(θ_start)]*√(((draw_at)^2)/2) + center),
            Point2f0([cos(θ_start+π/4); sin(θ_start+π/4)]*draw_at + center),
            Point2f0([cos(θ_end); sin(θ_end)]*√(((draw_at)^2)/2) + center)] :
        [Point2f0([cos(t); sin(t)]*draw_at + center) for t in θ_start:(π/180):θ_end]
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

    vec_θs = @lift(get_vecθs($center, $pointA, $pointB))

    θ_start_end = @lift(get_start_end_θ($vec_θs))

    θ_draw_at = angle_rad isa Observable{Float32} ?
                    @lift(get_drawing_angle($center, $pointA, $pointB, angle_rad)) :
                    @lift(get_drawing_angle($center, $pointA, $pointB, $angle_rad))

    angle_range = @lift(get_angle_range(($θ_draw_at)[1], larger, ($θ_start_end)[1], ($θ_start_end)[2], ($θ_draw_at)[2], $center))

    EuclidAngleObservables(@lift(($θ_start_end)[1]), @lift(($θ_start_end)[2]), @lift(($θ_draw_at)[2]), @lift(($θ_draw_at)[1]), angle_range)
end

"""
    get_obtuse_angle_marker(angle_data)

Get obtuse angle marker points for drawing a line indicating obtuse angle, based on observable euclid angle data

# Arguments
- `angle_data::EuclidAngleObservables` : Observable data about the angle being evaluated
"""
function get_obtuse_angle_marker(angle_data::EuclidAngleObservables)

    dot_begin = @lift(isapprox($(angle_data.θ), π, atol=0.0001) ?
                        ([cos(π/2f0 + $(angle_data.θ_start)); sin(π/2f0 + $(angle_data.θ_start))]*($(angle_data.draw_at)/1.5f0) +
                            first($(angle_data.angle_range))) :
                        $center)
    dot_end = @lift(isapprox($(angle_data.θ), π, atol=0.0001) ?
                        ([cos(π/2f0 + $(angle_data.θ_start)); sin(π/2f0 + $(angle_data.θ_start))]*($(angle_data.draw_at)/1.5f0) +
                            last($(angle_data.angle_range))) :
                        (larger ?
                            ([cos(π + $(angle_data.θ_start)); sin(π + $(angle_data.θ_start))]*($(angle_data.draw_at)*1.25f0) +
                                $center) :
                            ($(angle_data.θ) > π/2 ?
                                ([cos(π/2f0 + $(angle_data.θ_start)); sin(π/2f0 + $(angle_data.θ_start))]*($(angle_data.draw_at)*1.25f0) +
                                    $center) :
                                $center)))

    EuclidAngleObtuseMarker(dot_begin, dot_end)
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