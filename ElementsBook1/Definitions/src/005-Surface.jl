
export EuclidSurface, EuclidSurface2f, EuclidSurface3f, plane_surface, show_complete, hide, animate

"""
    EuclidSurface

Describes a surface to be drawn and animated in Euclid diagrams
"""
mutable struct EuclidSurface{N}
    from_points::Observable{Vector{Point{N, Float32}}}
    plots
    current_opacity::Observable{Float32}
    show_opacity::Observable{Float32}
    mesh::Observable
end
EuclidSurface2f = EuclidSurface{2}
EuclidSurface3f = EuclidSurface{3}



"""
plane_surface(points[, color=:blue, opacity=1f0])

Sets up a new surface in a Euclid Diagram for drawing, only drawing the surface itself

# Arguments
- `points::Observable{Vector{Point2f}}`: The points to draw the surface within
- `color`: The color to draw the line with
- `opacity::Union{Float32, Observable{Float32}}`: The opacity to show the surface at
"""
function plane_surface(points::Observable{Vector{Point2f}};
                      color=:blue, opacity::Union{Float32,Observable{Float32}}=1f0)

    observable_opacity = Observable(0f0)
    observable_show_opacity = opacity isa Observable{Float32} ?
                              opacity :
                              Observable(opacity)

    plots = poly!(points, color=@lift(opacify(color, $observable_opacity)),
                  strokewidth=0f0)

    EuclidSurface2f(points, plots,
                    observable_opacity, observable_show_opacity,
                    Observable(nothing))
end
function plane_surface(points::Vector{Point2f};
                      color=:blue, opacity::Union{Float32,Observable{Float32}}=1f0)

    plane_surface(Observable(points),
                 color=color, opacity=opacity)
end
function plane_surface(points::Observable{Vector{Point3f}};
                      color=:blue, opacity::Union{Float32,Observable{Float32}}=1f0)

    observable_opacity = Observable(0f0)
    observable_show_opacity = opacity isa Observable{Float32} ?
                              opacity :
                              Observable(opacity)

    mesh =
        if length(points[]) == 4
            @lift(GeometryBasics.Mesh($points, [2,3,1,4]))
        else
            @lift(GeometryBasics.mesh($points))
        end
    plots = mesh!(mesh, color=@lift([opacify(color, $observable_opacity) for i in 1:length($points)]))

    EuclidSurface3f(points, plots,
                    observable_opacity, observable_show_opacity, mesh)
end
function plane_surface(points::Vector{Point3f};
                      color=:blue, opacity::Union{Float32,Observable{Float32}}=1f0)

    plane_surface(Observable(points),
                 color=color, opacity=opacity)
end


"""
    show_complete(surface)

Completely show previously defined surface in a Euclid diagram

# Arguments
- `surface::EuclidSurface`: The surface to completely show
"""
function show_complete(surface::EuclidSurface)
    surface.current_opacity[] = surface.show_opacity[]
end

"""
    hide(surface)

Completely hide previously defined surface in a Euclid diagram

# Arguments
- `surface::EuclidSurface`: The surface to completely hide
"""
function hide(surface::EuclidSurface)
    surface.current_opacity[] = 0f0
end

"""
    animate(surface, hide_until, max_at, t[, fade_start=0f0, fade_end=0f0])

Animate drawing and perhaps then hiding surface drawn in a Euclid diagram

# Arguments
- `surface::EuclidSurface`: The surface to animate in the diagram
- `hide_until::AbstractFloat`: The point to hide the surface until
- `max_at::AbstractFloat`: The time to max drawing the surface at -- when it is fully drawn
- `t::AbstractFloat`: The current timeframe of the animation
- `fade_start::AbstractFloat`: When to begin fading the surface away from the diagram
- `fade_end::AbstractFloat`: When to end fading the surface awawy from the diagram -- it will be hidden entirely
"""
function animate(
    surface::EuclidSurface, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
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
