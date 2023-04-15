
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


#=

""" Get the point of intersection of a line and circle, if present """
function intersection(line::EuclidLine, circle::EuclidCircle)
    # Get formulas for line
    m = (line.B[1] - line.A[1] != 0) ? (line.B[2] - line.A[2]) / (line.B[1] - line.A[1]) : nothing
    b = m !== nothing ? line.A[2] - m * line.A[1] : nothing

    # Set up quadratic formula
    quad_a = m^2 + 1
    quad_b = 2*(b*m - circle.A[1] - circle.A[2]*m)
    quad_c = circle.A[1]^2 + circle.A[2]^2 - circle.r^2 + b^2 - 2 * b * circle.A[2]

    # check square root and division are going to be valid, then do them
    x_sqrtprt = quad_b^2 - 4 * quad_a * quad_c
    x_denomprt = 2 * quad_a
    x_1 = x_sqrtprt >= 0 && x_denomprt != 0 ? (-quad_b + √(x_sqrtprt)) / x_denomprt : nothing
    x_2 = x_sqrtprt >= 0 && x_denomprt != 0 ? (-quad_b - √(x_sqrtprt)) / x_denomprt : nothing
    y_1 = x_1 !== nothing ? m * x_1 + b : nothing
    y_2 = x_2 !== nothing ? m * x_2 + b : nothing

    # return the 2 points or empty list
    if x_1 !== nothing && x_2 !== nothing
        return [Point2f(x_1, y_1), Point2f(x_2, y_2)]
    elseif x_1 !== nothing
        return [Point2f(x_1, y_1)]
    elseif x_2 !== nothing
        return [Point2f(x_2, y_2)]
    else
        return []
    end
end

""" Get the point of intersection of a circle and line, if present """
function intersection(circle::EuclidCircle, line::EuclidLine)
    intersection(line, circle)
end

""" Get the point of intersection of 2 circles, if present """
function intersection(circle1::EuclidCircle, circle2::EuclidCircle)
    d = norm(circle2.A - circle1.A)
    a = (circle1.r^2 - circle2.r^2 +d^2) / (2*d)
    #b = (circle2.r^2 - circle1.r^2 +d^2) / (2*d)

    r_sum = circle1.r + circle2.r
    if d <= r_sum
        h = √((circle1.r)^2 - a^2)
        c = Point2f(circle1.A + ((a/d) .* (circle2.A - circle1.A)))

        if d == r_sum
            return [c]
        else
            center_vec = (circle2.A - circle1.A)
            clockwise = [0 1; -1 0] * center_vec
            counterclockwise = [0 -1; 1 0] * center_vec

            clockwise_int = Point2f(c - (h/d) * clockwise)
            counterclockwise_int = Point2f(c - (h/d) * counterclockwise)

            return [clockwise_int, counterclockwise_int]
        end
    end
    []
end
=#