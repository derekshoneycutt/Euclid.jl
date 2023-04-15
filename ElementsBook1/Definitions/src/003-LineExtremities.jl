
export EuclidLineHighlightExtremities, EuclidLine2fHighlightExtremities, EuclidLine3fHighlightExtremities, highlight_extremities, show_complete, hide, animate

"""
    EuclidLineHighlightExtremities{N}

Describes highlighting a line's extremities in a Euclid diagram
"""
mutable struct EuclidLineHighlightExtremities{N}
    baseOn::EuclidLine{N}
    extremity_A::EuclidPoint{N}
    highlight_A::EuclidPointHighlight{N}
    extremity_B::EuclidPoint{N}
    highlight_B::EuclidPointHighlight{N}
end
EuclidLine2fHighlightExtremities = EuclidLineHighlightExtremities{2}
EuclidLine3fHighlightExtremities = EuclidLineHighlightExtremities{3}

"""
    highlight_extremities(line[, point_width=0.02f0, point_color=:blue, text_color=:blue, text_opacity=1f0, labelA="A", labelB="B"])

Set up highlighting the extremities of a single line in a Euclid diagram

# Arguments
- `line::EuclidLine2f`: The line to highlight in the diagram
- `point_width::Union{Float32, Observable{Float32}}`: The width of the circle to draw the highlight
- `point_color`: The color to use in highlighting the line
- `text_color`: Color of the text to write the labels of the points with
- `text_opacity::Union{Float32, Observable{Float32}}`: The opacity to show the labels of the extremities with
- `labelA`: The label of the first extremity (in order they were created)
- `labelB`: The label of the second extremity
"""
function highlight_extremities(line::EuclidLine2f;
    point_width::Union{Float32, Observable{Float32}}=0.04f0, point_color=:blue,
    text_color=:blue, text_opacity::Union{Float32, Observable{Float32}}=1f0, labelA="A", labelB="B")

    extremity_A = point(line.extremityA,
                        point_width=point_width*0.001f0, point_color=point_color,
                        text_color=text_color, text_opacity=text_opacity,
                        label=labelA)
    highlight_A = highlight(extremity_A, width=point_width, color=point_color)
    extremity_B = point(line.extremityB,
                        point_width=point_width*0.001f0, point_color=point_color,
                        text_color=text_color, text_opacity=text_opacity,
                        label=labelB)
    highlight_B = highlight(extremity_B, width=point_width, color=point_color)

    EuclidLine2fHighlightExtremities(line, extremity_A, highlight_A, extremity_B, highlight_B)
end
function highlight_extremities(line::EuclidLine3f;
    point_width::Union{Float32, Observable{Float32}}=0.04f0, point_color=:blue,
    text_color=:blue, text_opacity::Union{Float32, Observable{Float32}}=1f0, labelA="A", labelB="B")

    extremity_A = point(line.extremityA,
                        point_width=point_width*0.001f0, point_color=point_color,
                        text_color=text_color, text_opacity=text_opacity,
                        label=labelA)
    highlight_A = highlight(extremity_A, width=point_width, color=point_color)
    extremity_B = point(line.extremityB,
                        point_width=point_width*0.001f0, point_color=point_color,
                        text_color=text_color, text_opacity=text_opacity,
                        label=labelB)
    highlight_B = highlight(extremity_B, width=point_width, color=point_color)

    EuclidLine3fHighlightExtremities(line, extremity_A, highlight_A, extremity_B, highlight_B)
end

"""
    show_complete(line)

Complete a previously defined highlight operation for a line's extremities in a Euclid diagram. It will be fully highlighted.

# Arguments
- `line::EuclidLineHighlightExtremities`: The description of the highlight to finish
"""
function show_complete(line::EuclidLineHighlightExtremities)
    show_complete(line.extremity_A)
    show_complete(line.highlight_A)
    show_complete(line.extremity_B)
    show_complete(line.highlight_B)
end

"""
    hide(line)

Hide highlights of a line's extremities in a Euclid diagram

# Arguments
- `line::EuclidLineHighlightExtremities`: The description of the highlight to completely hide
"""
function hide(line::EuclidLineHighlightExtremities)
    hide(line.extremity_A)
    hide(line.highlight_A)
    hide(line.extremity_B)
    hide(line.highlight_B)
end

"""
    animate(line, hide_until, max_at, min_at, t)

Animate highlighting a line's extremities in a Euclid diagram

# Arguments
- `line::EuclidLineHighlightExtremities`: The line to animate in the diagram
- `hide_until::AbstractFloat`: The time point to begin highlighting the line at
- `max_at::AbstractFloat`: The time point to have maximum highlight at
- `min_at::AbstractFloat`: The time point to finish going back to no more highlighting
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    line::EuclidLineHighlightExtremities, hide_until::AbstractFloat, max_at::AbstractFloat, min_at::AbstractFloat, t::AbstractFloat)

    max_time = max_at - hide_until
    animate(line.extremity_A, hide_until, hide_until + max_time/2f0, t, fade_start=max_at+0.0001, fade_end=min_at)
    animate(line.extremity_B, hide_until, hide_until + max_time/2f0, t, fade_start=max_at+0.0001, fade_end=min_at)
    animate(line.highlight_A, hide_until + max_time/2f0, max_at, min_at, t)
    animate(line.highlight_B, hide_until + max_time/2f0, max_at, min_at, t)
end
