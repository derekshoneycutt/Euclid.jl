
export EuclidSurfaceHighlightExtremities, EuclidSurface2fHighlightExtremities, EuclidSurface3fHighlightExtremities, highlight_extremities, show_complete, hide, animate

"""
    EuclidSurfaceHighlightExtremities

Describes highlighting a surface's extremities in a Euclid diagram
"""
mutable struct EuclidSurfaceHighlightExtremities{N}
    baseOn::EuclidSurface{N}
    extremities::Observable{Vector{EuclidLine{N}}}
    highlights::Observable{Vector{EuclidLineHighlight{N}}}
end
EuclidSurface2fHighlightExtremities = EuclidSurfaceHighlightExtremities{2}
EuclidSurface3fHighlightExtremities = EuclidSurfaceHighlightExtremities{3}

"""
    highlight_extremities(surface[, point_width=0.02f0, point_color=:blue, text_color=:blue, text_opacity=1f0, labelA="A", labelB="B"])

Set up highlighting the extremities of a single surface in a Euclid diagram

# Arguments
- `surface::EuclidSurface`: The surface to highlight in the diagram
- `width::Union{Float32, Observable{Float32}}`: The width of the highlight to draw
- `color`: The color to use in highlighting the surface extremities
"""
function highlight_extremities(surface::EuclidSurface2f;
                               width::Union{Float32, Observable{Float32}}=2f0, color=:blue)

    observable_width = width isa Observable ? width : Observable(width)
    true_line_width = @lift($observable_width * 0.001f0)

    extremities = @lift([line(x, ($(surface.from_points))[i < length($(surface.from_points)) ? i + 1 : 1],
                              width=true_line_width, color=color)
                            for (i,x) in enumerate($(surface.from_points))])
    highlights = @lift([highlight(x, width=observable_width, color=color)
                            for x in $extremities])

    EuclidSurface2fHighlightExtremities(surface, extremities, highlights)
end
function highlight_extremities(surface::EuclidSurface3f;
                               width::Union{Float32, Observable{Float32}}=2f0, color=:blue)

    observable_width = width isa Observable ? width : Observable(width)
    true_line_width = @lift($observable_width * 0.001f0)

    extremities = @lift([line(x, ($(surface.from_points))[i < length($(surface.from_points)) ? i + 1 : 1],
                              width=true_line_width, color=color)
                            for (i,x) in enumerate($(surface.from_points))])
    highlights = @lift([highlight(x, width=observable_width, color=color)
                            for x in $extremities])

    EuclidSurface3fHighlightExtremities(surface, extremities, highlights)
end

"""
    show_complete(surface)

Complete a previously defined highlight operation for a surface's extremities in a Euclid diagram. It will be fully highlighted.

# Arguments
- `surface::EuclidSurfaceHighlightExtremities`: The description of the highlight to finish
"""
function show_complete(surface::EuclidSurfaceHighlightExtremities)
    for x in surface.extremities[]
        show_complete(x)
    end
    for x in surface.highlights[]
        show_complete(x)
    end
end

"""
    hide(surface)

Hide highlights of a surface's extremities in a Euclid diagram

# Arguments
- `surface::EuclidSurfaceHighlightExtremities`: The description of the highlight to completely hide
"""
function hide(surface::EuclidSurfaceHighlightExtremities)
    for x in surface.extremities[]
        hide(x)
    end
    for x in surface.highlights[]
        hide(x)
    end
end

"""
    animate(surface, hide_until, max_at, min_at, t)

Animate highlighting a surface's extremities in a Euclid diagram

# Arguments
- `surface::EuclidSurfaceHighlightExtremities`: The surface to animate in the diagram
- `hide_until::AbstractFloat`: The time point to begin highlighting the surface at
- `max_at::AbstractFloat`: The time point to have maximum highlight at
- `min_at::AbstractFloat`: The time point to finish going back to no more highlighting
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(surface::EuclidSurfaceHighlightExtremities, hide_until::AbstractFloat,
                 max_at::AbstractFloat, min_at::AbstractFloat, t::AbstractFloat)

    max_time = max_at - hide_until
    for x in surface.extremities[]
        animate(x, hide_until, hide_until + max_time/2f0, t, fade_start=max_at+0.0001, fade_end=min_at)
    end
    for x in surface.highlights[]
        animate(x, hide_until, max_at, min_at, t)
    end
end
