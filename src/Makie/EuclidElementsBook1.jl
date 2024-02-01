export draw

"""
    draw(figure)

Draws a figure with the current chart space for Euclid with GLMakie

# Arguments
- `figure`: The figure to draw
"""
function draw(point::EuclidPoint2f)
    at_spot = point.data
    showtext = point.showtext
    plots = [
        poly!(@lift(Circle(($at_spot).definition, ($at_spot).size)),
            color=@lift(opacify(($at_spot).color, ($at_spot).opacity)))
    ]
    if showtext
        plots = vcat(plots,
            text!(@lift(($at_spot).definition), text=point.label,
                color=@lift(opacify(($at_spot).color, ($at_spot).opacity))))
    end

    return plots
end
function draw(point::EuclidPoint3f)
    at_spot = point.data
    showtext = point.showtext
    plots = [
        mesh!(@lift(Sphere(($at_spot).definition, ($at_spot).size)),
            color=@lift(opacify(($at_spot).color, ($at_spot).opacity)))
    ]
    if showtext
        plots = vcat(plots,
            text!(@lift(($at_spot).definition), text=point.label,
                color=@lift(opacify(($at_spot).color, ($at_spot).opacity))))
    end

    return plots
end

function draw(line::EuclidLine2f)
    theline = line.data
    plots = [
        lines!(@lift([($theline).extremityA.definition, ($theline).extremityB.definition]),
            color=@lift(opacify(($theline).color, ($theline).opacity)),
            linewidth=@lift(($theline).width), linestyle=line.linestyle)
    ]

    return plots
end
function draw(line::EuclidLine3f)
    theline = line.data
    plots = [
        mesh!(@lift(Cylinder(($theline).extremityA.definition, ($theline).extremityB.definition,
            ($theline).width)), color=@lift(opacify(($theline).color, ($theline).opacity)))
    ]

    return plots
end

function draw(straight::EuclidStraightLine)
    plots = [draw(marker) for marker in straight.markers]

    return vcat(plots...)
end

function draw(surface::EuclidSurface2f)
    points = @lift([p.definition for p in ($(surface.data)).points])
    color = @lift(opacify(($(surface.data)).color, ($(surface.data)).opacity))
    plots = [
        poly!(points, color=color, strokewidth=0f0)
    ]

    return plots
end
function draw(surface::EuclidSurface3f)
    points = @lift([p.definition for p in ($(surface.data)).points])
    pfaces = @lift(faces(Polygon(Point2f0.($points))))
    drawmesh = @lift(normal_mesh($points, $pfaces))
    color =
        @lift([opacify(($(surface.data)).color, ($(surface.data)).opacity)
            for i in 1:size(($(surface.data)).points, 1)])
    plots = [
        mesh!(drawmesh, color=color)
    ]

    return plots
end

function draw(plane::EuclidPlaneSurface)
    plots = [draw(marker) for marker in plane.markers]

    return vcat(plots...)
end


