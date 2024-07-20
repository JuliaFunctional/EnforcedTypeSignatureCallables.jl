module EnforcedTypeSignatureCallables

export TypedCallable

"""
    TypedCallable

A simple callable type wrapping another callable.

There are three type parameters: the first type parameter represents the allowed types
of the positional arguments. The second type parameter is the allowed return type of the
callable. The third type parameter is the type of the wrapped callable.

The first type parameter, representing the allowed positional argument types, always
subtypes `Tuple`. For example, to allow either a single `Int` argument or two `Bool`
arguments, choose `Union{Tuple{Int},Tuple{Bool,Bool}}` as the first type parameter.

To disable argument type checking, just choose `Tuple` as the first parameter.

To disable return type checking, just choose `Any`, as the second parameter.
"""
struct TypedCallable{A<:Tuple,R,F}
    f::F

    """
        TypedCallable{A,R}(f)

    Construct a `TypedCallable{A,R}` wrapping the callable `f`.
    """
    function TypedCallable{A,R}(f::F) where {A<:Tuple,R,F}
        t_r = R::Type
        r = new{A,t_r,F}(f)
        r = r::TypedCallable
        r = r::TypedCallable{A}
        r = r::TypedCallable{A,t_r}
        r = r::TypedCallable{A,t_r,F}
        r
    end
end

"""
    (tc::TypedCallable{A,R})(args...; kwargs...)

1. Enforces `args isa A`
2. Calls `tc.f` with the provided positional and keyword arguments
3. Enforces the return type of the above call as `R`
"""
function (tc::TypedCallable{A,R})(args::Vararg{Any,N}; kwargs...) where {A,R,N}
    args = args::A
    r = (tc.f)(args...; kwargs...)
    r::R
end

end
