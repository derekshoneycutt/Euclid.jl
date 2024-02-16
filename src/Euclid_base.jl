
# EUCLID!!!
# This is the high level file including all requirements and all pieces of the Euclid project.
# Individual frontends (e.g. Jupyter notebooks) pull this in for easiest access.


using GeometryBasics;
using LinearAlgebra;
using Colors;
using Observables;
using Distributions;
using ReusePatterns;

export Observable, Point2f, Point2f0, Point3f, Point3f0

# Load the core library features
include("Core/Colors.jl");
include("Core/Matrices.jl");
include("Core/Points.jl");
include("Core/Lines.jl");
include("Core/Surfaces.jl");
include("Core/Angles.jl");
include("Core/Circles.jl");


# Load Base components/widgets
include("Base/Animations.jl");
include("Base/Text.jl");


# Load Euclid Elements books
include("ElementsBook1/EuclidElementsBook1.jl");

