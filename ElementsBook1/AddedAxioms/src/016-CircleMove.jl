
export EuclidCircle2fMove, move, reset, show_complete, hide, animate

"""
EuclidCircle2fMove

Describes moving a circle in a Euclid diagram
"""
mutable struct EuclidCircle2fMove
    baseOn::EuclidCircle2f
    begin_at::Observable{Point2f}
    move_to::Observable{Point2f}
end

"""
    move(circle, new_spot[, begin_at, move_extremityA=true])

Set up a movement of a circle on the Euclid diagram

# Arguments
- `circle::EuclidCircle2f`: The circle to move in the diagram
- `new_spot::Point2f`: The new spot to move the circle in the diagram to
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(circle::EuclidCircle2f, new_spot::Observable{Point2f};
              begin_at::Union{Point2f, Observable{Point2f}}=circle.center)

    observable_begin = begin_at isa Observable{Point2f} ? Observable(begin_at[]) : Observable(begin_at)
    EuclidCircle2fMove(circle, observable_begin, new_spot)
end
function move(circle::EuclidCircle2f, new_spot::Point2f;
              begin_at::Union{Point2f, Observable{Point2f}}=circle.center)

    move(circle, Observable(new_spot), begin_at=begin_at)
end

"""
    reset(move[, begin_at, move_to, move_extremityA=true])

Reset a movement animation for a circle in a Euclid Diagram to new positions

# Arguments
- `move::EuclidCircle2fMove`: The description of the move to reset
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to begin movements at in the diagram
- `move_to::Union{Point2f, Observable{Point2f}}`: The point to end movements to in the diagram
"""
function reset(move::EuclidCircle2fMove;
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
end

"""
    show_complete(move)

Complete a previously defined move operation for a circle in a Euclid diagram

# Arguments
- `move::EuclidCircle2fMove`: The description of the move to finish moving
"""
function show_complete(move::EuclidCircle2fMove)
    move.baseOn.center[] = move.move_to[]
end

"""
    hide(move)

Move a circle in a Euclid diagram back to its starting position

# Arguments
- `move::EuclidCircle2fMove`: The description of the move to "undo"
"""
function hide(move::EuclidCircle2fMove)
    move.baseOn.center[] = move.begin_at[]
end

"""
    animate(move, begin_move, end_move, t)

Animate moving a circle drawn in a Euclid diagram

# Arguments
- `move::EuclidCircle2fMove`: The circle to animate in the diagram
- `begin_move::AbstractFloat`: The time point to begin moving the circle at
- `end_move::AbstractFloat`: The time point to finish moving the circle at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    move::EuclidCircle2fMove,
    begin_move::AbstractFloat, end_move::AbstractFloat, t::AbstractFloat)

    begin_at = move.begin_at[]
    move_to = move.move_to[]
    v = move_to - begin_at

    perform(t, begin_move, end_move,
         () -> nothing,
         () -> nothing) do

        on_t = ((t-begin_move)/(end_move-begin_move))
        if on_t > 0
            move.baseOn.center[] = begin_at + on_t * v
        else
            move.baseOn.center[] = move_to
        end
    end
end
