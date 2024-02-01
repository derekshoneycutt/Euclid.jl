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

The underlying code for this module is a 3-layered, matrix/vector transformation focused architecture. At the lowest level, animations are represented via static structures in space and transformations that act upon them to create new copies (think: functional). On top of this lies dynamic structures representing animation figures over time and the stateful transformations that change them (think: OOP, including a kind of interface inheritence via composition and observable patterns). Finally, these representations are drawn to graphics in the highest layer (GLMakie). In this, all 3 layers are often used together.

For example, to create a simple animated point, one would define the figures and their transformations with the middle layer, utilizing the lowest layer to define a euclidean point, and then animate the definitions into a gif file with the graphical layer:

```julia
# Actors/Figures
A = point("A", euclidean_point(0f0, 0f0, color=:steelblue, size=0.0125f0))

# Transformations
A_show = reveal(A, 1f0, 0.5f0π, 1f0π)
A_hide = reveal(A, -1f0, 1.5f0π, 2f0π)

# Draw the animation!
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
1. `src/Makie` handles creating GLMakie chart spaces and drawing the elements defined in prior layers. This simply draws the representations in lower levels and does not create otherwise undefined elements except for legends, titles, and similar.

---

## Limitations and Comments

### Makie dependencies

In theory, the Makie code could be split off and this could be made capable of supporting just about any other rendering library. Why is that not done? Primarily due to the heavy use of Observables and the `@lift` macro geared towards Makie in the middle layer identified above. In theory, could reproduce the `@lift` macro or rewrite it with simply `map` as is already available, but for now, decoupling that is a potential future enhancement.

### Efficiency and Compromises

For the most part, the stated architecture and following Euclid's elements does not always follow the best practices of efficient and speedy code. That is not the intention with this project, so this is entirely accepted. If you need speedy geometry code, this is an inspiration at best but simply is not going to be geared for that.

That said, some parts of the code are basically compromises to get an acceptable drawing. In the GLMakie code, drawing angle visuals in 3D and drawing circles and their portions tends towards deciphering outlines and triangulation. While this works well enough, much of it can be improved. For example, the circle code includes a very primitive piping code of sorts. This works well enough for circles, but quickly falls apart at using it in almost any other context. There is probable room for improvement in some of these drawings.