function draw(angle::EuclidAngle2f)
    function fix_angle(θ::AbstractFloat)
        ret = θ % 2f0π
        while ret < 0f0
            ret = ret + 2f0π
        end
        ret
    end
    function vector_angle(A::Point2, B::Point2)
        v = B-A
        r = norm(v)
        θ = acos(v[1]/r)
        (v[2] >= 0 ? 1 : -1) * (θ == 0f0 && v[1] < 0 ? π : θ)
    end
    function angle_between(A::Point, B::Point)
        dp = dot(A, B)
        normprod = norm(A)*norm(B)
        θ = acos(dp/normprod)
        (A[2] >= 0 ? 1 : -1) * (θ == 0f0 && A[1] < 0 ? π : θ)
    end

    function get_vecθs(center::Point, pointA::Point, pointB::Point)
        vector_angle_A = fix_angle(vector_angle(center, pointA))
        vector_angle_B = fix_angle(vector_angle(center, pointB))
        sort([vector_angle_A, vector_angle_B])
    end

    function get_start_end_θ(vec_θs::Vector{Float32}, larger::Bool)
        θ_use = (vec_θs[2] - vec_θs[1] <= π) ⊻ larger ? 1 : 2

        θ_start = vec_θs[θ_use]
        θ_end = (θ_use == 2 ? vec_θs[1] + 2f0π : vec_θs[2]) + 0.001f0

        (θ_start, θ_end)
    end

    function get_drawing_angle(center::Point, pointA::Point, pointB::Point, angle_rad::Float32)
        v_A = pointA - center
        v_B = pointB - center
        norm_A = norm(v_A)
        norm_B = norm(v_B)
        draw_at = min(norm_A, norm_B) * angle_rad

        θ = fix_angle(angle_between(v_A, v_B))

        (θ, draw_at)
    end

    function get_angle_range(θ, larger::Bool, θ_start::Float32, θ_end::Float32,
        draw_at, center::Point2f)

        vcat([center], isapprox(θ, π/2, atol=0.0001) && !larger ?
            [Point2f0([cos(θ_start); sin(θ_start)]*√(((draw_at)^2)/2) + center),
                Point2f0([cos(θ_start+π/4); sin(θ_start+π/4)]*draw_at + center),
                Point2f0([cos(θ_end); sin(θ_end)]*√(((draw_at)^2)/2) + center)] :
            [Point2f0([cos(t); sin(t)]*draw_at + center) for t in θ_start:(π/180):θ_end])
    end

    vecA = @lift($(angle.data).vectorA)
    vecB = @lift($(angle.data).vectorB)
    center = @lift($(angle.data).intersect.definition)
    pointA = @lift($vecA + $center)
    pointB = @lift($vecB + $center)
    angle_rad = @lift($(angle.data).radius)
    larger = false

    vec_θs = @lift(get_vecθs($center, $pointA, $pointB))

    θ_start_end = @lift(get_start_end_θ($vec_θs, larger))

    θ_draw_at = @lift(get_drawing_angle($center, $pointA, $pointB, $angle_rad))

    angle_range = @lift(get_angle_range(($θ_draw_at)[1], larger, ($θ_start_end)[1],
        ($θ_start_end)[2], ($θ_draw_at)[2], $center))

    color = @lift(opacify(($(angle.data)).color, ($(angle.data)).opacity))

    plots = [
        poly!(angle_range, color=color, strokewidth=0f0)
    ]

    return plots
end

