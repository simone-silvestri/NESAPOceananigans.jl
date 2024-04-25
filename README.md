# NESAPOceananigans

[![Build Status](https://github.com/simone-silvestri/NESAPOceananigans.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/simone-silvestri/NESAPOceananigans.jl/actions/workflows/CI.yml?query=branch%3Amain)

Performance tests for the Oceananigans project.
Different Oceananigans' version are loaded in the `environment` folder

### main

The main branch of Oceananigans

### divergence_branch

This branch contains modified advection that allows branch divergence near boundaries.

URL of the branch:
https://github.com/CliMA/Oceananigans.jl/tree/ss/divergent-branches

### new_weno_branch

This branch contains a modified WENO algorithm that

1. Should allow saving registers as the computation is done incrementally on different stencils instead of calculating stencils all together
2. Makes use of `fast-math` for non-precision critial computations (the computation of WENO smoothness measures)

This branch is discussed in PR 3518
https://github.com/CliMA/Oceananigans.jl/pull/3518
