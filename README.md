# EnforcedTypeSignatureCallables

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://nsajko.gitlab.io/EnforcedTypeSignatureCallables.jl/dev)
[![Build Status](https://gitlab.com/nsajko/EnforcedTypeSignatureCallables.jl/badges/main/pipeline.svg)](https://gitlab.com/nsajko/EnforcedTypeSignatureCallables.jl/pipelines)
[![Coverage](https://gitlab.com/nsajko/EnforcedTypeSignatureCallables.jl/badges/main/coverage.svg)](https://gitlab.com/nsajko/EnforcedTypeSignatureCallables.jl/commits/main)
[![Coverage](https://codecov.io/gh/nsajko/EnforcedTypeSignatureCallables.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/nsajko/EnforcedTypeSignatureCallables.jl)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/EnforcedTypeSignatureCallables.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/E/EnforcedTypeSignatureCallables.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A tiny Julia package providing a simple wrapper type for enforcing the argument and
return types of a wrapped callable object. The wrapper callable ensures that, for each
call, the types of the positional arguments and the return type are as specified.

Kind of provides a way to express a type signature for a callable in Julia's type
system.

## Why would one want to use this?

Two unrelated use cases come to mind. The first is helping Julia's type inference when
necessary.

The second use case is what many newcomers to Julia ask for, especially when coming from
a statically typed language: being able to express the type signature of a "function" in
the type system.