function draw(angle::EuclidAngle3f)
    # This code kinda sucks, but it works for now
    function vector_angles(vector::Point3f)
        θ = acos(vector[3] / norm(vector))
        θ = (vector[2] >= 0 ? 1 : -1) * (θ == 0f0 && vector[1] < 0 ? π : θ)
        ϕ = atan(vector[2], vector[1])

        (θ, ϕ)
    end
    function Point3f0_spherical(θ::Float32, ϕ::Float32, r::Float32)
        Point3f0(sin(θ) * cos(ϕ) * r, sin(θ) * sin(ϕ) * r, cos(θ) * r)
    end
    function points_between(center::Point3f, start::Point3f, final::Point3f,
            iters::Int, r::Float32)
        vec = final - start
        dist = norm(vec)
        di = dist / iters
        nvec = vec ./ dist
        if iters == 2
            online_r = √((r^2)/2)
            return [
                Point3f0(center + (normalize(start) * online_r)),
                Point3f0(center + (normalize(start + (nvec * di)) * r)),
                Point3f0(center + (normalize(final) * online_r))
            ]
        else
            return [
                Point3f0(center + (normalize((start + (nvec * (di * i)))) * r))
                for i in 0:iters
            ]
        end
    end
    function points_between(center::Point3f0, θ_start::Float32, θ_end::Float32,
        ϕ_start::Float32, ϕ_end::Float32, iters::Int, r::Float32)

        start = Point3f0_spherical(θ_start, ϕ_start, r)
        final = Point3f0_spherical(θ_end, ϕ_end, r)
        points_between(center, start, final, iters, r)
    end
    function get_start_end_θ(θA::Float32, ϕA::Float32, θB::Float32, ϕB::Float32, larger::Bool)
        #=θ_use = (θB - θA <= π) ⊻ larger ? 1 : 2

        θ_start = θ_use == 1 ? (θA, ϕA) : (θB, ϕB)
        θ_end = θ_use == 2 ? (θA + 2f0π, ϕA) : (θB, ϕB)

        (θ_start, θ_end)=#
        ((θA, ϕA), (θB, ϕB))
    end
    function get_triangledface1(center::Point3f0, vecA::Point3f0, vecB::Point3f0,
        angle_perp_vect::Point3f0, width::Float32,
        θ_start::Float32, θ_end::Float32, ϕ_start::Float32, ϕ_end::Float32,
        iters::Int, radius::Float32)

        use_center = center + (angle_perp_vect * width)
        pbetween = points_between(center, θ_start, θ_end, ϕ_start, ϕ_end,
            iters, radius)
        angle_points = [p + (angle_perp_vect * width) for p in pbetween]
        points = vcat([use_center], angle_points)
        triangles = TriangleFace{Int}[TriangleFace([1, i + 1, i + 2]) for i in 1:iters]

        (points, triangles, angle_points)
    end
    function get_triangledface2(mod_vec::Point3f, points::Array, iters::Int)
        plen = length(points)
        points = [p + mod_vec for p in points]
        triangles =
            TriangleFace{Int}[TriangleFace([plen + 1, plen + i + 2, plen + i + 1])
                for i in 0:iters]

        (points, triangles)
    end
    function get_sidetriangles(angle_points::Array, mod_vec::Point3f, before_side_count::Int)
        side_points = vcat(angle_points, [p + mod_vec for p in angle_points])
        count_points = length(side_points) / 2
        side_triangles = vcat([
            [TriangleFace{Int}(
                [before_side_count + i, before_side_count + count_points + i,
                 before_side_count + i + 1]),
             TriangleFace{Int}(
                [before_side_count + i + 1, before_side_count + count_points + i,
                 before_side_count + count_points + i + 1])]
            for i in 2:(count_points - 1)
        ]...)

        (side_points, side_triangles)
    end

    vecA = @lift($(angle.data).vectorA)
    vecB = @lift($(angle.data).vectorB)
    center = @lift($(angle.data).intersect.definition)
    radius = @lift($(angle.data).radius)
    width = @lift($(angle.data).width)
    opacity = @lift($(angle.data).opacity)
    color = @lift($(angle.data).color)
    larger = false

    θ_between = @lift(acos(($vecA ⋅ $vecB) / (norm($vecA) * norm($vecB))))
    iters = @lift(isapprox($θ_between, π/2, atol=0.0001) ? 2 : 30)

    anglesA = @lift(vector_angles($vecA))
    anglesB = @lift(vector_angles($vecB))
    angles = @lift(
        get_start_end_θ(($anglesA)[1], ($anglesA)[2], ($anglesB)[1], ($anglesB)[2], larger))

    angle_perp_vect = @lift(normalize($vecA × $vecB))
    mod_vec = @lift($angle_perp_vect * (-($width) * 2))

    ptriangles1 = @lift(get_triangledface1($center, $vecA, $vecB, $angle_perp_vect, $width,
        ($angles)[1][1], ($angles)[2][1], ($angles)[1][2], ($angles)[2][2],
        $iters, $radius))

    ptriangles2 = @lift(get_triangledface2($mod_vec, ($ptriangles1)[1], $iters))

    before_side_count = @lift(length(($ptriangles1)[1]) + length(($ptriangles2)[1]))
    ptriangles_side = @lift(get_sidetriangles(($ptriangles1)[3], $mod_vec, $before_side_count))

    use_points = @lift(vcat(($ptriangles1)[1], ($ptriangles2)[1], ($ptriangles_side)[1]))
    use_triangles = @lift(vcat(($ptriangles1)[2], ($ptriangles2)[2], ($ptriangles_side)[2]))

    meshed = @lift(normal_mesh($use_points, $use_triangles))

    use_color = @lift(opacify($color, $opacity))

    plots = [
        mesh!(@lift(Sphere($center, $width)), color=use_color)
        mesh!(meshed, color=@lift([$use_color for p in $use_points]))
    ]

    return plots
end

function draw(rectilineal::EuclidRectilinealAngle)
    plots = [
        draw(rectilineal.highlightA)...,
        draw(rectilineal.highlightB)...
    ]

    return plots
end

function draw(circle::EuclidCircle2f)
    center = @lift(($(circle.data)).center.definition)
    radius = @lift(($(circle.data)).radius)
    startθ = @lift(($(circle.data)).startθ)
    endθ = @lift(($(circle.data)).endθ)
    width = @lift(($(circle.data)).width)
    color = @lift(opacify(($(circle.data)).color, ($(circle.data)).opacity))

    points = @lift([
        Point2f0($radius * cos(θ) + ($center)[1], $radius * sin(θ) + ($center)[2])
        for θ in $startθ:(2π/60):$endθ
    ])

    plots = [
        lines!(points, color=color, linewidth=width, linestyle=:solid)
    ]

    return plots
end

