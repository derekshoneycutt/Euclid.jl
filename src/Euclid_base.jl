
# EUCLID!!!
# This is the high level file including all requirements and all pieces of the Euclid project.
# Individual frontends (e.g. Jupyter notebooks) pull this in for easiest access.


using GeometryBasics;
using LinearAlgebra;
using Symbolics;
using LaTeXStrings;
using Latexify;
using Colors;
using GLMakie;
using Distributions;
using Base64;

export Observable, @L_str, Point2f, Point2f0, Point3f, Point3f0

# Load the core library features
include("Core/Paths.jl");
include("Core/Angles.jl");
include("Core/Colors.jl");
include("Core/ChartSpace.jl");
include("Core/Animations.jl");
include("Core/AxisElements.jl");
include("Core/Text.jl");
include("Core/TextMove.jl");



# Load Euclid Elements books
include("../ElementsBook1/EuclidElementsBook1.jl");

