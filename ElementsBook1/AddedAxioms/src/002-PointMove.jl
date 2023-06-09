
export EuclidPointMove, EuclidPoint2fMove, EuclidPoint3fMove, move, reset, show_complete, hide, animate

"""
    EuclidPoint2fMove

Describes moving a point in a Euclid diagram
"""
mutable struct EuclidPointMove{N}
    baseOn::EuclidPoint{N}
    begin_at::Observable{Point{N, Float32}}
    move_to::Observable{Point{N, Float32}}
    move_text::EuclidTextMove{N}
end
EuclidPoint2fMove = EuclidPointMove{2}
EuclidPoint3fMove = EuclidPointMove{3}

"""
    move(point, new_spot[, begin_at])

Set up a movement of point on the Euclid diagram

# Arguments
- `point::EuclidPoint2f`: The point to move in the diagram
- `new_spot::Observable{Point2f}`: The new spot to move the point in the diagram to
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(point::EuclidPoint2f, new_spot::Observable{Point2f};
                begin_at::Union{Point2f, Observable{Point2f}}=point.data)

    observable_begin = begin_at isa Observable{Point2f} ? Observable(begin_at[]) : Observable(begin_at)
    EuclidPoint2fMove(point, observable_begin, new_spot, move(point.label, new_spot, begin_at = begin_at))
end
function move(point::EuclidPoint3f, new_spot::Observable{Point3f};
                begin_at::Union{Point3f, Observable{Point3f}}=point.data)

    observable_begin = begin_at isa Observable{Point3f} ? Observable(begin_at[]) : Observable(begin_at)
    EuclidPoint3fMove(point, observable_begin, new_spot, move(point.label, new_spot, begin_at = begin_at))
end

"""
    move(point, new_spot[, begin_at])

Set up a movement of point on the Euclid diagram

# Arguments
- `point::EuclidPoint2f`: The point to move in the diagram
- `new_spot::Point2f`: The new spot to move the point in the diagram to
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(point::EuclidPoint2f, new_spot::Point2f;
                begin_at::Union{Point2f, Observable{Point2f}}=point.data)
    move(point, Observable(new_spot), begin_at=begin_at)
end
function move(point::EuclidPoint3f, new_spot::Point3f;
                begin_at::Union{Point3f, Observable{Point3f}}=point.data)
    move(point, Observable(new_spot), begin_at=begin_at)
end

"""
    reset(move[, begin_at, move_to])

Reset a movement animation for a point in a Euclid Diagram to new positions

Does not move the text

# Arguments
- `move::EuclidPoint2fMove`: The description of the move to reset
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to begin movements at in the diagram
- `move_to::Union{Point2f, Observable{Point2f}}`: The point to end movements to in the diagram
"""
function reset(move::EuclidPoint2fMove;
    begin_at::Union{Point2f, Observable{Point2f}}=move.baseOn.data,
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
    reset(move.move_text, begin_at=begin_at, move_to=move_to)
end
function reset(move::EuclidPoint3fMove;
    begin_at::Union{Point3f, Observable{Point3f}}=move.baseOn.data,
    move_to::Union{Point3f, Observable{Point3f}}=move.move_to)

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
    reset(move.move_text, begin_at=begin_at, move_to=move_to)
end

"""
    show_complete(move)

Complete a previously defined move operation for a point in a Euclid diagram

# Arguments
- `move::EuclidPointMove`: The description of the move to finish moving
"""
function show_complete(move::EuclidPointMove)
    move.baseOn.data[] = move.move_to[]
    show_complete(move.move_text)
end

"""
    hide(move)

Move a point in a Euclid diagram back to its starting position

# Arguments
- `move::EuclidPointMove`: The description of the move to "undo"
"""
function hide(move::EuclidPointMove)
    point.baseOn.data[] = move.begin_at[]
    hide(move.move_text)
end

"""
    animate(move, begin_move, end_move, t)

Animate moving a point drawn in a Euclid diagram

# Arguments
- `move::EuclidPointMove`: The point to animate in the diagram
- `begin_move::AbstractFloat`: The time point to begin moving the point at
- `end_move::AbstractFloat`: The time point to finish moving the point at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    move::EuclidPointMove,
    begin_move::AbstractFloat, end_move::AbstractFloat, t::AbstractFloat)

    animate(move.move_text, begin_move, end_move, t)

    begin_at = move.begin_at[]
    move_to = move.move_to[]
    v = move_to - begin_at
    norm_v = norm(v)
    u = v / norm_v

    perform(t, begin_move, end_move,
         () -> nothing,
         () -> nothing) do
        on_t = ((t-begin_move)/(end_move-begin_move)) * norm_v
        if on_t > 0
            move.baseOn.data[] = (begin_at + on_t * u)
        else
            move.baseOn.data[] = move_to
        end
    end
end
