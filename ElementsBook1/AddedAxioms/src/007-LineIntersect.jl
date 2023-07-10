
export intersection

"""
    intersection(line1, line2)

Get the point of intersection of 2 lines, if present

# Arguments
- `line1::EuclidLine`: The first line to find intersection with
- `line2::EuclidLine`: The second line to find intersection with
"""
function intersection(line1::EuclidLine2f, line2::EuclidLine2f;
    point_width::Union{Float32, Observable{Float32}}=0.01f0, point_color=:blue,
    text_color=:blue, text_opacity::Union{Float32, Observable{Float32}}=1f0, label="A")

    extremity_1A = line1.extremityA
    extremity_1B = line1.extremityB
    extremity_2A = line2.extremityA
    extremity_2B = line2.extremityB

    observable_in_width = point_width isa Observable{Float32} ?
                          point_width :
                          Observable(point_width)

    # Get formulas for line1 and line2
    m_1 = @lift(($extremity_1B[2] - $extremity_1A[2]) / ($extremity_1B[1] - $extremity_1A[1]))
    b_1 = @lift($extremity_1A[2] - $m_1 * $extremity_1A[1])
    m_2 = @lift(($extremity_2B[2] - $extremity_2A[2]) / ($extremity_2B[1] - $extremity_2A[1]))
    b_2 = @lift($extremity_2A[2] - $m_2 * $extremity_2A[1])

    x = @lift((abs($m_1) === Inf) ?
               $extremity_1A[1] :
               ((abs($m_2) === Inf) ?
                 $extremity_2A[1] :
                 ($b_1 - $b_2) / ($m_2 - $m_1)))
    y = @lift((abs($m_1) !== Inf) ?
               $m_1 * $x + $b_1 :
               $m_2 * $x + $b_2)



    text_opacity_observable = text_opacity isa Observable{Float32} ?
                              text_opacity :
                              Observable(text_opacity)
    true_text_opacity =
            @lift((($m_1 === Inf && $m_2 === Inf) || $m_1 == $m_2) ?
                   0f0 :
                   $text_opacity_observable)

    use_point_width =
        @lift(($m_1 == $m_2) ?
               0f0 :
               $observable_in_width)

    point(@lift(Point2f0($x,$y)),
            point_width=use_point_width, point_color=point_color,
            text_color=text_color, text_opacity=true_text_opacity, label=label)
end
function intersection(line1::EuclidLine3f, line2::EuclidLine3f;
    point_width::Union{Float32, Observable{Float32}}=0.01f0, point_color=:blue,
    text_color=:blue, text_opacity::Union{Float32, Observable{Float32}}=1f0, label="A")

    extremity_1A = line1.extremityA
    extremity_1B = line1.extremityB
    extremity_2A = line2.extremityA
    extremity_2B = line2.extremityB

    observable_in_width = point_width isa Observable{Float32} ?
                          point_width :
                          Observable(point_width)


    v_a = @lift($extremity_1B - $extremity_1A)
    v_b = @lift($extremity_2B - $extremity_2A)
    v_c = @lift($extremity_2A - $extremity_1A)

    a_cross_b = @lift($v_a × $v_b)
    squarenorm = @lift(norm($a_cross_b)^2)
    check_intersect = @lift($v_c ⋅ $a_cross_b)
    c_cross_b = @lift($v_c × $v_b)
    possible = @lift($check_intersect != 0f0 && $squarenorm != 0f0 ? NaN : ($c_cross_b ⋅ $a_cross_b) / $squarenorm)

    intersection = @lift(Point3f0($possible === NaN ?
                                    Inf :
                                    $extremity_1A + ($v_a .* $possible)))

    text_opacity_observable = text_opacity isa Observable{Float32} ?
                              text_opacity :
                              Observable(text_opacity)
    true_text_opacity =
            @lift(((($intersection)[1] === Inf || ($intersection)[2] === Inf)) ?
                   0f0 :
                   $text_opacity_observable)

    use_point_width =
        @lift((($intersection)[1] === Inf || ($intersection)[2] === Inf) ?
               0f0 :
               $observable_in_width)

    point(intersection,
            point_width=use_point_width, point_color=point_color,
            text_color=text_color, text_opacity=true_text_opacity, label=label)
end
