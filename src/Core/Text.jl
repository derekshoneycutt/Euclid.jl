
export EuclidText, text, show_complete, hide, animate

"""
    EuclidText2f

Describes text to be drawn in Euclid diagrams
"""
struct EuclidText{N<:Int64}
    location::Observable{Point{N, Float32}}
    plots
    current_opacity::Observable{Float32}
    show_opacity::Observable{Float32}
end

"""
    text(at_spot, text[, color=:blue, opacity=1f0])

Create text to draw in a Euclid diagram

# Arguments
- `at_spot::Observable{Point2f}`: Point to draw text at
- `text`: The text to draw
- `color`: The color to draw the text in
- `opacity::Union{Float32,Observable{Float32}}`: Maximum opacity of the text to draw
"""
function text(at_spot::Observable{Point2f}, text;
    color=:blue, opacity::Union{Float32,Observable{Float32}}=1f0)

    observable_location = at_spot
    observable_opacity = Observable(0f0)
    observable_show_opacity = opacity isa Observable{Float32} ? opacity : Observable(opacity)

    rgb_text = get_color(color)
    plots = text!(observable_location, text=text, color=@lift(RGBA(rgb_text.r, rgb_text.g, rgb_text.b, $observable_opacity)))

    EuclidText{2}(observable_location, plots,
        observable_opacity, observable_show_opacity)
end

"""
    text(at_spot, text[, color=:blue, opacity=1f0])

Create text to draw in a 3D Euclid diagram

# Arguments
- `at_spot::Observable{Point3f}`: Point to draw text at
- `text`: The text to draw
- `color`: The color to draw the text in
- `opacity::Union{Float32,Observable{Float32}}`: Maximum opacity of the text to draw
"""
function text(at_spot::Observable{Point3f}, text;
    color=:blue, opacity::Union{Float32,Observable{Float32}}=1f0)

    observable_location = at_spot
    observable_opacity = Observable(0f0)
    observable_show_opacity = opacity isa Observable{Float32} ? opacity : Observable(opacity)

    rgb_text = get_color(color)
    plots = text!(observable_location, text=text, color=@lift(RGBA(rgb_text.r, rgb_text.g, rgb_text.b, $observable_opacity)))

    EuclidText{3}(observable_location, plots,
        observable_opacity, observable_show_opacity)
end

"""
    text(at_spot, text[, color=:blue, opacity=1f0])

Create text to draw in a Euclid diagram

# Arguments
- `at_spot::Point2f`: Point to draw text at
- `text`: The text to draw
- `color`: The color to draw the text in
- `opacity::Float32`: Maximum opacity of the text to draw
"""
function text(at_spot::Point2f, text; color=:blue, opacity::Float32=1f0)
    text(Observable(at_spot), Observable(text), color=color, opacity=opacity)
end

"""
    text(at_spot, text[, color=:blue, opacity=1f0])

Create text to draw in a 3D Euclid diagram

# Arguments
- `at_spot::Point3f`: Point to draw text at
- `text`: The text to draw
- `color`: The color to draw the text in
- `opacity::Float32`: Maximum opacity of the text to draw
"""
function text(at_spot::Point3f, text; color=:blue, opacity::Float32=1f0)
    text(Observable(at_spot), Observable(text), color=color, opacity=opacity)
end


"""
    show_complete(text)

Completely show previously defined text in a Euclid diagram

# Arguments
- `text::EuclidText2f`: The text to completely show
"""
function show_complete(text::EuclidText)
    text.current_opacity[] = text.show_opacity[]
end

"""
    hide(text)

Completely hide previously defined text in a Euclid diagram

# Arguments
- `text::EuclidText2f`: The text to completely hide
"""
function hide(text::EuclidText)
    text.current_opacity[] = 0f0
end

"""
    animate(text, hide_until, max_at, t[, fade_start=0f0, fade_end=0f0])

Animate drawing and perhaps then hiding text drawn in a Euclid diagram

# Arguments
- `text::EuclidText2f`: The text to animate in the diagram
- `hide_until::AbstractFloat`: The point to hide the text until
- `max_at::AbstractFloat`: The time to max drawing the text at -- when it is fully drawn
- `t::AbstractFloat`: The current timeframe of the animation
- `fade_start::AbstractFloat`: When to begin fading the text away from the diagram
- `fade_end::AbstractFloat`: When to end fading the text awawy from the diagram -- it will be hidden entirely
"""
function animate(
    text::EuclidText, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
    fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)

    perform(t, hide_until, max_at, fade_start, fade_end,
        () -> text.current_opacity[] = 0f0,
        () -> text.current_opacity[] = text.show_opacity[],
        () -> text.current_opacity[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            text.current_opacity[] = text.show_opacity[] * on_t
        else
            on_t = (t-fade_start)/(fade_end-fade_start)
            text.current_opacity[] = text.show_opacity[] - (text.show_opacity[] * on_t)
        end
    end
end
