
function ocean_grid_setup(arch, bottom_height;
                          active_cells_map = true)

    # We choose a size that saturates the GPU. 
    # A quarter degree "near-global" ocean spanning 75 south to 75 north is enough
    Nx = grid_size[1]
    Ny = grid_size[2]
    Nz = grid_size[3]

    variable_z_faces = range(-6000, 0, length = Nz+1)

    grid = LatitudeLongitudeGrid(arch, 
                                 size = (Nx, Ny, Nz), 
                                 latitude = (-75, 75),
                                 longitude = (0, 360),
                                 halo = (7, 7, 7),
                                 z = collect(variable_z_faces))

    if !isnothing(bottom_height)
        grid = ImmersedBoundaryGrid(grid, GridFittedBottom(bottom_height); active_cells_map)
    end

    return grid
end

# Random initial velocities
function initial_ocean_velocities(grid)

    arch = architecture(grid)

    u = XFaceField(grid)
    v = YFaceField(grid)
    w = ZFaceField(grid)

    set!(u, (x, y, z) -> rand() * 0.01)
    set!(v, (x, y, z) -> rand() * 0.01)

    compute_w_from_continuity!((; u, v, w), arch, grid)

    velocities = PrescribedVelocityFields(; u, v, w)

    return velocities
end

ocean_tracer_advection()   = TracerAdvection(WENO(order = 7), 
                                             WENO(order = 7),
                                             Centered())

ocean_momentum_advection() = VectorInvariant(vorticity_scheme = WENO(order = 9),
                                            divergence_scheme = WENO(),
                                              vertical_scheme = Centered()) 

"""
    tracer_kernel_test(arch; 
                       tracer_advection = ocean_tracer_advection(), 
                       bottom_height = nothing,
                       active_cells_map = true)

Returns a model that tests the efficiency of the tracer tendency kernels.
The methods are similar to those used for tracer evolution in a typical ocena simulation.
The two possible performance degradation settings are the tracer advection scheme advection
the presence of an immersed boundary.

Arguments:
==========

- `arch`: the architecture (`CPU`, `GPU` or `Distributed`)

Keyword Arguments:
==================

- `tracer_advection`: the most expensive computation in the tracer evolution kernel. The
                      simplest (and cheapest) advection scheme is the `Centered()` advection. 
                      The scheme we would like to use for tracer advection is the 
                      `ocean_tracer_advection()`

- `bottom_height`: a 1440×600 array containing the height of the ocean floor. 
                   If nothing a flat bottom is assumed.
                   Note that with an immersed bottom, as opposed to a flat bottom, many more `if`
                   conditions will be triggered, possibly impacting performance.

- `active_cells_map`: if `true` the tracer tendency kernel is linear and launched only over immersed cells,
                      if `false` the tracer tendency kernel is three-dimensional and launched over the whole grid
"""
function tracer_kernel_test(arch; 
                            tracer_advection = ocean_tracer_advection(), 
                            bottom_height = nothing,
                            active_cells_map = true)

    grid = ocean_grid_setup(arch, bottom_height; active_cells_map)

    velocities = initial_ocean_velocities(grid)

    model = HydrostaticFreeSurfaceModel(; grid, 
                                          tracers = :c,
                                          buoyancy = nothing, 
                                          coriolis = nothing, 
                                          velocities,
                                          tracer_advection,
                                          closure = nothing)

    return model
end

