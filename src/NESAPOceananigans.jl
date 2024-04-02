module NESAPOceananigans

using Oceananigans
using BenchmarkTools
using SeawaterPolynomials
using NVTX

using Oceananigans.Architectures: architecture

using Oceananigans.Advection: TracerAdvection
using Oceananigans.Coriolis: ActiveCellEnstrophyConserving
using Oceananigans.Models.HydrostaticFreeSurfaceModels: compute_w_from_continuity!

include("hydrostatic_example.jl")
include("run_model_benchmark.jl")

end
