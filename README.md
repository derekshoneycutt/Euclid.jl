# Euclid.jl

This first began as a project entirely about trying to code out the propositions in Euclid's Elements using the Julia language and GLMakie. That remains entirely true for what this is, but after some frustration with my initial round, I began to pull the code out into a new version. This project is to house a Julia module that is used to do all the drawing, etc. with cleaner git handlings.


See [https://derekshoneycutt.github.io/Euclid/index.html](https://derekshoneycutt.github.io/Euclid/index.html) and [its GitHub source](https://github.com/derekshoneycutt/Euclid) for how this project is used.

---

This project can be used as a Julia module. Although I have no intention of publishing it as an official package, it can be brought into any other project by adding it directly from the git repository.

```julia
using Pkg
Pkg.add(url="https://github.com/derekshoneycutt/Euclid.jl.git")

# ...

using Euclid
```

---

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