"""
    momentum_kernel_test(arch; 
                         momentum_advection = ocean_momentum_advection(), 
                         bottom_height = nothing,
                         active_cells_map = true)

Return a model that tests the efficiency of the momentum tendency kernels.
The settings are similar to those of the `tracer_kernel_test` function

Arguments:
==========

- `arch`: the architecture (`CPU`, `GPU` or `Distributed`)

Keyword Arguments:
==================

- `momentum_advection`: the most expensive computation in the momentum evolution kernel. The
                        simplest (and cheapest) advection scheme is the `VectorInvariant()` advection. 
                        The scheme we would like to use for momentum advection is the 
                        `ocean_momentum_advection()`

- `bottom_height`: a 1440×600 array containing the height of the ocean floor. 
                   If nothing a flat bottom is assumed.
                   Note that with an immersed bottom, as opposed to a flat bottom, many more `if`
                   conditions will be triggered, possibly impacting performance.

- `active_cells_map`: if `true` the tracer tendency kernel is linear and launched only over immersed cells,
                      if `false` the tracer tendency kernel is three-dimensional and launched over the whole grid
"""
function momentum_kernel_test(arch; 
                              momentum_advection = ocean_momentum_advection(), 
                              bottom_height = nothing,
                              active_cells_map = true)

    grid = ocean_grid_setup(arch, bottom_height; active_cells_map)

    velocities   = initial_ocean_velocities(grid)
    free_surface = SplitExplicitFreeSurface(; grid, cfl = 0.7)
    
    model = HydrostaticFreeSurfaceModel(; grid, 
                                          tracers = (),
                                          free_surface,
                                          buoyancy = nothing, 
                                          coriolis = nothing, 
                                          momentum_advection,
                                          closure = nothing)

    set!(model, u = velocities.u, v = velocities.v, w = velocities.w)

    return model
end

"""
   ocean_model_test(arch; 
                    momentum_advection = ocean_momentum_advection(), 
                    tracer_advection = ocean_tracer_advection(), 
                    bottom_height = nothing,
                    active_cells_map = true)

Return a model that tests the efficiency of a typical ocean simulation.
The settings are similar to those of the `tracer_kernel_test` function. 
In addition to the advection, this model has coriolis, two tracers 
(one representing salinity, the other representing temperature), implicit vertical diffusion,
and a free surface model. These last settings are hardcoded and not changeable.

Arguments:
==========

- `arch`: the architecture (`CPU`, `GPU` or `Distributed`)

Keyword Arguments:
==================

- `tracer_advection`: the most expensive computation in the tracer evolution kernel. The
                      simplest (and cheapest) advection scheme is the `Centered()` advection. 
                      The scheme we would like to use for tracer advection is the 
                      `ocean_tracer_advection()`

- `momentum_advection`: the most expensive computation in the momentum evolution kernel. The
                        simplest (and cheapest) advection scheme is the `VectorInvariant()` advection. 
                        The scheme we would like to use for momentum advection is the 
                        `ocean_momentum_advection()`

- `bottom_height`: a 1440×600 array containing the height of the ocean floor. 
                   If nothing a flat bottom is assumed.
                   Note that with an immersed bottom, as opposed to a flat bottom, many more `if`
                   conditions will be triggered, possibly impacting performance.

- `active_cells_map`: if `true` the tracer tendency kernel is linear and launched only over immersed cells,
                      if `false` the tracer tendency kernel is three-dimensional and launched over the whole grid
"""
function ocean_model_test(arch; 
                          momentum_advection = ocean_momentum_advection(), 
                          tracer_advection = ocean_tracer_advection(),
                          bottom_height = nothing,
                          active_cells_map = true)

    grid = ocean_grid_setup(arch, bottom_height; active_cells_map)

    velocities   = initial_ocean_velocities(grid)
    free_surface = SplitExplicitFreeSurface(; grid, cfl = 0.7)
    buoyancy     = SeawaterBuoyancy(equation_of_state = TES10EquationOfState())
    coriolis     = HydrostaticSphericalCoriolis(scheme = ActiveCellEnstrophyConserving())
    closure      = VerticalScalarDiffusivity(ν = 1e-5, κ = 1e-5)

    model = HydrostaticFreeSurfaceModel(; grid, 
                                          tracers = (:T, :S),
                                          free_surface,
                                          tracer_advection,
                                          buoyancy, 
                                          coriolis, 
                                          momentum_advection,
                                          closure)

    N² = 1e-6

    set!(model, u = velocities.u, v = velocities.v, w = velocities.w)
    set!(model, T = (x, y, z) -> N² * z, S = 35)

    return model
end
