export triangulate_square

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
