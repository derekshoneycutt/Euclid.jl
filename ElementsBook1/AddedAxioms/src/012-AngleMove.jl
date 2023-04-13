
export EuclidAngle2fMove, move, reset, show_complete, hide, animate

"""
    EuclidAngle2fMove

Describes moving a plane angle in a Euclid diagram
"""
mutable struct EuclidAngle2fMove
    baseOn::EuclidAngle2f
    begin_at::Observable{Point2f}
    move_to::Observable{Point2f}
    vectorA::Observable{Point2f}
    vectorB::Observable{Point2f}
end

"""
    move(angle, new_spot[, begin_at, move_extremityA=true])

Set up a movement of a plane angle on the Euclid diagram

# Arguments
- `angle::EuclidAngle2f`: The angle to move in the diagram
- `new_spot::Point2f`: The new spot to move the angle in the diagram to
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(angle::EuclidAngle2f, new_spot::Observable{Point2f};
              begin_at::Union{Point2f, Observable{Point2f}}=angle.point)

    vectorA = @lift($(angle.extremityA) - $(angle.point))
    vectorB = @lift($(angle.extremityB) - $(angle.point))
    observable_begin = begin_at isa Observable{Point2f} ? Observable(begin_at[]) : Observable(begin_at)
    EuclidAngle2fMove(angle, observable_begin, new_spot, vectorA, vectorB)
end

"""
    move(angle, new_spot[, begin_at, move_extremityA=true])

Set up a movement of a plane angle on the Euclid diagram

# Arguments
- `angle::EuclidAngle2f`: The angle to move in the diagram
- `new_spot::Point2f`: The new spot to move the angle in the diagram to
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(angle::EuclidAngle2f, new_spot::Point2f;
              begin_at::Union{Point2f, Observable{Point2f}}=angle.point)

    move(angle, Observable(new_spot), begin_at=begin_at)
end

"""
    reset(move[, begin_at, move_to, move_extremityA=true])

Reset a movement animation for a angle in a Euclid Diagram to new positions

# Arguments
- `move::EuclidAngle2fMove`: The description of the move to reset
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to begin movements at in the diagram
- `move_to::Union{Point2f, Observable{Point2f}}`: The point to end movements to in the diagram
"""
function reset(move::EuclidAngle2fMove;
               begin_at::Union{Point2f, Observable{Point2f}}=move.baseOn.point,
               move_to::Union{Point2f, Observable{Point2f}}=move.move_to)

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
    move.vectorA[] = @lift($(angle.extremityA) - $(angle.point))
    move.vectorB[] = @lift($(angle.extremityB) - $(angle.point))
end

"""
    show_complete(move)

Complete a previously defined move operation for a angle in a Euclid diagram

# Arguments
- `move::EuclidAngle2fMove`: The description of the move to finish moving
"""
function show_complete(move::EuclidAngle2fMove)
    move.baseOn.point[] = move.move_to[]
    move.baseOn.extremityA[] = move.move_to[] + move.vectorA[]
    move.baseOn.extremityB[] = move.move_to[] + move.vectorB[]
end

"""
    hide(move)

Move a angle in a Euclid diagram back to its starting position

# Arguments
- `move::EuclidAngle2fMove`: The description of the move to "undo"
"""
function hide(move::EuclidAngle2fMove)
    move.baseOn.point[] = move.begin_at[]
    move.baseOn.extremityA[] = move.begin_at[] + move.vectorA[]
    move.baseOn.extremityB[] = move.begin_at[] + move.vectorB[]
end

"""
    animate(move, begin_move, end_move, t)

Animate moving a angle drawn in a Euclid diagram

# Arguments
- `move::EuclidAngle2fMove`: The angle to animate in the diagram
- `begin_move::AbstractFloat`: The time point to begin moving the angle at
- `end_move::AbstractFloat`: The time point to finish moving the angle at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    move::EuclidAngle2fMove,
    begin_move::AbstractFloat, end_move::AbstractFloat, t::AbstractFloat)

    begin_at = move.begin_at[]
    move_to = move.move_to[]
    v = move_to - begin_at
    norm_v = norm(v)
    u = v / norm_v

    line_vectorA = move.vectorA[]
    line_vectorB = move.vectorB[]

    perform(t, begin_move, end_move,
         () -> nothing,
         () -> nothing) do

        on_t = ((t-begin_move)/(end_move-begin_move)) * norm_v
        if on_t > 0
            x,y = begin_at + on_t * u
            move.baseOn.point[] = Point2f0(x, y)
            move.baseOn.extremityA[] = Point2f0(x, y) + line_vectorA
            move.baseOn.extremityB[] = Point2f0(x, y) + line_vectorB
        else
            move.baseOn.point[] = move_to
            move.baseOn.extremityA[] = move_to + line_vectorA
            move.baseOn.extremityB[] = move_to + line_vectorB
        end
    end
end
