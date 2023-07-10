
export intersection

"""
    intersection(circle1, circle2)

Get the point of intersection of 2 circles, if present

# Arguments
- `circle1::EuclidCircle`: The first circle to find intersection with
- `circle2::EuclidCircle`: The second circle to find intersection with
"""
function intersection(circle1::EuclidCircle, circle2::EuclidCircle;
                        point_width::Union{Float32, Observable{Float32}}=0.01f0,
                        point_color=:blue,
                        text_color=:blue,
                        text_opacity::Union{Float32, Observable{Float32}}=1f0,
                        labelA="A", labelB="B")
    center1 = circle1.center
    center2 = circle2.center
    r1 = circle1.radius
    r2 = circle2.radius

    observable_in_width = point_width isa Observable{Float32} ?
                          point_width :
                          Observable(point_width)

    center_vec = @lift($center2 - $center1)
    d = @lift(norm($center_vec))
    a = @lift(($r1^2 - $r2^2 + $d^2) / (2*$d))

    h = @lift(√(($r1)^2 - $a^2))
    c = @lift(Point2f($center1 + (($a/$d) .* ($center2 - $center1))))

    clockwise = @lift([0 1; -1 0] * $center_vec)
    counterclockwise = @lift([0 -1; 1 0] * $center_vec)

    clockwise_int = @lift(Point2f($c - ($h/$d) * $clockwise))
    counterclockwise_int = @lift(Point2f($c - ($h/$d) * $counterclockwise))

    text_opacity_observable = text_opacity isa Observable{Float32} ?
                              text_opacity :
                              Observable(text_opacity)
    true_text_opacity = text_opacity_observable

    use_point_width = observable_in_width

    # return the 2 curve_points
    [
        point(clockwise_int,
            point_width=use_point_width, point_color=point_color,
            text_color=text_color, text_opacity=true_text_opacity, label=labelA),
        point(counterclockwise_int,
            point_width=use_point_width, point_color=point_color,
            text_color=text_color, text_opacity=true_text_opacity, label=labelB)
    ]
    #=
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
    []=#
end