function draw(circle::EuclidCircle3f)
    function get_circ_angles(source::Point3f, target::Point3f)
        v = target - source
        θ = sign(v[2]) * acos(v[1] / norm(Point2f(v)))
        ϕ = acos(v[3] / norm(v))

        (θ, ϕ)
    end

    function get_circ_points(center::Point3f, T::Matrix{Float32}; sects::Int=60, width::Float32=0.02f0)
        [
            Point3f(center + (T * [width * cos(2π*i / Float32(sects)), width * sin(2π*i / Float32(sects)), 0f0]))
            for i in 1:sects
        ]
    end

    function pipetris_from_circs(offset::Int; sects::Int=60, )
        vcat([
            [TriangleFace{Int}(offset + i, offset + sects + i, offset + (i == sects ? 1 : i + 1)),
             TriangleFace{Int}(offset + (i == sects ? 1 : i + 1), offset + sects + i, offset + (i == sects ? sects + 1 : sects + i + 1))]
            for i in 1:sects
        ]...)
    end

    function get_section_circs(before::Nothing, sect1::Point3f, sect2::Point3f;
            sects::Int=60, width::Float32=0.02f0)
        θ, ϕ = get_circ_angles(sect1, sect2)
        T = [cos(θ) -sin(θ) 0; sin(θ) cos(θ) 0; 0 0 1]*[cos(ϕ) 0 sin(ϕ); 0 1 0; -sin(ϕ) 0 cos(ϕ)]

        circ_seg1 = get_circ_points(sect1, T, sects=sects, width=width)
        circ_seg2 = get_circ_points(sect2, T, sects=sects, width=width)

        return [circ_seg2, circ_seg1]
    end
    function get_section_circs(before::Point3f, sect1::Point3f, sect2::Point3f;
            sects::Int=60, width::Float32=0.02f0)
        θ, ϕ = get_circ_angles(sect1, sect2)
        T = [cos(θ) -sin(θ) 0; sin(θ) cos(θ) 0; 0 0 1]*[cos(ϕ) 0 sin(ϕ); 0 1 0; -sin(ϕ) 0 cos(ϕ)]

        circ_seg1 = get_circ_points(sect1, T, sects=sects, width=width)
        circ_seg2 = get_circ_points(sect2, T, sects=sects, width=width)

        θ_b, ϕ_b = get_circ_angles(before, sect1)
        T_b = [cos(θ_b) -sin(θ_b) 0; sin(θ_b) cos(θ_b) 0; 0 0 1]*
            [cos(ϕ_b) 0 sin(ϕ_b); 0 1 0; -sin(ϕ_b) 0 cos(ϕ_b)]

        circ_seg1_b = get_circ_points(sect1, T_b, sects=sects, width=width)
        circ_seg2_b = [p for p in circ_seg1]

        return [circ_seg2_b, circ_seg1_b, circ_seg2, circ_seg1]
    end
    function get_pipe_mesh(along_points::Vector{Point3f}, draw_width, circ_sects)
        sect_hints = [
            [i == 1 ? nothing : along_points[i - 1], along_points[i], along_points[i + 1]]
            for i in 1:(length(along_points) - 1)
        ]

        sect_circs = vcat([
            get_section_circs(before, sect1, sect2, sects=circ_sects, width=draw_width)
            for (before, sect1, sect2) in sect_hints
        ]...)

        with_tris = [
            (sect_circs[i], sect_circs[i + 1],
                pipetris_from_circs((i-1)*circ_sects, sects=circ_sects))
            for i in 1:2:(length(sect_circs) - 1)
        ]
        all_points = vcat([
            vcat(c1, c2)
            for (c1, c2, tris) in with_tris
        ]...)
        all_tris = vcat([
            tris
            for (c1, c2, tris) in with_tris
        ]...)

        return (all_points, normal_mesh(all_points, all_tris))
    end

    all_points = []

    center = @lift(($(circle.data)).center.definition)
    radius = @lift(($(circle.data)).radius)
    normal = @lift(($(circle.data)).normal)
    startθ = @lift(($(circle.data)).startθ)
    endθ = @lift(($(circle.data)).endθ)
    width = @lift(($(circle.data)).width)
    color = @lift(opacify(($(circle.data)).color, ($(circle.data)).opacity))

    circ_sects = 60

    angles = @lift(vector_angles($normal))
    θ, ϕ = (@lift(($angles)[1]), @lift(($angles)[2]))
    T = @lift(
        [cos($θ) -sin($θ) 0; sin($θ) cos($θ) 0; 0 0 1]
        *[cos($ϕ) 0 sin($ϕ); 0 1 0; -sin($ϕ) 0 cos($ϕ)]
    )
    draw_points = @lift([
        Point3f0($T * [cos(a) * $radius, sin(a) * $radius, 0] + $center) for a in $startθ:π/circ_sects:$endθ
    ])

    mesh_data = @lift(get_pipe_mesh($draw_points, $width, circ_sects))

    all_points = @lift(($mesh_data)[1])
    meshed = @lift(($mesh_data)[2])

    plots = [
        mesh!(meshed, color=@lift([$color for p in $all_points]))
    ]

    return plots
end
