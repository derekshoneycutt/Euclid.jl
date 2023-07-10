
export intersection

"""
    intersection(line1, line2)

Get the point of intersection of a line and a circle, if present

# Arguments
- `line::EuclidLine`: The line to find intersection with
- `circle::EuclidCircle`: The circle to find intersection with
"""
function intersection(line::EuclidLine2f, circle::EuclidCircle2f;
                        point_width::Union{Float32, Observable{Float32}}=0.01f0,
                        point_color=:blue,
                        text_color=:blue,
                        text_opacity::Union{Float32, Observable{Float32}}=1f0,
                        labelA="A", labelB="B")
    extremityA = line.extremityA
    extremityB = line.extremityB
    radius = circle.radius
    center = circle.center

    observable_in_width = point_width isa Observable{Float32} ?
                          point_width :
                          Observable(point_width)

    # Get formulas for line
    m = @lift((($extremityB)[2] - ($extremityA)[2]) / (($extremityB)[1] - ($extremityA)[1]))
    b = @lift(($extremityA)[2] - $m * ($extremityA)[1])

    # Set up quadratic formula
    quad_a = @lift(($m)^2 + 1)
    quad_b = @lift(2*($b*$m - ($center)[1] - ($center)[2]*$m))
    quad_c = @lift(($center)[1]^2 + ($center)[2]^2 - $radius^2 + $b^2 - 2 * $b * ($center)[2])

    # check square root and division are going to be valid, then do them
    x_sqrtprt = @lift($quad_b^2 - 4 * $quad_a * $quad_c)
    x_denomprt = @lift(2 * $quad_a)
    x_1 = @lift((-$quad_b + √($x_sqrtprt)) / $x_denomprt)
    x_2 = @lift((-$quad_b - √($x_sqrtprt)) / $x_denomprt)
    y_1 = @lift($m * $x_1 + $b)
    y_2 = @lift($m * $x_2 + $b)



    text_opacity_observable = text_opacity isa Observable{Float32} ?
                              text_opacity :
                              Observable(text_opacity)
    true_text_opacity =
            @lift(($m === Inf) ?
                   0f0 :
                   $text_opacity_observable)

    use_point_width = observable_in_width

    # return the 2 curve_points
    [
        point(@lift(Point2f0($x_1, $y_1)),
            point_width=use_point_width, point_color=point_color,
            text_color=text_color, text_opacity=true_text_opacity, label=labelA),
        point(@lift(Point2f0($x_2, $y_2)),
            point_width=use_point_width, point_color=point_color,
            text_color=text_color, text_opacity=true_text_opacity, label=labelB)
    ]
end
function intersection(circle::EuclidCircle2f, line::EuclidLine2f;
                        point_width::Union{Float32, Observable{Float32}}=0.01f0,
                        point_color=:blue,
                        text_color=:blue,
                        text_opacity::Union{Float32, Observable{Float32}}=1f0,
                        labelA="A", labelB="B")
    intersection(line, circle, point_width=point_width, point_color=point_color,
        text_color=text_color, text_opacity=text_opacity, labelA=labelA, labelB=labelB)
end
