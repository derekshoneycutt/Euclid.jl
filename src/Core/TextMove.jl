
export EuclidTextMove, EuclidText2fMove, EuclidText3fMove, move, reset, show_complete, hide, animate

"""
    EuclidTextMove

Describes a movement of text in Euclid diagrams
"""
struct EuclidTextMove{N}
    baseOn::EuclidText{2}
    begin_at::Observable{Point{N, Float32}}
    move_to::Observable{Point{N, Float32}}
end
EuclidText2fMove = EuclidTextMove{2}
EuclidText3fMove = EuclidTextMove{3}

"""
    move(text, new_spot[, begin_at])

Set up a movement of text on the Euclid diagram

# Arguments
- `text::EuclidText2f`: The text to move in the diagram
- `new_spot::Observable{Point2f}`: The new spot to move the text in the diagram to
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(text::EuclidText{2}, new_spot::Observable{Point2f};
              begin_at::Union{Point2f, Observable{Point2f}}=point.data[])

    observable_begin_at = begin_at isa Observable{Point2f} ? begin_at : Observable(begin_at)
    EuclidText2fMove(text, observable_begin_at, new_spot)
end
function move(text::EuclidText{3}, new_spot::Observable{Point3f};
              begin_at::Union{Point3f, Observable{Point3f}}=point.data[])

    observable_begin_at = begin_at isa Observable{Point3f} ? begin_at : Observable(begin_at)
    EuclidText2fMove(text, observable_begin_at, new_spot)
end

"""
    move(text, new_spot[, begin_at])

Set up a movement of text on the Euclid diagram

# Arguments
- `text::EuclidText2f`: The text to move in the diagram
- `new_spot::Point2f`: The new spot to move the text in the diagram to
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(text::EuclidText{2}, new_spot::Point2f;
              begin_at::Union{Point2f, Observable{Point2f}}=point.data)
    move(text, Observable(new_spot), begin_at=begin_at)
end
function move(text::EuclidText{3}, new_spot::Point3f;
              begin_at::Union{Point3f, Observable{Point3f}}=point.data)
    move(text, Observable(new_spot), begin_at=begin_at)
end

"""
    reset(move[, begin_at, move_to])

Reset a movement animation for text in a Euclid Diagram to new positions

Does not move the text

# Arguments
- `move::EuclidText2fMove`: The description of the move to reset
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to begin movements at in the diagram
- `move_to::Union{Point2f, Observable{Point2f}}`: The point to end movements to in the diagram
"""
function reset(move::EuclidTextMove;
    begin_at::Union{Point2f, Observable{Point2f}}=move.baseOn.location,
    move_to::Union{Point2f, Observable{Point2f}}=move.move_to)

    if begin_at isa Observable{Point2f}
        move.begin_at = begin_at
    else
        move.begin_at[] = begin_at
    end
    if move_to isa Observable{Point2f}
        move.move_to = move_to
    else
        move.move_to[] = move_to
    end
end
function reset(move::EuclidTextMove;
    begin_at::Union{Point3f, Observable{Point3f}}=move.baseOn.location,
    move_to::Union{Point3f, Observable{Point3f}}=move.move_to)

    if begin_at isa Observable{Point2f}
        move.begin_at = begin_at
    else
        move.begin_at[] = begin_at
    end
    if move_to isa Observable{Point2f}
        move.move_to = move_to
    else
        move.move_to[] = move_to
    end
end

"""
    show_complete(move)

Complete a previously defined move operation for text in a Euclid diagram

# Arguments
- `move::EuclidText2fMove`: The description of the move to finish moving
"""
function show_complete(move::EuclidTextMove)
    move.baseOn.location[] = move.move_to[]
end

"""
    hide(move)

Move text in a Euclid diagram back to its starting position

# Arguments
- `move::EuclidText2fMove`: The description of the move to "undo"
"""
function hide(move::EuclidTextMove)
    move.baseOn.location[] = move.begin_at[]
end

"""
    animate(move, begin_move, end_move, t)

Animate moving text drawn in a Euclid diagram

# Arguments
- `move::EuclidText2fMove`: The text to animate in the diagram
- `begin_move::AbstractFloat`: The time point to begin moving the text at
- `end_move::AbstractFloat`: The time point to finish moving the text at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    move::EuclidTextMove,
    begin_move::AbstractFloat, end_move::AbstractFloat, t::AbstractFloat)

    begin_at = move.begin_at[]
    move_to = move.move_to[]
    v = move_to - begin_at
    norm_v = norm(v)
    u = v / norm_v

    perform(t, begin_move, end_move,
         () -> nothing,
         () -> nothing) do
        on_t = ((t-begin_move)/(end_move-begin_move)) * norm_v
        move.baseOn.location[] = (begin_at + on_t * u)
    end
end

