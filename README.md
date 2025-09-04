# EnforcedTypeSignatureCallables

[![Build Status](https://github.com/JuliaFunctional/EnforcedTypeSignatureCallables.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaFunctional/EnforcedTypeSignatureCallables.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaFunctional/EnforcedTypeSignatureCallables.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaFunctional/EnforcedTypeSignatureCallables.jl)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/EnforcedTypeSignatureCallables.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/EnforcedTypeSignatureCallables.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A Julia package providing functionality for annotating arbitrary callables with
type signature data.

Might help with bad inference.

Provides somewhat of a restricted way of expressing a type signature for a callable
in Julia's type system.

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

NB: `typed_callable(Int, Int)` actually only consists of types already present in
`Base` Julia, so it's just a nicer interface for functionality that already comes
with Julia:

```julia-repl
julia> typed_callable(Int, Int)
Base.Fix2{typeof(typeassert), Type{Int64}}(typeassert, Int64) ∘ Int64
```

The three-argument version of `typed_callable` depends on a type defined in this
package, though.

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

For example, a `CallableWithReturnType{Float32}` is guaranteed to return a
`Float32` value, if a value is returned. A
`CallableWithTypeSignature{Float32, Tuple{Float32, Float32}}` additionally
guarantees to only accept exactly two `Float32` values as positional arguments.

For example, suppose your package has a method that accepts a function from the
user. Further suppose the method code expects the user-provided function to only
ever return `Float64`. Instead of sprinkling typeasserts all over your code, it
suffices to call `typed_callable` once:

```julia
function accepts_a_function_from_the_user(func, other_arguments...)
    func = typed_callable(Float64, func)
    # any call of `func` is now guaranteed not to return anything other than `Float64`
end
```

Furthermore, dispatch can also be used to achieve type safety in this regard:

```julia
function accepts_a_function_from_the_user_type_safe(func::CallableWithReturnType{Float64}, other_arguments...)
    # any call of `func` is guaranteed not to return anything other than `Float64`
end

function accepts_a_function_from_the_user(func, other_arguments...)
    func = typed_callable(Float64, func)
    accepts_a_function_from_the_user_type_safe(func, other_arguments...)
end
```

### Why not just use an inline closure with a `typeassert`?

Creating a new local function with a typeassert in the method body would work as
intended for both:

* helping the compiler achieve good inference

* wrapping a user-provided function into a type-safe wrapper function

However using `typed_callable` instead is slightly better:

* avoiding the creation of a new function is slightly friendlier to the compiler,
  giving it less work to do

* using a standardized type may allow the ecosystem to converge on a single type to
  dispatch on when a callable with a certain type signature is required

    * This is more so appropriate as `CallableWithReturnType` is just a type alias
      for a type already provided by `Base`. Thus a package doesn't even need to
      depend on this package to dispatch on `CallableWithReturnType{ReturnType}`.
