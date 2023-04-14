
export EuclidPoint, EuclidPoint2f, EuclidPoint3f, point, show_complete, hide, animate

"""
    EuclidPoint{N<:Int64}

Describes a point to be drawn and animated in Euclid diagrams
"""
mutable struct EuclidPoint{N}
    data::Observable{Point{N, Float32}}
    plots
    current_point_width::Observable{Float32}
    show_point_width::Observable{Float32}
    label::EuclidText{N}
end

EuclidPoint2f = EuclidPoint{2}
EuclidPoint3f = EuclidPoint{3}

"""
    point(at_spot[, point_width=0.01f0, point_color=:blue, text_color=:blue, text_opacity=1f0, label="A"])

Sets up a new point in a Euclid Diagram for drawing

# Arguments
- `at_spot::Point2f`: The location of the point to draw
- `point_width::Union{Float32,Observable{Float32}}`: The width of the point to draw
- `point_color`: The color to draw the point with
- `text_color`: The color to draw the text of the point label with
- `text_opacity`: The opacity of the text label to draw
- `label`: The text label to draw on the point
- `show_label::Bool`: Whether to show the label of the point
"""
function point(at_spot::Observable{Point2f};
    point_width::Union{Float32,Observable{Float32}}=0.01f0, point_color=:blue,
    text_color=:blue, text_opacity=1f0, label="A")

    observable_data = at_spot
    observable_width = Observable(0f0)
    observable_show_width = point_width isa Observable{Float32} ? point_width : Observable(point_width)

    plots = poly!(@lift(Circle($observable_data, $observable_width)), color=point_color)
    use_label = text(at_spot, label, color=text_color, opacity=text_opacity)

    EuclidPoint{2}(observable_data, plots,
        observable_width, observable_show_width,
        use_label)
end


"""
    point(at_spot[, point_width=0.01f0, point_color=:blue, text_color=:blue, text_opacity=1f0, label="A"])

Sets up a new point in a Euclid Diagram for drawing

# Arguments
- `at_spot::Point2f`: The location of the point to draw
- `point_width::AbstractFloat`: The width of the point to draw
- `point_color`: The color to draw the point with
- `text_color`: The color to draw the text of the point label with
- `text_opacity::AbstractFloat`: The opacity of the text label to draw
- `label`: The text label to draw on the point
- `show_label::Bool`: Whether to show the label of the point
"""
function point(at_spot::Point2f;
    point_width::AbstractFloat=0.01f0, point_color=:blue,
    text_color=:blue, text_opacity::AbstractFloat=1f0, label="A")

    observable_data = Observable(at_spot)
    point(observable_data,
          point_width=point_width, point_color=point_color,
          text_color=text_color, text_opacity=text_opacity, label=label)
end

"""
    point(at_spot[, point_width=0.01f0, point_color=:blue, text_color=:blue, text_opacity=1f0, label="A"])

Sets up a new point in a Euclid Diagram for drawing

# Arguments
- `at_spot::Point3f`: The location of the point to draw
- `point_width::Union{Float32,Observable{Float32}}`: The width of the point to draw
- `point_color`: The color to draw the point with
- `text_color`: The color to draw the text of the point label with
- `text_opacity`: The opacity of the text label to draw
- `label`: The text label to draw on the point
- `show_label::Bool`: Whether to show the label of the point
"""
function point(at_spot::Observable{Point3f};
    point_width::Union{Float32,Observable{Float32}}=0.015f0, point_color=:blue,
    text_color=:blue, text_opacity=1f0, label="A")

    observable_data = at_spot
    observable_width = Observable(0f0)
    observable_show_width = point_width isa Observable{Float32} ? point_width : Observable(point_width)

    plots = mesh!(@lift(Sphere($observable_data, $observable_width)), color=point_color)
    use_label = text(at_spot, label, color=text_color, opacity=text_opacity)

    EuclidPoint{3}(observable_data, plots,
        observable_width, observable_show_width,
        use_label)
end


"""
    point(at_spot[, point_width=0.01f0, point_color=:blue, text_color=:blue, text_opacity=1f0, label="A"])

Sets up a new point in a Euclid Diagram for drawing

# Arguments
- `at_spot::Point3f`: The location of the point to draw
- `point_width::AbstractFloat`: The width of the point to draw
- `point_color`: The color to draw the point with
- `text_color`: The color to draw the text of the point label with
- `text_opacity::AbstractFloat`: The opacity of the text label to draw
- `label`: The text label to draw on the point
- `show_label::Bool`: Whether to show the label of the point
"""
function point(at_spot::Point3f;
    point_width::AbstractFloat=0.015f0, point_color=:blue,
    text_color=:blue, text_opacity::AbstractFloat=1f0, label="A")

    observable_data = Observable(at_spot)
    point(observable_data,
          point_width=point_width, point_color=point_color,
          text_color=text_color, text_opacity=text_opacity, label=label)
end

"""
    show_complete(point)

Completely show previously defined point in a Euclid diagram

# Arguments
- `point::EuclidPoint2f`: The point to completely show
"""
function show_complete(point::EuclidPoint)
    point.current_point_width[] = point.show_point_width[]
    show_complete(point.label)
end

"""
    hide(point)

Completely hide previously defined point in a Euclid diagram

# Arguments
- `point::EuclidPoint2f`: The point to completely hide
"""
function hide(point::EuclidPoint)
    point.current_point_width[] = 0f0
    hide(point.label)
end

"""
    animate(point, hide_until, max_at, t[, fade_start=0f0, fade_end=0f0])

Animate drawing and perhaps then hiding point drawn in a Euclid diagram

# Arguments
- `point::EuclidPoint2f`: The point to animate in the diagram
- `hide_until::AbstractFloat`: The point to hide the point until
- `max_at::AbstractFloat`: The time to max drawing the point at -- when it is fully drawn
- `t::AbstractFloat`: The current timeframe of the animation
- `fade_start::AbstractFloat`: When to begin fading the point away from the diagram
- `fade_end::AbstractFloat`: When to end fading the point awawy from the diagram -- it will be hidden entirely
"""
function animate(
    point::EuclidPoint, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
    fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)

    animate(point.label, hide_until, max_at, t, fade_start=fade_start, fade_end=fade_end)

    perform(t, hide_until, max_at, fade_start, fade_end,
        () -> point.current_point_width[] = 0f0,
        () -> point.current_point_width[] = point.show_point_width[],
        () -> point.current_point_width[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            point.current_point_width[] = point.show_point_width[] * on_t
        else
            on_t = (t-fade_start)/(fade_end-fade_start)
            point.current_point_width[] = point.show_point_width[] - (point.show_point_width[] * on_t)
        end
    end
end
