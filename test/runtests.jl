using EnforcedTypeSignatureCallables
using Test
using Aqua: Aqua

@testset "EnforcedTypeSignatureCallables.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(EnforcedTypeSignatureCallables)
    end

    @testset "`CallableWithReturnType`" begin
        @testset "subtyping" begin
            @test CallableWithReturnType <: ComposedFunction
            @test CallableWithReturnType{Float32} == ComposedFunction{Base.Fix2{typeof(typeassert), Type{Float32}}}
        end
        @testset "construction" begin
            @test (@inferred typed_callable(Float64, cos)) isa CallableWithReturnType
            @test (@inferred typed_callable(Float64, cos)) isa CallableWithReturnType{Float64}
            @test (@inferred typed_callable(Float64, cos)) isa CallableWithReturnType{Float64, typeof(cos)}
        end
        @testset "return type enforcement" begin
            f = typed_callable(Int, only)::CallableWithReturnType
            x_int = Any[3]
            x_f64 = Any[3.0]
            @test 3 === @inferred f(x_int)
            @test_throws TypeError f(x_f64)
        end
    end

    @testset "`CallableWithTypeSignature`" begin
        @testset "subtyping" begin
            @test CallableWithTypeSignature <: CallableWithReturnType
            @test CallableWithTypeSignature{Float32} <: ComposedFunction{Base.Fix2{typeof(typeassert), Type{Float32}}}
            @test_throws TypeError CallableWithTypeSignature{<:Any, Int}
        end
        @testset "construction" begin
            @test (@inferred typed_callable(Float64, Tuple{Int, Int}, hypot)) isa CallableWithTypeSignature
            @test (@inferred typed_callable(Float64, Tuple{Int, Int}, hypot)) isa CallableWithTypeSignature{Float64}
            @test (@inferred typed_callable(Float64, Tuple{Int, Int}, hypot)) isa CallableWithTypeSignature{Float64, Tuple{Int, Int}}
            @test (@inferred typed_callable(Float64, Tuple{Int, Int}, hypot)) isa CallableWithTypeSignature{Float64, Tuple{Int, Int}, typeof(hypot)}
            @test (@inferred typed_callable(Int, Tuple{Float32}, Int)) isa CallableWithTypeSignature
            @test (@inferred typed_callable(Int, Tuple{Float32}, Int)) isa CallableWithTypeSignature{Int}
            @test (@inferred typed_callable(Int, Tuple{Float32}, Int)) isa CallableWithTypeSignature{Int, Tuple{Float32}}
            @test (@inferred typed_callable(Int, Tuple{Float32}, Int)) isa CallableWithTypeSignature{Int, Tuple{Float32}, Type{Int}}
            @test_throws MethodError typed_callable(Int, Int, Int)  # arguments type must subtype `Tuple`
        end
        @testset "arguments type enforcement" begin
            @testset "non-`Type`" begin
                f = typed_callable(Any, Tuple{Int}, -)::CallableWithTypeSignature
                @test -3 === @inferred f(3)
                @test_throws TypeError f(3.0)
            end
            @testset "`Type`" begin
                f = typed_callable(Any, Tuple{Int}, Int8)::CallableWithTypeSignature
                @test Int8(3) === @inferred f(3)
                @test_throws TypeError f(3.0)
            end
        end
        @testset "return type enforcement" begin
            x_int = Any[3]
            x_f64 = Any[3.0]
            @testset "non-`Type`" begin
                f = typed_callable(Int, Tuple, only)::CallableWithTypeSignature
                @test 3 === @inferred f(x_int)
                @test_throws TypeError f(x_f64)
            end
            @testset "`Type`" begin
                f = typed_callable(Int, Tuple, Int)::CallableWithTypeSignature
                @test 3 === @inferred f(3)
                @test 3 === @inferred f(3.0)
            end
        end
    end
end
