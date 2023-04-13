
export perform, display_gif, draw_animation

"""
    perform(t, start_at1, end_at1, start_at2, end_at2, begin... end, begin... end, begin... end) do ... end

Performs a 2-part animation based on elapsed time. Includes cleaning functions passing a boolean if action has performed.

# Arguments
- `actor::Function`: Function called to perform the animation
- `t::AbstractFloat`: The amount of time elapsed so far in the animation
- `start_at1::AbstractFloat`: The time to begin doing actual animations
- `end_at1::AbstractFloat`: The time to end doing any animations
- `start_at2::AbstractFloat`: The time to begin doing actual animations
- `end_at2::AbstractFloat`: The time to end doing any animations
- `init_run::Function`: Function called on iterations prior to any actual animations
- `mid_run::Function`: Function called on iterations between the 2 timespans of actual animation
- `end_run::Function`: Function called on iterations after any actual animations
"""
function perform(
    actor::Function,
    t::AbstractFloat,
    start_at1::AbstractFloat, end_at1::AbstractFloat,
    start_at2::AbstractFloat, end_at2::AbstractFloat,
    init_run::Function, mid_run::Function, end_run::Function)

    if t < start_at1
        init_run()
    elseif t < end_at1
        actor(1)
    elseif t < start_at2
        mid_run()
    elseif t < end_at2
        actor(2)
    else
        end_run()
    end
end

"""
    perform(t, start_at, end_at, begin... end, begin... end) do ... end

Performs an animation based on elapsed time. Includes a cleaning function passing a boolean if action has performed.

# Arguments
- `actor::Function`: Function called to perform the animation
- `t::AbstractFloat`: The amount of time elapsed so far in the animation
- `start_at::AbstractFloat`: The time to begin doing actual animations
- `end_at::AbstractFloat`: The time to end doing any animations
- `init_run::Function`: Function called on iterations prior to any actual animations
- `end_run::Function`: Function called on iterations after any actual animations
"""
function perform(
    actor::Function,
    t::AbstractFloat,
    start_at::AbstractFloat, end_at::AbstractFloat,
    init_run::Function, end_run::Function)

    if t < start_at
        init_run()
    elseif t < end_at
        actor()
    else
        end_run()
    end
end

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
function draw_animation(doer::Function, chart::EuclidChartSpace, filename::String; duration=24, framerate=24)
    display_gif(record(doer, chart.f, filename, range(0,2π, step=2π/(duration*framerate)); framerate=framerate))
end
