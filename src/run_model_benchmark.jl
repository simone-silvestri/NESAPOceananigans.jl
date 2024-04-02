"""
    run_model_benchmark(test_function, test_args, test_kwargs; use_benchmarktools = true)

Run a benchmark in the NESAPOceananigans repository.

# Arguments
============

- `test_function`: The benchmark to test. for example `tracer_kernel_test`

- `arch`: The architecture to pass to the benchmark test.

# Keyword Arguments
===================

- `test_kwargs`: The keyword arguments to pass to the test function. for example `tracer_kernel_test`
                 accepts `tracer_advection`, `bottom_height`, and `active_cells_map`

- `use_benchmarktools`: Whether to use BenchmarkTools for benchmarking. Default is `true`.

- `number_of_samples`: how many times to run the benchmark to collect profiling data
"""
function run_model_benchmark!(test_function,
                              arch; 
                              use_benchmarktools = true,
                              number_of_samples = 10,
                              test_kwargs...)

    model = test_function(arch; test_kwargs...)

    if use_benchmarktools
        benchmark = @benchmark begin
            CUDA.@sync run_benchmark!(model, test_function)
        end samples = number_of_samples
    else
        for samples in number_of_samples
            run_benchmark!(model, test_function)
            GC.gc()
        end
        benchmark = nothing
    end

    return benchmark
end

TendencyTests = Union{typeof(tracer_kernel_test), typeof(momentum_kernel_test)}

run_benchmark!(model, test_function)   = time_step!(model, 1)
run_benchmark!(model, ::TendencyTests) = compute_tendencies!(model)
