quad=[5 7 9 15;7 9 15 17]
include("readdcd.jl")
include("triple.jl")
include("calcdi.jl")
include("phi_psi.jl")
sleep(0.1)
phi_psi(quad)
sleep(0.1)
include("plot_phi_psi.jl")