
export euclid_chart, euclid_legend

"""
    EuclidChartSpace2d

Describes a chart space for euclid diagrams
"""
mutable struct EuclidChartSpace2d
    f
    ax
end

"""
    euclid_chart([title="", xlims=(0,0), ylims=(0,0)])

Sets up a new chart space for drawing euclid diagrams

# Arguments
- `title::String`: The title to draw on the diagram
- `xlims`: The x limits of drawing : should be a 2-tuple of x limits
- `ylims`: The y limits of drawing : should be a 2-tupel of y limits
"""
function euclid_chart(; title::String="", xlims=(0,0), ylims=(0,0))
    set_theme!(theme_dark())
    f = Figure()
    ax = euclid_axis(f[1,1], title=title)
    if xlims[1] != 0 || xlims[2] != 0
        xlims!(ax, xlims[1], xlims[2])
    end
    if ylims[1] != 0 || ylims[2] != 0
        ylims!(ax, ylims[1], ylims[2])
    end

    EuclidChartSpace2d(f, ax)
end

"""
    euclid_legend(chart, icons, text)

Draw a legend on a Euclid diagram

# Arguments
- `chart::EuclidChartSpace2d`: The chart to draw the legend on
- `icons`: The vector of icons to draw for each string in the legend
- `texts`: The vector of texts to draw on the legend
"""
function euclid_legend(chart::EuclidChartSpace2d, icons, texts)
    axislegend(chart.ax, icons, texts)
end

