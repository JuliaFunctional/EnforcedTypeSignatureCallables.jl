module EnforcedTypeSignatureCallables

export CallableWithReturnType, CallableWithTypeSignature, typed_callable

struct CallableWithArgumentTypes{Arguments <: Tuple, Callable} <: Function
    callable::Callable
    function CallableWithArgumentTypes{Arguments}(callable::Callable) where {Arguments <: Tuple, Callable}
        callable_type = if callable isa Type
            Type{callable}
        else
            typeof(callable)
        end
        new{Arguments, callable_type}(callable)
    end
end

function (callable::CallableWithArgumentTypes)(args...; kwargs...)
    function arguments(::CallableWithArgumentTypes{Arguments}) where {Arguments <: Tuple}
        Arguments
    end
    args = args::arguments(callable)
    c = getfield(callable, 1)
    c(args...; kwargs...)
end

"""
    CallableWithReturnType <: ComposedFunction

Type of callables with a guaranteed return type.

Has two type variables:

* the return type

* the underlying callable type

`CallableWithReturnType` is not a newly defined type. It is merely a type alias based on:

* `ComposedFunction`

* `Base.Fix2`

* `typeassert`

For some type `Return` we have the following identity which allows dispatching on a function with a certain guaranteed return type:

```julia
CallableWithReturnType{Return} == ComposedFunction{Base.Fix2{typeof(typeassert), Type{Return}}}
```

Lacks constructor methods. Construct a `CallableWithReturnType` using [`typed_callable`](@ref).
"""
const CallableWithReturnType = ComposedFunction{
    Base.Fix2{
        typeof(typeassert),
        Type{Return},
    },
    Callable,
} where {
    Return,
    Callable,
}

"""
    CallableWithTypeSignature <: CallableWithReturnType

Type of callables with a guaranteed return type and argument types.

Has three type variables:

* the return type

* the type of the positional (non-keyword) arguments, subtypes `Tuple`

* the underlying callable type

Lacks constructor methods. Construct a `CallableWithTypeSignature` using [`typed_callable`](@ref).
"""
const CallableWithTypeSignature = CallableWithReturnType{
    Return,
    CallableWithArgumentTypes{
        Arguments,
        Callable,
    },
} where {
    Return,
    Arguments <: Tuple,
    Callable,
}

function return_type_enforcer(::Type{Return}) where {Return}
    Base.Fix2(typeassert, Return)
end

function typed_callable_no_special_casing(callable::Callable, ::Type{Return}) where {
    Return, Callable,
}
    ret = return_type_enforcer(Return)
    ret ∘ callable
end

function typed_callable_no_special_casing(callable::Callable, ::Type{Return}, ::Type{Arguments}) where {
    Return, Arguments <: Tuple, Callable,
}
    with_argument_types = CallableWithArgumentTypes{Arguments}(callable)
    typed_callable_no_special_casing(with_argument_types, Return)
end

"""
    typed_callable(callable, return_type::Type, argument_types::Type{<:Tuple})::CallableWithTypeSignature{return_type, argument_types}

Creates a callable from `callable` with:

* guaranteed return type `return_type`

* guaranteed argument types `argument_types`

The return type is [`CallableWithTypeSignature`](@ref).

Examples:

```julia-repl
julia> using EnforcedTypeSignatureCallables

julia> typed_callable(hypot, Float32, Tuple{Float32, Float32})(3.1f0, 3.0f0)
4.313931f0

julia> typed_callable(hypot, Float32, Tuple{Float32, Float32})(3.1f0, 3.0)
ERROR: TypeError: in typeassert, expected Tuple{Float32, Float32}, got a value of type Tuple{Float32, Float64}
```
"""
function typed_callable(callable::Callable, ::Type{Return}, ::Type{Arguments}) where {
    Return, Arguments <: Tuple, Callable,
}
    if callable isa CallableWithTypeSignature{Return, Arguments}  # ensure idempotence
        callable
    else
        typed_callable_no_special_casing(callable, Return, Arguments)
    end
end

"""
    typed_callable(callable, return_type::Type)::CallableWithReturnType{return_type}

Creates a callable from `callable` with guaranteed return type `return_type`

The return type is [`CallableWithReturnType`](@ref).

Examples:

```julia-repl
julia> using EnforcedTypeSignatureCallables

julia> typed_callable(Int, Int)(3)
3

julia> typed_callable(Int, Int) isa CallableWithReturnType{Int}
true

julia> typed_callable(cos, Float64)(3)
-0.9899924966004454

julia> typed_callable(cos, Float32)(3.0)
ERROR: TypeError: in typeassert, expected Float32, got a value of type Float64
```
"""
function typed_callable(callable::Callable, ::Type{Return}) where {
    Return, Callable,
}
    if callable isa CallableWithReturnType{Return}  # ensure idempotence
        callable
    else
        typed_callable_no_special_casing(callable, Return)
    end
end

end
