using NESAPOceananigans

# By default the problem size is 1440×600×50 which corresponds to about 
# 10 GB for the full ocean testcase which should saturate the GPU compute
set_problem_size!(10, 10, 10)

arch = CPU()

# Tracer advection benchmark
trial = run_model_benchmark!(tracer_kernel_test, arch)

# Simple advection benchmark
trail = run_model_benchmark!(tracer_kernel_test, arch;
                             tracer_advection = Centered())