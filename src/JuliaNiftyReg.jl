module JuliaNiftyReg

using Pkg
Pkg.activate("..")
Pkg.instantiate()

include("core.jl")
init_()
export run_registration

end