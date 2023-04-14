
export EuclidLineHighlight, EuclidLine2fHighlight, EuclidLine3fHighlight, highlight, show_complete, hide, animate

"""
    EuclidLineHighlight

Describes highlighting a line in a Euclid diagram
"""
mutable struct EuclidLineHighlight{N}
    baseOn::EuclidLine{N}
    plots
    current_width::Observable{Float32}
    max_width::Observable{Float32}
end
EuclidLine2fHighlight = EuclidLineHighlight{2}
EuclidLine3fHighlight = EuclidLineHighlight{3}

"""
    highlight(line[, width=2f0, color=:red])

Set up highlighting a single line in a Euclid diagram

# Arguments
- `line::EuclidLine`: The line to highlight in the diagram
- `width::Union{Float32, Observable{Float32}}`: The width of the line to draw the highlight
- `color`: The color to use in highlighting the line
"""
function highlight(line::EuclidLine2f; width::Union{Float32, Observable{Float32}}=2f0, color=:red)

    observable_highlight = Observable(0f0)
    observable_max_width = width isa Observable{Float32} ? width : Observable(width)

    plots = lines!(@lift([$(line.extremityA), $(line.extremityB)]),
                    color=opacify(color, 0.6),
                    linewidth=observable_highlight)

    EuclidLine2fHighlight(line, plots, observable_highlight, observable_max_width)
end
function highlight(line::EuclidLine3f; width::Union{Float32, Observable{Float32}}=2f0, color=:red)

    observable_highlight = Observable(0f0)
    observable_max_width = width isa Observable{Float32} ? width : Observable(width)

    plots = lines!(@lift([$(line.extremityA), $(line.extremityB)]),
                    color=opacify(color, 0.6),
                    linewidth=observable_highlight)

    EuclidLine3fHighlight(line, plots, observable_highlight, observable_max_width)
end

"""
    show_complete(line)

Complete a previously defined highlight operation for a line in a Euclid diagram. It will be fully highlighted.

# Arguments
- `line::EuclidLineHighlight`: The description of the highlight to finish
"""
function show_complete(line::EuclidLineHighlight)
    line.current_width[] = line.max_width[]
end

"""
    hide(line)

Hide highlights of a line in a Euclid diagram

# Arguments
- `line::EuclidLineHighlight`: The description of the highlight to completely hide
"""
function hide(line::EuclidLineHighlight)
    line.current_width[] = 0f0
end

"""
    animate(line, hide_until, max_at, min_at, t)

Animate highlighting a line in a Euclid diagram

# Arguments
- `line::EuclidLineHighlight`: The line to animate in the diagram
- `hide_until::AbstractFloat`: The time point to begin highlighting the line at
- `max_at::AbstractFloat`: The time point to have maximum highlight at
- `min_at::AbstractFloat`: The time point to finish going back to no more highlighting
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    line::EuclidLineHighlight, hide_until::AbstractFloat, max_at::AbstractFloat, min_at::AbstractFloat, t::AbstractFloat)

    perform(t, hide_until, max_at, max_at + 0.00001, min_at,
        () -> line.current_width[] = 0f0,
        () -> line.current_width[] = line.max_width[],
        () -> line.current_width[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            line.current_width[] = line.max_width[] * on_t
        else
            on_t = (t-max_at)/(min_at-max_at)
            line.current_width[] = line.max_width[] - (line.max_width[] * on_t)
        end
    end
end
