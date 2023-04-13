
export EuclidSurface2f, just_surface, show_complete, hide, animate

"""
    EuclidSurface2f

Describes a surface to be drawn and animated in Euclid diagrams
"""
mutable struct EuclidSurface2f
    from_points::Observable{Vector{Point2f}}
    plots
    current_opacity::Observable{Float32}
    show_opacity::Observable{Float32}
end



"""
    just_surface(points[, color=:blue, opacity=1f0])

Sets up a new surface in a Euclid Diagram for drawing, only drawing the surface itself

# Arguments
- `points::Observable{Vector{Point2f}}`: The points to draw the surface within
- `color`: The color to draw the line with
- `opacity::Union{Float32, Observable{Float32}}`: The opacity to show the surface at
"""
function just_surface(points::Observable{Vector{Point2f}};
                      color=:blue, opacity::Union{Float32,Observable{Float32}}=1f0)

    observable_opacity = Observable(0f0)
    observable_show_opacity = opacity isa Observable{Float32} ?
                              opacity :
                              Observable(opacity)

    use_color = get_color(color)
    plots = poly!(points, color=@lift(RGBA(use_color.r, use_color.g, use_color.b, $observable_opacity)),
                  strokewidth=0f0)

    EuclidSurface2f(points, plots,
                    observable_opacity, observable_show_opacity)
end


"""
    just_surface(points[, color=:blue, opacity=1f0])

Sets up a new surface in a Euclid Diagram for drawing, only drawing the surface itself

# Arguments
- `points::Vector{Point2f}`: The points to draw the surface within
- `color`: The color to draw the line with
- `opacity::Union{Float32, Observable{Float32}}`: The opacity to show the surface at
"""
function just_surface(points::Vector{Point2f};
                      color=:blue, opacity::Union{Float32,Observable{Float32}}=1f0)

    just_surface(Observable(points),
                 color=color, opacity=opacity)
end


"""
    show_complete(surface)

Completely show previously defined surface in a Euclid diagram

# Arguments
- `surface::EuclidSurface2f`: The surface to completely show
"""
function show_complete(surface::EuclidSurface2f)
    surface.current_opacity[] = surface.show_opacity[]
end

"""
    hide(surface)

Completely hide previously defined surface in a Euclid diagram

# Arguments
- `surface::EuclidSurface2f`: The surface to completely hide
"""
function hide(surface::EuclidSurface2f)
    surface.current_opacity[] = 0f0
end

"""
    animate(surface, hide_until, max_at, t[, fade_start=0f0, fade_end=0f0])

Animate drawing and perhaps then hiding surface drawn in a Euclid diagram

# Arguments
- `surface::EuclidSurface2f`: The surface to animate in the diagram
- `hide_until::AbstractFloat`: The point to hide the surface until
- `max_at::AbstractFloat`: The time to max drawing the surface at -- when it is fully drawn
- `t::AbstractFloat`: The current timeframe of the animation
- `fade_start::AbstractFloat`: When to begin fading the surface away from the diagram
- `fade_end::AbstractFloat`: When to end fading the surface awawy from the diagram -- it will be hidden entirely
"""
function animate(
    surface::EuclidSurface2f, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
    fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)

    perform(t, hide_until, max_at, fade_start, fade_end,
        () -> surface.current_opacity[] = 0f0,
        () -> surface.current_opacity[] = surface.show_opacity[],
        () -> surface.current_opacity[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            surface.current_opacity[] = surface.show_opacity[] * on_t
        else
            on_t = (t-fade_start)/(fade_end-fade_start)
            surface.current_opacity[] = surface.show_opacity[]- (surface.show_opacity[] * on_t)
        end
    end
end
