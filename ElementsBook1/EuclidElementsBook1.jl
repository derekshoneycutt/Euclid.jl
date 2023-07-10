#


# Note on additional axioms:
#       Although they might not all be "axioms" in a traditional
#       sense, the idea is that they underly the geometry being explored.
#       Sometimes, that is purely in a constructive "drawing" sense.
#       Sometimes, that is because Euclid assumed them.
#       They are numbered but mixed into the items as they are relevant.
#       Some of these are created as an exercise less than to be help in Euclid.


# ==============================================
#               Definitions
# ==============================================

# Definition 1 and its highlighting and moving axioms
include("Definitions/src/001-Point.jl")
include("AddedAxioms/src/001-PointHighlight.jl")
include("AddedAxioms/src/002-PointMove.jl")

# Defintion 2 and its highlighting axioms
include("Definitions/src/002-Line.jl")
include("AddedAxioms/src/003-LineHighlight.jl")

# Defintion 3 and resulting moving axioms
include("Definitions/src/003-LineExtremities.jl")
include("AddedAxioms/src/004-LineMove.jl")
include("AddedAxioms/src/005-LineRotate.jl")

# Definition 4 and resulting axioms
include("Definitions/src/004-StraightLine.jl")
include("AddedAxioms/src/006-LineReflect.jl")
include("AddedAxioms/src/007-LineIntersect.jl")

# Definition 5
include("Definitions/src/005-Surface.jl")

# Definition 6 and its resulting moving axioms
include("Definitions/src/006-SurfaceExtremities.jl")
include("AddedAxioms/src/008-SurfaceMove.jl")
include("AddedAxioms/src/009-SurfaceRotate.jl")
include("AddedAxioms/src/010-SurfaceReflect.jl")

# Definition 7
include("Definitions/src/007-PlaneSurface.jl")

# Definition 8 and resulting axioms
include("Definitions/src/008-PlaneAngle.jl")
include("AddedAxioms/src/011-AngleHighlight.jl")
include("AddedAxioms/src/012-AngleMove.jl")
include("AddedAxioms/src/013-AngleRotate.jl")
include("AddedAxioms/src/014-AngleReflect.jl")

# Definition 9
include("Definitions/src/009-RectilinealAngle.jl")

# Definition 15 and resulting axioms
include("Definitions/src/015-Circle.jl")
include("AddedAxioms/src/015-CircleHighlight.jl")
include("AddedAxioms/src/016-CircleMove.jl")
include("AddedAxioms/src/017-CircleLineIntersect.jl")
include("AddedAxioms/src/018-CircleIntersect.jl")

# Definition 17
include("Definitions/src/017-Diameter.jl")



# ==============================================
#               Postulates
# ==============================================

# Postulate 1
include("Postulates/src/001-DrawStraightLine.jl")


# ==============================================
#               Common Notions
# ==============================================

# Common Notion 1
include("CommonNotions/src/001-EqualThings.jl")

# ==============================================
#               Propositions
# ==============================================

# Propositions 1
include("Propositions/src/001-EquilateralTriangle.jl")
