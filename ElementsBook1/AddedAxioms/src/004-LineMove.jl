
export EuclidLineMove, EuclidLine2fMove, EuclidLine3fMove, move, reset, show_complete, hide, animate

"""
    EuclidLineMove

Describes moving a line in a Euclid diagram
"""
mutable struct EuclidLineMove{N}
    baseOn::EuclidLine{N}
    begin_at::Observable{Point{N, Float32}}
    move_to::Observable{Point{N, Float32}}
    vector::Observable{Point{N, Float32}}
    movingA::Bool
end
EuclidLine2fMove = EuclidLineMove{2}
EuclidLine3fMove = EuclidLineMove{3}

"""
    move(line, new_spot[, begin_at, move_extremityA=true])

Set up a movement of a line on the Euclid diagram

# Arguments
- `line::EuclidLine`: The line to move in the diagram
- `new_spot::Point`: The new spot to move the line in the diagram to
- `move_extremityA::Bool`: Whether to move the line by dragging extremity A. Will move by extremity B if false.
- `begin_at::Union{Point, Observable{Point}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(line::EuclidLine2f, new_spot::Observable{Point2f};
    move_extremityA::Bool=true, begin_at::Union{Point2f, Observable{Point2f}}=line.extremityA)

    move_extremity = move_extremityA ? line.extremityA : line.extremityB
    alt_extremity = move_extremityA ? line.extremityB : line.extremityA
    v = @lift($(alt_extremity) - $(move_extremity))
    observable_begin = begin_at isa Observable{Point2f} ? Observable(begin_at[]) : Observable(begin_at)
    EuclidLine2fMove(line, observable_begin, new_spot, v, move_extremityA)
end
function move(line::EuclidLine2f, new_spot::Point2f;
    move_extremityA::Bool=true, begin_at::Union{Point2f, Observable{Point2f}}=line.extremityA)

    move(line, Observable(new_spot), move_extremityA=move_extremityA, begin_at=begin_at)
end
function move(line::EuclidLine3f, new_spot::Observable{Point3f};
    move_extremityA::Bool=true, begin_at::Union{Point3f, Observable{Point3f}}=line.extremityA)

    move_extremity = move_extremityA ? line.extremityA : line.extremityB
    alt_extremity = move_extremityA ? line.extremityB : line.extremityA
    v = @lift($(alt_extremity) - $(move_extremity))
    observable_begin = begin_at isa Observable{Point3f} ? Observable(begin_at[]) : Observable(begin_at)
    EuclidLine3fMove(line, observable_begin, new_spot, v, move_extremityA)
end
function move(line::EuclidLine3f, new_spot::Point3f;
    move_extremityA::Bool=true, begin_at::Union{Point3f, Observable{Point3f}}=line.extremityA)

    move(line, Observable(new_spot), move_extremityA=move_extremityA, begin_at=begin_at)
end

"""
    reset(move[, begin_at, move_to, move_extremityA=true])

Reset a movement animation for a line in a Euclid Diagram to new positions

# Arguments
- `move::EuclidLineMove`: The description of the move to reset
- `begin_at::Union{Point, Observable{Point}}`: The point to begin movements at in the diagram
- `move_to::Union{Point, Observable{Point}}`: The point to end movements to in the diagram
- `move_extremityA::Bool`: Whether to move the line by dragging extremity A. Will move by extremity B if false.
"""
function reset(move::EuclidLine2fMove;
    begin_at::Union{Point2f, Observable{Point2f}}=move.baseOn.extremityA,
    move_to::Union{Point2f, Observable{Point2f}}=move.move_to,
    move_extremityA::Bool=true)

    if begin_at isa Observable{Point2f}
        move.begin_at[] = begin_at[]
    else
        move.begin_at[] = begin_at
    end
    if move_to isa Observable{Point2f}
        move.move_to[] = move_to[]
    else
        move.move_to[] = move_to
    end
    move_extremity = move_extremityA ? line.extremityA : line.extremityB
    alt_extremity = move_extremityA ? line.extremityB : line.extremityA
    v = @lift($(alt_extremity) - $(move_extremity))
    move.vector[] = alt_extremity[] - move_extremity[]
    move.movingA = move_extremityA
end
function reset(move::EuclidLine3fMove;
    begin_at::Union{Point3f, Observable{Point3f}}=move.baseOn.extremityA,
    move_to::Union{Point3f, Observable{Point3f}}=move.move_to,
    move_extremityA::Bool=true)

    if begin_at isa Observable{Point3f}
        move.begin_at[] = begin_at[]
    else
        move.begin_at[] = begin_at
    end
    if move_to isa Observable{Point3f}
        move.move_to[] = move_to[]
    else
        move.move_to[] = move_to
    end
    move_extremity = move_extremityA ? line.extremityA : line.extremityB
    alt_extremity = move_extremityA ? line.extremityB : line.extremityA
    v = @lift($(alt_extremity) - $(move_extremity))
    move.vector[] = alt_extremity[] - move_extremity[]
    move.movingA = move_extremityA
end

"""
    show_complete(move)

Complete a previously defined move operation for a line in a Euclid diagram

# Arguments
- `move::EuclidLineMove`: The description of the move to finish moving
"""
function show_complete(move::EuclidLineMove)
    if move.movingA
        move.baseOn.extremityA[] = move.move_to[]
        move.baseOn.extremityB[] = move.move_to[] + move.vector[]
    else
        move.baseOn.extremityB[] = move.move_to[]
        move.baseOn.extremityA[] = move.move_to[] + move.vector[]
    end
end

"""
    hide(move)

Move a line in a Euclid diagram back to its starting position

# Arguments
- `move::EuclidLineMove`: The description of the move to "undo"
"""
function hide(move::EuclidLineMove)
    if move.movingA
        move.baseOn.extremityA[] = move.begin_at[]
        move.baseOn.extremityB[] = move.begin_at[] + move.vector[]
    else
        move.baseOn.extremityB[] = move.begin_at[]
        move.baseOn.extremityA[] = move.begin_at[] + move.vector[]
    end
end

"""
    animate(move, begin_move, end_move, t)

Animate moving a line drawn in a Euclid diagram

# Arguments
- `move::EuclidLineMove`: The line to animate in the diagram
- `begin_move::AbstractFloat`: The time point to begin moving the line at
- `end_move::AbstractFloat`: The time point to finish moving the line at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    move::EuclidLineMove,
    begin_move::AbstractFloat, end_move::AbstractFloat, t::AbstractFloat)


    begin_at = move.begin_at[]
    move_to = move.move_to[]
    v = move_to - begin_at
    norm_v = norm(v)
    u = v / norm_v

    line_vector = move.vector[]

    perform(t, begin_move, end_move,
         () -> nothing,
         () -> nothing) do

        on_t = ((t-begin_move)/(end_move-begin_move)) * norm_v
        if on_t > 0
            if move.movingA
                move.baseOn.extremityA[] = (begin_at + on_t * u)
                move.baseOn.extremityB[] = (begin_at + on_t * u) + line_vector
            else
                move.baseOn.extremityB[] = (begin_at + on_t * u)
                move.baseOn.extremityA[] = (begin_at + on_t * u) + line_vector
            end
        else
            if move.movingA
                move.baseOn.extremityA[] = move_to
                move.baseOn.extremityB[] = move_to + line_vector
            else
                move.baseOn.extremityB[] = move_to
                move.baseOn.extremityA[] = move_to + line_vector
            end
        end
    end
end
