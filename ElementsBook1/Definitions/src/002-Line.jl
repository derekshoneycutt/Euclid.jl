
export EuclidLine, EuclidLine2f, EuclidLine3f, line, show_complete, hide, animate

"""
    EuclidLine{N}

Describes a line to be drawn and animated in Euclid diagrams
"""
mutable struct EuclidLine{N}
    extremityA::Observable{Point{N, Float32}}
    extremityB::Observable{Point{N, Float32}}
    plots
    current_width::Observable{Float32}
    show_width::Observable{Float32}
end
EuclidLine2f = EuclidLine{2}
EuclidLine3f = EuclidLine{3}

"""
    line(extremityA, extremityB[, width=1f0, color=:blue])

Sets up a new line in a Euclid Diagram for drawing

# Arguments
- `extremityA::Observable{Point2f}`: The location of one extremity of the line to draw
- `extremityB::Observable{Point2f}`: The location of a second extremity of a line to draw
- `width::Union{Float32, Observable{Float32}}`: The width of the line to draw
- `color`: The color to draw the line with
"""
function line(extremityA::Observable{Point2f}, extremityB::Observable{Point2f};
              width::Union{Float32, Observable{Float32}}=1f0, color=:blue, linestyle=:solid)

    observable_width = Observable(0f0)
    observable_show_width = width isa Observable{Float32} ? width : Observable(width)

    plots = lines!(@lift([$extremityA, $extremityB]),
                   color=color, linewidth=(observable_width), linestyle=linestyle)

    EuclidLine2f(extremityA, extremityB, plots,
        observable_width, observable_show_width)
end
function line(extremityA::Observable{Point3f}, extremityB::Observable{Point3f};
              width::Union{Float32, Observable{Float32}}=0.01f0, color=:blue)

    observable_width = Observable(0f0)
    observable_show_width = width isa Observable{Float32} ? width : Observable(width)

    plots = mesh!(@lift(Cylinder($extremityA, $extremityB, $observable_width)),
                   color=color)

    EuclidLine3f(extremityA, extremityB, plots,
                 observable_width, observable_show_width)
end
function line(extremityA::Point2f, extremityB::Point2f;
              width::Union{Float32, Observable{Float32}}=1f0, color=:blue, linestyle=:solid)

    line(Observable(extremityA), Observable(extremityB), width=width, color=color, linestyle=linestyle)
end
function line(extremityA::Point3f, extremityB::Point3f;
              width::Union{Float32, Observable{Float32}}=1f0, color=:blue, linestyle=:solid)

    line(Observable(extremityA), Observable(extremityB), width=width, color=color, linestyle=linestyle)
end
function line(extremityA::Observable{Point2f}, extremityB::Point2f;
              width::Union{Float32, Observable{Float32}}=1f0, color=:blue, linestyle=:solid)

    line(extremityA, Observable(extremityB), width=width, color=color, linestyle=linestyle)
end
function line(extremityA::Observable{Point3f}, extremityB::Point3f;
              width::Union{Float32, Observable{Float32}}=0.01f0, color=:blue)

    line(extremityA, Observable(extremityB), width=width, color=color)
end
function line(extremityA::Point2f, extremityB::Observable{Point2f};
              width::AbstractFloat=0.01f0, color=:blue)

    line(Observable(extremityA), extremityB, width=width, color=color)
end
function line(extremityA::Point3f, extremityB::Observable{Point3f};
              width::AbstractFloat=0.01f0, color=:blue)

    line(Observable(extremityA), extremityB, width=width, color=color)
end

"""
    show_complete(line)

Completely show previously defined line in a Euclid diagram

# Arguments
- `line::EuclidLine`: The line to completely show
"""
function show_complete(line::EuclidLine)
    line.current_width[] = line.show_width[]
end

"""
    hide(line)

Completely hide previously defined line in a Euclid diagram

# Arguments
- `line::EuclidLine`: The line to completely hide
"""
function hide(line::EuclidLine)
    line.current_width[] = 0f0
end

"""
    animate(line, hide_until, max_at, t[, fade_start=0f0, fade_end=0f0])

Animate drawing and perhaps then hiding line drawn in a Euclid diagram

# Arguments
- `line::EuclidLine`: The line to animate in the diagram
- `hide_until::AbstractFloat`: The point to hide the line until
- `max_at::AbstractFloat`: The time to max drawing the line at -- when it is fully drawn
- `t::AbstractFloat`: The current timeframe of the animation
- `fade_start::AbstractFloat`: When to begin fading the line away from the diagram
- `fade_end::AbstractFloat`: When to end fading the line awawy from the diagram -- it will be hidden entirely
"""
function animate(line::EuclidLine, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                 fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)

    perform(t, hide_until, max_at, fade_start, fade_end,
        () -> line.current_width[] = 0f0,
        () -> line.current_width[] = line.show_width[],
        () -> line.current_width[] = 0f0) do i
        if i == 1
            on_t = (t-hide_until)/(max_at-hide_until)
            line.current_width[] = line.show_width[] * on_t
        else
            on_t = (t-fade_start)/(fade_end-fade_start)
            line.current_width[] = line.show_width[]- (line.show_width[] * on_t)
        end
    end
end
