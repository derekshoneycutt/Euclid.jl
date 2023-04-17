
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
function euclid_chart(; title::String="", xlims=(0,0), ylims=(0,0), bottom_label="https://derekshoneycutt.github.io/Euclid/")
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
    rowsize!(f.layout, 1, 500)
    colsize!(f.layout, 1, 600)

    EuclidChartSpace(f, ax)
end

"""
    euclid_chart3([title="", xlims=(0,0), ylims=(0,0), bottom_label="https://derekshoneycutt.github.io/Euclid/"])

Sets up a new chart space for drawing euclid diagrams

# Arguments
- `title::String`: The title to draw on the diagram
- `xlims`: The x limits of drawing : should be a 2-tuple of x limits
- `ylims`: The y limits of drawing : should be a 2-tupel of y limits
- `bottom_label`: The label to print at the bottom of the image
"""
function euclid_chart3(; title::String="", xlims=(0,0), ylims=(0,0), zlims=(0,0), bottom_label="https://derekshoneycutt.github.io/Euclid/")
    set_theme!(theme_dark())
    f = Figure()
    ax = euclid_axis3(f[1,1], title=title)
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
    rowsize!(f.layout, 1, 500)
    colsize!(f.layout, 1, 600)

    EuclidChartSpace(f, ax)
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

