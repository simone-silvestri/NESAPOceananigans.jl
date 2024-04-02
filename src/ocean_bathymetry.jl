using DataDeps
using JLD2

path = "https://github.com/CliMA/OceananigansArtifacts.jl/raw/main/quarter_degree_near_global_input_data/"

dh = DataDep("quarter_degree_near_global_lat_lon",
    "Bathymetry for global latitude longitude simulation",
    path * "bathymetry-1440x600.jld2"
)

DataDeps.register(dh)

datadep"quarter_degree_near_global_lat_lon"

function ocean_bathymetry()
    
    str = @datadep_str "quarter_degree_near_global_lat_lon/bathymetry-1440x600.jld2"
    file = jldopen(str)

    return file["bathymetry"]
end

function random_bathymetry()
    Nx = grid_size[1]
    Ny = grid_size[2]

    bottom = rand(Nx, Ny)
    
    # With a random bathymetry roughly 50% of the 
    # domain should be immersed. The ocean has 42%

    return bottom
end
