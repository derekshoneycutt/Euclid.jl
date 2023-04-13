
export point_along

"""
    point_along(A, B, move_out=n)

Gets a point along a path from a starting point A to another point B

# Arguments
- `A::Point2`: The starting point along the path
- `B::Point2`: The known destination along the path
- `move_out`: How far to move along the path--including before or beyond B
"""
function point_along(A::Point2, B::Point2; move_out=0)
    v = B - A
    norm_v = norm(v)
    u = v / norm_v
    x,y = A + (move_out > 0 ? move_out : norm_v) * u
    Point2f0(x, y)
end
