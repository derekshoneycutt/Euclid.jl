export extremities

"""
    extremities(line, labelA, labelB[, showtextA=false, showtextB=false])

Get points representing the extremities of a given line

# Arguments
- `line::EuclidLine{N}`: The line to get the extremities of
- `labelA::String`: The label for the A extremity
- `labelB::String`: The label for the B extremity
- `showtextA::Bool`: Whether to show the text for the A extremity; default false
- `showtextB::Bool`: Whether to show the text for the B extremity; default false
"""
function extremities(line::EuclidLine2f, labelA::String, labelB::String;
        showtextA::Bool=false, showtextB::Bool=false)
    extrems = Observables.@map(extremities(&(line.data)))
    A = point(labelA, Observables.@map((&extrems)[1]), showtext=showtextA)
    B = point(labelB, Observables.@map((&extrems)[2]), showtext=showtextB)
    return (A, B)
end
function extremities(line::EuclidLine3f, labelA::String, labelB::String;
        showtextA::Bool=false, showtextB::Bool=false)
    extrems = Observables.@map(extremities(&(line.data)))
    A = point(labelA, Observables.@map((&extrems)[1]), showtext=showtextA)
    B = point(labelB, Observables.@map((&extrems)[2]), showtext=showtextB)
    return (A, B)
end
