using EnforcedTypeSignatureCallables
using Test
using Aqua

@testset "EnforcedTypeSignatureCallables.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(EnforcedTypeSignatureCallables)
    end
    # Write your tests here.
end
