module JuliaNiftyReg

using Pkg
Pkg.activate("..")
Pkg.instantiate()

include("core.jl")

export run_registration

end