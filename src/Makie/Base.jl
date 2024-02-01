export draw

"""
    draw(figure)

Draws a figure with the current chart space for Euclid with GLMakie

# Arguments
- `figure`: The figure to draw
"""
function draw(point::EuclidText2f)
    at_spot = point.data
    plots = [
        text!(@lift(($at_spot).definition), text=point.text,
            color=@lift(opacify(($at_spot).color, ($at_spot).opacity)))
    ]

    return plots
end
function draw(point::EuclidText3f)
    at_spot = point.data
    plots = [
        text!(@lift(($at_spot).definition), text=point.text,
            color=@lift(opacify(($at_spot).color, ($at_spot).opacity)))
    ]

    return plots
end

