
export EuclidSurface2fMove, move, reset, show_complete, hide, animate

"""
    EuclidSurface2fMove

Describes moving a surface in a Euclid diagram
"""
mutable struct EuclidSurface2fMove
    baseOn::EuclidSurface2f
    begin_at::Observable{Point2f}
    move_to::Observable{Point2f}
    vectors::Observable{Vector{Point2f}}
    movingIndex::Int
end

"""
    move(surface, new_spot[, begin_at, move_index=1])

Set up a movement of a surface on the Euclid diagram

# Arguments
- `surface::EuclidSurface2f`: The surface to move in the diagram
- `new_spot::Point2f`: The new spot to move the surface in the diagram to
- `move_index::Int`: The index of the point to base movement on (defaults to 1)
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(surface::EuclidSurface2f, new_spot::Observable{Point2f};
    move_index::Int=1, begin_at::Union{Point2f, Observable{Point2f}}=surface.from_points[][1])

    move_extremity = @lift(($(surface.from_points))[move_index])
    v = @lift([p - $move_extremity for p in $(surface.from_points)])
    observable_begin = begin_at isa Observable{Point2f} ? Observable(begin_at[]) : Observable(begin_at)
    EuclidSurface2fMove(surface, observable_begin, new_spot, v, move_index)
end

"""
    move(surface, new_spot[, begin_at, move_index=1])

Set up a movement of a surface on the Euclid diagram

# Arguments
- `surface::EuclidSurface2f`: The surface to move in the diagram
- `new_spot::Point2f`: The new spot to move the surface in the diagram to
- `move_index::Int`: The index of the point to base movement on (defaults to 1)
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to start the movements at (defaults to current location at time of definition)
"""
function move(surface::EuclidSurface2f, new_spot::Point2f;
    move_index::Int=1, begin_at::Union{Point2f, Observable{Point2f}}=surface.from_points[][1])

    move(surface, Observable(new_spot), move_index=move_index, begin_at=begin_at)
end

"""
    reset(move[, begin_at, move_to, move_extremityA=true])

Reset a movement animation for a surface in a Euclid Diagram to new positions

# Arguments
- `move::EuclidSurface2fMove`: The description of the move to reset
- `begin_at::Union{Point2f, Observable{Point2f}}`: The point to begin movements at in the diagram
- `move_to::Union{Point2f, Observable{Point2f}}`: The point to end movements to in the diagram
- `move_index::Int`: The index of the point to base movement on (defaults to 1)
"""
function reset(move::EuclidSurface2fMove;
    begin_at::Union{Point2f, Observable{Point2f}}=move.baseOn.from_points[][move.movingIndex],
    move_to::Union{Point2f, Observable{Point2f}}=move.move_to,
    move_index::Int=move.movingIndex)

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
    move_extremity = @lift(($(surface.from_points))[move_index])
    move.vectors[] = @lift([p - $move_extremity for p in $(surface.from_points)])
    move.movingIndex = move_index
end

"""
    show_complete(move)

Complete a previously defined move operation for a surface in a Euclid diagram

# Arguments
- `move::EuclidSurface2fMove`: The description of the move to finish moving
"""
function show_complete(move::EuclidSurface2fMove)
    move_to = move.move_to[]
    vectors = move.vectors[]
    new_points = [move_to + vector for vector in vectors]
    move.baseOn.from_points[] = new_points
end

"""
    hide(move)

Move a surface in a Euclid diagram back to its starting position

# Arguments
- `move::EuclidSurface2fMove`: The description of the move to "undo"
"""
function hide(move::EuclidSurface2fMove)
    begin_at = move.begin_at[]
    vectors = move.vectors[]
    new_points = [begin_at + vector for vector in vectors]
    move.baseOn.from_points[] = new_points
end

"""
    animate(move, begin_move, end_move, t)

Animate moving a surface drawn in a Euclid diagram

# Arguments
- `move::EuclidSurface2fMove`: The surface to animate in the diagram
- `begin_move::AbstractFloat`: The time point to begin moving the surface at
- `end_move::AbstractFloat`: The time point to finish moving the surface at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    move::EuclidSurface2fMove,
    begin_move::AbstractFloat, end_move::AbstractFloat, t::AbstractFloat)


    perform(t, begin_move, end_move,
         () -> nothing,
         () -> nothing) do

        begin_at = move.begin_at[]
        move_to = move.move_to[]
        v = move_to - begin_at
        norm_v = norm(v)
        u = v / norm_v

        vectors = move.vectors[]

        on_t = ((t-begin_move)/(end_move-begin_move)) * norm_v
        if on_t > 0
            x,y = begin_at + on_t * u
            new_points = [Point2f0(x, y) + vector for vector in vectors]
            move.baseOn.from_points[] = new_points
        else
            new_points = [move_to + vector for vector in vectors]
            move.baseOn.from_points[] = new_points
        end
    end
end
