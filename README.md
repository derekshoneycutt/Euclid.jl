# Euclid.jl

This first began as a project entirely about trying to code out the propositions in Euclid's Elements using the Julia language and GLMakie. That remains entirely true for what this is, but after some frustration with my initial round, I began to pull the code out into a new version. This project is to house a Julia module that is used to do all the drawing, etc. with cleaner git handlings.

See [https://derekshoneycutt.github.io/Euclid/index.html](https://derekshoneycutt.github.io/Euclid/index.html) and [its GitHub source](https://github.com/derekshoneycutt/Euclid) for how this project is used.

---

## Julia Module

This project can be used as a Julia module. Although I have no intention of publishing it as an official package, it can be brought into any other project by adding it directly from the git repository.

```julia
using Pkg
Pkg.add(url="https://github.com/derekshoneycutt/Euclid.jl.git")

# ...

using Euclid
```

---

## Architecture

The underlying code for this module is a 2-layered, matrix/vector transformation focused architecture. At the lowest level, animations are represented via static structures in space and transformations that act upon them to create new copies (think: functional). On top of this lies dynamic structures representing animation figures over time and the stateful transformations that change them (think: OOP, including a kind of interface inheritence via composition and observable patterns). These representations can be drawn to graphics in some additional layer (e.g. with GLMakie).

For example, to create a simple animated point, one would define the figures and their transformations with the middle layer, utilizing the lowest layer to define a euclidean point, and then animate the definitions into a gif file with the graphical layer:

```julia
# Actors/Figures
A_def = euclidean_point(0f0, 0f0, color=:steelblue, size=0.0125f0)
A = point("A", A_def)

# Transformations
A_show = reveal(A, 1f0, 0.5f0π, 1f0π)
A_hide = reveal(A, -1f0, 1.5f0π, 2f0π)

# Draw the animation!
# NOTE: The below code uses EuclidGLMakie.jl project to draw the animations
chart = euclid_chart(
    title="Euclid's Elements Book I, Definition 1: Point",
    xlims=(-1,1), ylims=(-1,1))
euclid_legend(chart,
    [circle_legend(color=:steelblue)],
    [L"\text{A \textit{point} is that which has no part.}"])

draw_animated_transforms(chart, "gifs/001-Point.gif",
    [A], [A_show, A_hide], duration=6)
```

The current architectural layers of the project:

1. `src/Core` contains the low-level, primary math and a few underlying utilities. Whereas some core animation code is represented here, it is represented in terms of percent along the animation, without respect to particular timing, etc. Objects in this layer typically represent objects in space at only one time. At all times, all dependencies on drawing libraries are avoided in this layer.
1. `src/Base`, `src/ElementsBook...` contains the code representations of the visualization of Euclid's Elements. `src/Base` contains a core interface for common animations. This makes heavy use of Observables to represent animation-ready objects. These objects represent objects throughout the lifetime of an animation. No actual drawing is done in this layer.

---

## Drawings

The above code sample, as well as the EUclid project this was developed for also utilize a specific drawing library located at [https://derekshoneycutt.github.io/EuclidGLMakie.jl/index.html](https://derekshoneycutt.github.io/EuclidGLMakie.jl/index.html). This was decoupled from this project to keep this one cleaner and more versatile.
