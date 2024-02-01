
export EuclidRectilinealAngle, EuclidRectilinealAngle2f, EuclidRectilinealAngle3f,
    rectilineal_angle, highlight

"""
    EuclidRectilinealAngle

Describes highlighting a rectilineal angle in a Euclid diagram
"""
struct EuclidRectilinealAngle{N}
    baseOn::EuclidAngle{N}
    lineA::EuclidLine{N}
    lineB::EuclidLine{N}
    highlightA::EuclidStraightLine{N}
    highlightB::EuclidStraightLine{N}
end
EuclidRectilinealAngle2f = EuclidRectilinealAngle{2}
EuclidRectilinealAngle3f = EuclidRectilinealAngle{3}


"""
rectilineal_angle(angle, markers[, width=2f0, color=:red])

Set up highlighting a rectilineal angle in a Euclid diagram

# Arguments
- `angle::EuclidAngle`: The angle to highlight in the diagram
- `lineA::EuclidLine`: The first straight line to highlight
- `lineB::EuclidLine`: The second straight line to highlight
- `markers::Integer`: The number of markers to use in highlighting each straight line
- `color`: The color to use in highlighting the angle
"""
function rectilineal_angle(angle::EuclidAngle, lineA::EuclidLine, lineB::EuclidLine, markers::Integer;
        color=:red)

    highlightA = straight_line(lineA, markers, color=color)
    highlightB = straight_line(lineB, markers, color=color)

    EuclidRectilinealAngle(angle, lineA, lineB, highlightA, highlightB)
end


"""
    highlight(rectilineal, add_size, start_time, end_time)

Highlight points along straight lines of a rectilineal angle

# Arguments
- `rectilineal::EuclidRectilinealAngle`: The rectilineal angle figure defined
- `add_size::Float32`: The amount to add to the size of the points to highlight them
- `start_time::Float32`: The time during an animation to start animation
- `end_time::Float32`: The time during an animation to stop animation
"""
function highlight(rectilineal::EuclidRectilinealAngle, add_size::Float32,
        start_time::Float32, end_time::Float32)
    return [
        highlight(rectilineal.highlightA, add_size, start_time, end_time)...,
        highlight(rectilineal.highlightB, add_size, start_time, end_time)...
    ]
end