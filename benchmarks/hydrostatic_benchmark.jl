using NESAPOceananigans

# Choices for the architecture are `CPU` or `GPU` for a single core
arch = CPU()

# By default the problem size is 1440×600×50 which corresponds to about 
# 10 GB for the full ocean testcase which should saturate the GPU compute
# We can change it with 
set_problem_size!(10, 10, 10)

# The choice for a bottom height for the immersed boundary is
# `nothing`             -> flat bottom
# `random_bathymetry()` -> roughly 50% of cells are immersed
# `ocean_bathymetry()`  -> realistic bathymetry works only if the problem size if `1440×600` in the horizontal

# In this test we are looking at the tracer advection performance. 
# `tracer_advection` is a keyword argument for this test.
# The choices are:
# Centered()              -> the simplest (non-feasible) tracer advection scheme
# UpwindBiased(order = 3) -> the simplest (feasible) tracer advection scheme
# WENO(order = 5)         -> a standard "average-performing" tracer advection scheme
# default                 -> the best compromise between stability and accuracy. Very expensive

# Tracer advection benchmark
@show trial1 = run_model_benchmark!(tracer_kernel_test, arch;
                                    use_benchmarktools = false)

# Simple advection benchmark
@show trial2 = run_model_benchmark!(tracer_kernel_test, arch;
                                    use_benchmarktools = false,
                                    tracer_advection = Centered())

# Simple advection benchmark with a bathymetry
@show trial3 = run_model_benchmark!(tracer_kernel_test, arch;
                                    use_benchmarktools = false,
                                    tracer_advection = Centered(),
                                    bottom_height = random_bathymetry())
                       
# In this test we are looking at the momentum advection performance. 
# `momentum_advection` is a keyword argument for this test.
# The choices are:
# VectorInvariant()       -> the simplest (non-feasible) momentum advection scheme
# UpwindBiased(order = 3) -> the simplest (feasible) momentum advection scheme
# WENO(order = 5)         -> a standard "average-performing" momentum advection scheme
# default                 -> the best compromise between stability and accuracy. Very expensive

# Momentum advection benchmark
@show trial1 = run_model_benchmark!(momentum_kernel_test, arch;
                                    use_benchmarktools = false)

# Simple advection benchmark
@show trial2 = run_model_benchmark!(momentum_kernel_test, arch;
                                    use_benchmarktools = false,
                                    momentum_advection = VectorInvariant())

@show trial3 = run_model_benchmark!(momentum_kernel_test, arch;
                                    use_benchmarktools = false,
                                    momentum_advection = VectorInvariant(),
                                    bottom_height = random_bathymetry())
                       
# In this test we are looking at the full ocean. 
# `momentum_advection` is a keyword argument for this test.
# The choices are:
# VectorInvariant()       -> the simplest (non-feasible) momentum advection scheme
# UpwindBiased(order = 3) -> the simplest (feasible) momentum advection scheme
# WENO(order = 5)         -> a standard "average-performing" momentum advection scheme
# default                 -> the best compromise between stability and accuracy. Very expensive

# Momentum advection benchmark
@show trial1 = run_model_benchmark!(ocean_model_test, arch;
                                    use_benchmarktools = false,
                                    bottom_height = ocean_bathymetry())

# Simple advection benchmark
@show trial2 = run_model_benchmark!(ocean_model_test, arch;
                                    use_benchmarktools = false,
                                    momentum_advection = VectorInvariant(),
                                    bottom_height = ocean_bathymetry())

@show trial3 = run_model_benchmark!(ocean_model_test, arch;
                                    use_benchmarktools = false,
                                    momentum_advection = VectorInvariant(),
                                    tracer_advection = Centered(),
                                    bottom_height = ocean_bathymetry())