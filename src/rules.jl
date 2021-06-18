"""
    frule([::RuleConfig,] (Δf, Δx...), f, x...)

Expressing the output of `f(x...)` as `Ω`, return the tuple:

    (Ω, ΔΩ)

The second return value is the differential w.r.t. the output.

If no method matching `frule((Δf, Δx...), f, x...)` has been defined, then return `nothing`.

Examples:

unary input, unary output scalar function:

```jldoctest frule
julia> dself = NoTangent();

julia> x = rand()
0.8236475079774124

julia> sinx, Δsinx = frule((dself, 1), sin, x)
(0.7336293678134624, 0.6795498147167869)

julia> sinx == sin(x)
true

julia> Δsinx == cos(x)
true
```

Unary input, binary output scalar function:

```jldoctest frule
julia> sincosx, Δsincosx = frule((dself, 1), sincos, x);

julia> sincosx == sincos(x)
true

julia> Δsincosx[1] == cos(x)
true

julia> Δsincosx[2] == -sin(x)
true
```

Note that techically speaking julia does not have multiple output functions, just functions
that return a single output that is iterable, like a `Tuple`.
So this is actually a [`Tangent`](@ref):
```jldoctest frule
julia> Δsincosx
Tangent{Tuple{Float64, Float64}}(0.6795498147167869, -0.7336293678134624)
```

The optional [`RuleConfig`](@ref) option allows specifying frules only for AD systems that
support given features. If not needed, then it can be omitted and the `frule` without it
will be hit as a fallback. This is the case for most rules.

See also: [`rrule`](@ref), [`@scalar_rule`](@ref), [`RuleConfig`](@ref)
"""
frule(::Any, ::Any, ::Vararg{Any}) = nothing

# if no config is present then fallback to config-less rules
frule(::RuleConfig, args...) = frule(args...)

# Manual fallback for keyword arguments. Usually this would be generated by
#
#   frule(::Any, ::Vararg{Any}; kwargs...) = nothing
#
# However - the fallback method is so hot that we want to avoid any extra code
# that would be required to have the automatically generated method package up
# the keyword arguments (which the optimizer will throw away, but the compiler
# still has to manually analyze). Manually declare this method with an
# explicitly empty body to save the compiler that work.
(::Core.kwftype(typeof(frule)))(::Any, ::Any, ::Vararg{Any}) = nothing
(::Core.kwftype(typeof(frule)))(kws::Any, ::RuleConfig, args...) =
    (Core.kwftype(typeof(frule)))(kws, args...)


"""
    rrule([::RuleConfig,] f, x...)

Expressing `x` as the tuple `(x₁, x₂, ...)` and the output tuple of `f(x...)`
as `Ω`, return the tuple:

    (Ω, (Ω̄₁, Ω̄₂, ...) -> (s̄elf, x̄₁, x̄₂, ...))

Where the second return value is the the propagation rule or pullback.
It takes in differentials corresponding to the outputs (`x̄₁, x̄₂, ...`),
and `s̄elf`, the internal values of the function itself (for closures)

If no method matching `rrule(f, xs...)` has been defined, then return `nothing`.

Examples:

unary input, unary output scalar function:

```jldoctest
julia> x = rand();

julia> sinx, sin_pullback = rrule(sin, x);

julia> sinx == sin(x)
true

julia> sin_pullback(1) == (NoTangent(), cos(x))
true
```

binary input, unary output scalar function:

```jldoctest
julia> x, y = rand(2);

julia> hypotxy, hypot_pullback = rrule(hypot, x, y);

julia> hypotxy == hypot(x, y)
true

julia> hypot_pullback(1) == (NoTangent(), (x / hypot(x, y)), (y / hypot(x, y)))
true
```

The optional [`RuleConfig`](@ref) option allows specifying rrules only for AD systems that
support given features. If not needed, then it can be omitted and the `rrule` without it
will be hit as a fallback. This is the case for most rules.

See also: [`frule`](@ref), [`@scalar_rule`](@ref), [`RuleConfig`](@ref)
"""
rrule(::Any, ::Vararg{Any}) = nothing

# if no config is present then fallback to config-less rules
rrule(::RuleConfig, f, args...) = rrule(f, args...)

# Manual fallback for keyword arguments. See above
(::Core.kwftype(typeof(rrule)))(::Any, ::Any, ::Vararg{Any}) = nothing
(::Core.kwftype(typeof(rrule)))(kws::Any, ::RuleConfig, args...) =
    (Core.kwftype(typeof(rrule)))(kws, args...)
