
export EuclidChartSpace, euclid_chart, euclid_chart3, euclid_legend

"""
    EuclidChartSpace

Describes a chart space for euclid diagrams
"""
mutable struct EuclidChartSpace
    f
    ax
end

"""
    euclid_chart([title="", xlims=(0,0), ylims=(0,0), bottom_label="https://derekshoneycutt.github.io/Euclid/"])

Sets up a new chart space for drawing euclid diagrams

# Arguments
- `title::String`: The title to draw on the diagram
- `xlims`: The x limits of drawing : should be a 2-tuple of x limits
- `ylims`: The y limits of drawing : should be a 2-tupel of y limits
- `bottom_label`: The label to print at the bottom of the image
"""
function euclid_chart(; title::String="", xlims=(-1,1), ylims=(-1,1), bottom_label="https://derekshoneycutt.github.io/Euclid/")
    set_theme!(theme_dark())
    f = Figure()
    ax = euclid_axis(f[1,1], title=title)
    if xlims[1] != 0 || xlims[2] != 0
        xlims!(ax, xlims[1], xlims[2])
    end
    if ylims[1] != 0 || ylims[2] != 0
        ylims!(ax, ylims[1], ylims[2])
    end

    Label(f[2,1], bottom_label, fontsize=10)
    rowsize!(f.layout, 2, 0)
    rowsize!(f.layout, 1, 350)
    colsize!(f.layout, 1, 600)

    EuclidChartSpace(f, ax)
end

"""
    euclid_chart3([title="", xlims=(-1,1), ylims=(-1,1), zlims(-1,1), azimuth=1.275π, elevation=π/8, bottom_label="https://derekshoneycutt.github.io/Euclid/"])

Sets up a new chart space for drawing euclid diagrams

# Arguments
- `title::String`: The title to draw on the diagram
- `xlims`: The x limits of drawing : should be a 2-tuple of x limits
- `ylims`: The y limits of drawing : should be a 2-tuple of y limits
- `zlims`: The z limits of drawing : should be a 2-tuple of z limits
- `azimuth`: The azimuth angle of the camera displaying the chart
- `elevation`: The elevation angle of the camera displaying the chart
- `bottom_label`: The label to print at the bottom of the image
"""
function euclid_chart3(;
        title::String="", xlims=(-1,1), ylims=(-1,1), zlims=(-1,1),
        azimuth::Float32=1.275f0π, elevation::Float32=π/8f0,
        bottom_label="https://derekshoneycutt.github.io/Euclid/")
    set_theme!(theme_dark())
    f = Figure()
    ax = euclid_axis3(f[1,1], title=title, azimuth=azimuth, elevation=elevation)
    if xlims[1] != 0 || xlims[2] != 0
        xlims!(ax, xlims[1], xlims[2])
    end
    if ylims[1] != 0 || ylims[2] != 0
        ylims!(ax, ylims[1], ylims[2])
    end
    if zlims[1] != 0 || zlims[2] != 0
        zlims!(ax, zlims[1], zlims[2])
    end

    Label(f[2,1], bottom_label, fontsize=10)
    rowsize!(f.layout, 2, 0)
    rowsize!(f.layout, 1, 325)
    colsize!(f.layout, 1, 550)

    EuclidChartSpace(f, ax)
end
"""
    euclid_chart3([title="", xlims=(-1,1), ylims=(-1,1), zlims(-1,1), azimuth=π/2, elevation=π/2, bottom_label="https://derekshoneycutt.github.io/Euclid/"])

Sets up a new chart space for drawing euclid diagrams, with the default camera angle at seeing the xy plane (alike 2D or birds eye)

# Arguments
- `title::String`: The title to draw on the diagram
- `xlims`: The x limits of drawing : should be a 2-tuple of x limits
- `ylims`: The y limits of drawing : should be a 2-tuple of y limits
- `zlims`: The z limits of drawing : should be a 2-tuple of z limits
- `azimuth`: The azimuth angle of the camera displaying the chart
- `elevation`: The elevation angle of the camera displaying the chart
- `bottom_label`: The label to print at the bottom of the image
"""
function euclid_chart3xy(;
        title::String="", xlims=(-1,1), ylims=(-1,1), zlims=(-1,1),
        azimuth::Float32=0.5f0π, elevation::Float32=0.5f0π,
        bottom_label="https://derekshoneycutt.github.io/Euclid/")
    euclid_chart3(title=title, xlims=xlims, ylims=ylims, zlims=zlims,
        azimuth=azimuth, elevation=elevation, bottom_label=bottom_label)
end

"""
    euclid_legend(chart, icons, text)

Draw a legend on a Euclid diagram

# Arguments
- `chart::EuclidChartSpace`: The chart to draw the legend on
- `icons`: The vector of icons to draw for each string in the legend
- `texts`: The vector of texts to draw on the legend
"""
function euclid_legend(chart::EuclidChartSpace, icons, texts)
    axislegend(chart.ax, icons, texts)
end

