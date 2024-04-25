## README for New WENO Benchmark

This folder contains performance benchmarks for the Oceananigans project that use the ss/test-scaling.
This branch contains a modified WENO algorithm that

1. Should allow saving registers as the computation is done incrementally on different stencils instead of calculating stencils all together
2. Makes use of `fast-math` for non-precision critial computations (the computation of WENO smoothness measures)

This branch is discussed in PR 3518
https://github.com/CliMA/Oceananigans.jl/pull/3518