
export EuclidSurfaceMove, EuclidSurface2fMove, EuclidSurface3fMove, move, reset, show_complete, hide, animate

"""
    EuclidSurfaceMove

Describes moving a surface in a Euclid diagram
"""
mutable struct EuclidSurfaceMove{N}
    baseOn::EuclidSurface{N}
    begin_at::Observable{Point{N, Float32}}
    move_to::Observable{Point{N, Float32}}
    vectors::Observable{Vector{Point{N, Float32}}}
    movingIndex::Int
end
EuclidSurface2fMove = EuclidSurfaceMove{2}
EuclidSurface3fMove = EuclidSurfaceMove{3}

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
function move(surface::EuclidSurface3f, new_spot::Observable{Point3f};
              move_index::Int=1,
              begin_at::Union{Point3f, Observable{Point3f}}=surface.from_points[][1])

    move_extremity = @lift(($(surface.from_points))[move_index])
    v = @lift([p - $move_extremity for p in $(surface.from_points)])
    observable_begin = begin_at isa Observable{Point3f} ? Observable(begin_at[]) : Observable(begin_at)
    EuclidSurface3fMove(surface, observable_begin, new_spot, v, move_index)
end
function move(surface::EuclidSurface2f, new_spot::Point2f;
    move_index::Int=1, begin_at::Union{Point2f, Observable{Point2f}}=surface.from_points[][1])

    move(surface, Observable(new_spot), move_index=move_index, begin_at=begin_at)
end
function move(surface::EuclidSurface3f, new_spot::Point3f;
    move_index::Int=1, begin_at::Union{Point3f, Observable{Point3f}}=surface.from_points[][1])

    move(surface, Observable(new_spot), move_index=move_index, begin_at=begin_at)
end

"""
    reset(move[, begin_at, move_to, move_extremityA=true])

Reset a movement animation for a surface in a Euclid Diagram to new positions

# Arguments
- `move::EuclidSurfaceMove`: The description of the move to reset
- `begin_at::Union{Point, Observable{Point}}`: The point to begin movements at in the diagram
- `move_to::Union{Point, Observable{Point}}`: The point to end movements to in the diagram
- `move_index::Int`: The index of the point to base movement on (defaults to 1)
"""
function reset(move::EuclidSurfaceMove;
    begin_at::Union{Point, Observable{Point}}=move.baseOn.from_points[][move.movingIndex],
    move_to::Union{Point, Observable{Point}}=move.move_to,
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
- `move::EuclidSurfaceMove`: The description of the move to "undo"
"""
function hide(move::EuclidSurfaceMove)
    begin_at = move.begin_at[]
    vectors = move.vectors[]
    new_points = [begin_at + vector for vector in vectors]
    move.baseOn.from_points[] = new_points
end

"""
    animate(move, begin_move, end_move, t)

Animate moving a surface drawn in a Euclid diagram

# Arguments
- `move::EuclidSurfaceMove`: The surface to animate in the diagram
- `begin_move::AbstractFloat`: The time point to begin moving the surface at
- `end_move::AbstractFloat`: The time point to finish moving the surface at
- `t::AbstractFloat`: The current timeframe of the animation
"""
function animate(
    move::EuclidSurfaceMove,
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
            new_points = [(begin_at + on_t * u) + vector for vector in vectors]
            move.baseOn.from_points[] = new_points
        else
            new_points = [move_to + vector for vector in vectors]
            move.baseOn.from_points[] = new_points
        end
    end
end
