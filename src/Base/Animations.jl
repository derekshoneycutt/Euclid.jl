export EuclidTransformBase,
    get_transformation_label, get_transformation_starttime, get_transformation_endtime,
    show_complete


"""
    EuclidTransformBase

Base structure for Euclid Animations

# Interface
- `get_transformation_label(t)`: Returns the text label of the object to transform
- `get_transformation_data(t)`: Returns the actual data object to apply transformations to
- `set_transformation_data(t, newdata)`: Update the according to the transformed information
- `get_transformation_starttime(t)`: Returns the time to start single transform animations, between 0 and 2π.
- `get_transformation_endtime(t)`: Returns the time to end single transform animations, between 0 and 2π.
- `get_transformation_at_percent(t, percent::AbstractFloat)`: Returns the transformation to apply when at a given percent

# Example
```
    struct MyTransform
        base::EuclidTransformBase
        data::Observable{MyData}
        last_percent::Observable{Float32}
    end
    @forward((MyTransform, :base), EuclidTransformBase)
    function get_transformation_data(transform::MyTransform)
        return transform.data[]
    end
    function set_transformation_data(transform::MyTransform, newdata::MyData)
        transform.data[] = newdata
    end
    function get_transformation_at_percent(transform::MyTransform, percent::AbstractFloat)
        ...
    end
```
"""
struct EuclidTransformBase
    label::String
    start_time::Float32
    end_time::Float32
end


"""
    draw_animated_transforms(chart, filename, transforms[, duration=24, framerate=24])

Draws an animation into a gif file and returns an HTML encoding of it.

This takes in a vector of transformations, which should be defined as some type with associated
methods for accessing as defined in Interface below.

# Arguments
- `t`: The time along the animation (typically 0-2π)
- `transforms::Vector`: The transforms to apply during the animation

"""
function perform_transforms(t, transforms::Vector)
    timed_transforms =
        [(trans, get_transformation_starttime(trans),
          get_transformation_endtime(trans), get_transformation_label(trans))
            for trans in transforms]

    relevant =
        filter(transform -> transform[2] <= t, timed_transforms)
    labels = reduce(relevant, init=[]) do sofar, labelitem
        if findfirst(l -> l == labelitem[4], sofar) === nothing
            vcat(sofar, labelitem[4])
        else
            sofar
        end
    end
    transform_partitions =
        [(label, filter(t -> t[4] == label, relevant))
            for label in labels]
    for (label, localtransforms) in transform_partitions
        final_transform = reduce(localtransforms, init=nothing) do final, current
            start_time = current[2]
            end_time = current[3]
            on_t = (t - start_time)/(end_time - start_time)
            on_t = on_t >= 1f0 ? 1f0 : Float32(on_t)
            dotransform = get_transformation_at_percent(current[1], on_t)
            if final === nothing
                return dotransform
            else
                return compose(final, dotransform)
            end
        end
        transformobj = localtransforms[1][1]
        target = get_transformation_data(transformobj)
        newdata = perform(target, final_transform)
        set_transformation_data(transformobj, newdata)
    end
end

"""
    show_complete(transform)

Show a complete animation transformation at 100%

# Arguments
- `transform`: The animation transformation to show completely
"""
function show_complete(transform)
    dotransform = get_transformation_at_percent(transform, 1f0)
    target = get_transformation_data(transform)
    newdata = perform(target, dotransform)
    set_transformation_data(transform, newdata)
end



#=
    BEGIN draw_animated_transforms interface for EuclidTransformBase
=#

function get_transformation_label(transform::EuclidTransformBase)
    return transform.label
end

function get_transformation_starttime(transform::EuclidTransformBase)
    return transform.start_time
end

function get_transformation_endtime(transform::EuclidTransformBase)
    return transform.end_time
end

#=
    END draw_animated_transforms interface for EuclidTransformBase
=#
