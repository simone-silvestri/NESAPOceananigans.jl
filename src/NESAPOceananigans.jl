module NESAPOceananigans

export set_problem_size!
export run_model_benchmark!
export tracer_kernel_test, momentum_kernel_test, ocean_model_test
export random_bathymetry, ocean_bathymetry

using Oceananigans
using BenchmarkTools
using SeawaterPolynomials
using NVTX
using CUDA

using Oceananigans.Architectures: architecture

using Oceananigans.Advection: TracerAdvection
using Oceananigans.Coriolis: ActiveCellEnstrophyConserving
using Oceananigans.TimeSteppers: compute_tendencies!
using Oceananigans.Models.HydrostaticFreeSurfaceModels: compute_w_from_continuity!

grid_size = [1440, 600, 50]

function set_problem_size!(Nx, Ny, Nz)
    NESAPOceananigans.grid_size .= Nx, Ny, Nz
    return nothing
end

include("ocean_bathymetry.jl")
include("hydrostatic_example.jl")
include("run_model_benchmark.jl")

end
