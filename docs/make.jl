using EnforcedTypeSignatureCallables
using Documenter

DocMeta.setdocmeta!(EnforcedTypeSignatureCallables, :DocTestSetup, :(using EnforcedTypeSignatureCallables); recursive=true)

makedocs(;
    modules=[EnforcedTypeSignatureCallables],
    authors="Neven Sajko <s@purelymail.com> and contributors",
    sitename="EnforcedTypeSignatureCallables.jl",
    format=Documenter.HTML(;
        canonical="https://nsajko.gitlab.io/EnforcedTypeSignatureCallables.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
