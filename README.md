# EnforcedTypeSignatureCallables

[![Build Status](https://github.com/nsajko/EnforcedTypeSignatureCallables.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/nsajko/EnforcedTypeSignatureCallables.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/nsajko/EnforcedTypeSignatureCallables.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/nsajko/EnforcedTypeSignatureCallables.jl)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/EnforcedTypeSignatureCallables.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/EnforcedTypeSignatureCallables.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A Julia package providing functionality for annotating arbitrary callables with
type signature data.

Might help with bad inference.

Kind of provides a restricted way of expressing a type signature for a callable in
Julia's type system.

## Provided functionality

The package exports the following bindings:

* `CallableWithReturnType`

    * Throws after calling the underlying callable if the return type does not
      match.

    * Lacks constructor methods.

    * Not a newly defined type, just a nice interface over functionality provided
      by `Base`. In particular, for any `Return::Type` we have:

      ```julia
      CallableWithReturnType{Return} == ComposedFunction{Base.Fix2{typeof(typeassert), Type{Return}}}
      ```

* `CallableWithTypeSignature`

    * Throws after calling the underlying callable if the return type does not
      match.

    * Throws before calling the underlying callable if the argument types do not
      match.

    * Subtypes `CallableWithReturnType`.

    * Lacks constructor methods.

* `typed_callable`

    * Use `typed_callable` to construct `CallableWithReturnType` or `CallableWithTypeSignature` values.

## Usage example

```julia-repl
julia> using EnforcedTypeSignatureCallables

julia> typed_callable(Float32, sin)(0.3f0)
0.29552022f0

julia> typed_callable(Float32, sin)(0.3)
ERROR: TypeError: in typeassert, expected Float32, got a value of type Float64
[...]

julia> typed_callable(Float64, Tuple{Int, Int}, hypot)(3, 4)
5.0

julia> typed_callable(Float64, Tuple{Int, Int}, hypot)(3, 4.0)
ERROR: TypeError: in typeassert, expected Tuple{Int64, Int64}, got a value of type Tuple{Int64, Float64}
[...]
```

## Motivation

### Use case 1: help the Julia compiler to achieve good inference

As discussed in Julia issue
[#42372](https://github.com/JuliaLang/julia/issues/42372), a type constructor is
not required to return a value of the given type: the return value of a constructor
can technically be of any type! Thus, in the worst case, the compiler is not able
to infer the return type of a constructor like, for example, `Int`.

This package presents a workaround (actually merely a nice interface over
functionality already provided with Julia `Base`):

```julia-repl
julia> using EnforcedTypeSignatureCallables

julia> naive(x) = map(Int, x)
naive (generic function with 1 method)

julia> improved(x) = map(typed_callable(Int, Int), x)
improved (generic function with 1 method)

julia> Base.infer_return_type(naive, Tuple{NTuple{5, Any}})  # pessimistic type inference result
NTuple{5, Any}

julia> Base.infer_return_type(improved, Tuple{NTuple{5, Any}})  # the return type is now known concretely
NTuple{5, Int64}
```

### Use case 2: dispatch on callables with a certain type signature (kind of)

This is what many newcomers to Julia ask for, especially when coming from a
statically typed language: being able to express the type signature of a "function"
in the type system.

Suppose one is writing a method which takes, among other arguments, a function
(callable object). Further suppose the method needs to be constrained to only apply
when the callable argument has a certain type signature. One way to achieve this is
to restrict the allowed types of the callable argument to chosen subtypes of
`CallableWithReturnType`. This includes `CallableWithTypeSignature`, so the entire
type signature, except any keyword arguments, may be accounted for.
