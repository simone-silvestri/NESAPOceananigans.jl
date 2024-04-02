"""
    run_model_benchmark(test_function, test_args, test_kwargs; use_benchmarktools = true)

Run a benchmark in the NESAPOceananigans repository.

# Arguments
============

- `test_function`: The function to test. for example ``

- `test_args`: The arguments to pass to the test function.

- `test_kwargs`: The keyword arguments to pass to the test function.

- `use_benchmarktools`: Whether to use BenchmarkTools for benchmarking. Default is `true`.

"""
function run_model_benchmark(test_function,
                             test_args, 
                             test_kwargs;
                             use_benchmarktools = true)

    model = test_function(test_args...; test_kwargs...)

    if use_benchmarktools
        @benchmark begin
            CUDA.@sync time_step!(model, 1)
        end
    else
        time_step!(model, 1)
        GC.gc()
    end
end
