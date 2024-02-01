export display_gif, draw_animation, draw_animated_transforms

"""
    display_gif(file)

Displays a gif image through the IJulia interface in Jupyter notebooks

# Arguments
- `file::String`: The file path/name to the gif to open and display
"""
function display_gif(file::String)
    base64gif = base64encode(open(file))
    display(HTML("<img src=\"data:image/gif;base64,$(base64gif)\" />"))
end

"""
    draw_animation(chart, filename, timestamps[, framerate=24]) do t ... end

Draws an animation into a gif file and returns an HTML encoding of it

# Arguments
- `doer::Function`: Animation function to perform each round
- `chart::EuclidChartSpace`: The chart space to draw animations in
- `filename::String`: The name of the gif file to write
- `timestamps`: The range of timestamps to draw on
- `framerate`: The framerate to draw animations at
"""
function draw_animation(doer::Function, chart::EuclidChartSpace, filename::String, timestamps; framerate=24)
    display_gif(record(doer, chart.f, filename, timestamps; framerate=framerate))
end

"""
    draw_animation(chart, filename, timestamps[, duration=24, framerate=24]) do t ... end

Draws an animation into a gif file and returns an HTML encoding of it.

This call doer with a time between 0 and 2π. 2π will be the complete duration, each step a fraction of 2π.

# Arguments
- `doer::Function`: Animation function to perform each round
- `chart::EuclidChartSpace`: The chart space to draw animations in
- `filename::String`: The name of the gif file to write
- `duration`: The duration the animation should run for
- `framerate`: The framerate to draw animations at
"""
function draw_animation(
        doer::Function, chart::EuclidChartSpace, filename::String;
        duration=24, framerate=24)
    display_gif(record(doer, chart.f, filename, range(0,2π, step=2π/(duration*framerate)); framerate=framerate))
end





"""
    draw_animated_transforms(chart, filename, transforms[, duration=24, framerate=24])

Draws an animation into a gif file and returns an HTML encoding of it.

This takes in a vector of figures to draw and a vector of transformations.
Vector of figures should be associated with a `draw` method taking only that figure to draw
Vector of transformations are expected to follow the `EuclidTransformBase` interface

# Arguments
- `chart::EuclidChartSpace`: The chart space to draw animations in
- `filename::String`: The name of the gif file to write
- `figures::Vector`: The vectors to draw
- `transforms::Vector`: The transforms to apply during the animation
- `duration`: The duration the animation should run for
- `framerate`: The framerate to draw animations at

"""
function draw_animated_transforms(
        chart::EuclidChartSpace, filename::String, figures::Vector, transforms::Vector;
        duration=24, framerate=24)
    for figure in figures
        draw(figure)
    end
    draw_animation(chart, filename, duration=duration, framerate=framerate) do t
        perform_transforms(t, transforms)
    end
end
