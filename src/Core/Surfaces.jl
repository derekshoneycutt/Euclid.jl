export triangulate_square, triangulate_arch

"""
    triangulate_square(pointA, pointB, pointC, pointD)

Creates a square in the form of triangulated points; that is, get a square in the form of triangles to draw it from

# Arguments
- `pointA::Point3f` - Point A to draw the square from
- `pointB::Point3f` - Point B to draw the square from
- `pointC::Point3f` - Point C to draw the square from
- `pointD::Point3f` - Point D to draw the square from
"""
function triangulate_square(pointA::Point3f, pointB::Point3f, pointC::Point3f, pointD::Point3f)
    [pointA, pointB, pointC, pointA, pointC, pointD]
end

"""
    triangulage_arch(points, center)

Triangulate an arch based on a vector of points that are pre-set around a given center

# Arguments
- `points::Vector{Point}` : The arch points to draw triangles for; should not include the center point
- `center:Point` : The center point that triangles will be drawn to around the arch
"""
function triangulate_arch(points::Vector{Point}, center::Point)
    vcat(([[center, p, (i == length(points) ? p[1] : p[i + 1])]
                for (i,p) in enumerate(points)])...)
end
