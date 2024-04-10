using JLD2

function ocean_bathymetry()
    
    file = jldopen("../data/bathymetry-1440x600.jld2")

    return file["bathymetry"]
end

function random_bathymetry()
    Nx = grid_size[1]
    Ny = grid_size[2]

    bottom = - rand(Nx, Ny) .* 6000
    
    # With a random bathymetry roughly 50% of the 
    # domain should be immersed. The ocean has 42%

    return bottom
end
