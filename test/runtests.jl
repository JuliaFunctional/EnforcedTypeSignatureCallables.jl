using EnforcedTypeSignatureCallables
using Test
using Aqua: Aqua

@testset "EnforcedTypeSignatureCallables.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(EnforcedTypeSignatureCallables)
    end

    @testset "construction" begin
        @testset "successful" begin
            for A ∈ (Tuple, Tuple{Vararg{Float64}}, Tuple{Float64}, Union{Tuple{Nothing},Tuple{Float64}})
                for R ∈ (Any, Float64)
                    for f ∈ (sin, cos)
                        @test TypedCallable{A,R}(f) isa TypedCallable
                        @test TypedCallable{A,R}(f) isa TypedCallable{A}
                        @test TypedCallable{A,R}(f) isa TypedCallable{A,R}
                        @test TypedCallable{A,R}(f) isa TypedCallable{A,R,typeof(f)}
                    end
                end
            end
        end
        @testset "failed" begin
            @test_throws TypeError TypedCallable{Vector}
            @test_throws TypeError TypedCallable{Vector,Any}
            @test_throws TypeError TypedCallable{Vector,Any,typeof(sin)}
        end
    end

    @testset "argument type enforcement" begin
        @testset "successful" begin
            @test TypedCallable{Tuple{Vararg{Float64}},Any}(sin)(0.1) isa Float64
            @test TypedCallable{Tuple{Vararg{Float32}},Any}(sin)(0.1f0) isa Float32
            @test TypedCallable{Union{Tuple{Nothing},Tuple{Float64}},Any}(sin)(0.1) isa Float64
        end
        @testset "failed" begin
            @test_throws TypeError TypedCallable{Tuple{Vararg{Float64}},Any}(sin)(0.1f0)
        end
    end

    @testset "return type enforcement" begin
        @testset "successful" begin
            @test TypedCallable{Tuple,Float64}(sin)(0.1) isa Float64
            @test TypedCallable{Tuple,Float32}(sin)(0.1f0) isa Float32
            @test TypedCallable{Tuple,Union{Float32,Float64}}(sin)(0.1) isa Float64
        end
        @testset "failed" begin
            @test_throws TypeError TypedCallable{Tuple,Float64}(sin)(0.1f0)
            @test_throws TypeError TypedCallable{Tuple,Float32}(sin)(0.1)
        end
    end
end
