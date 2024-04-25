#!/bin/bash
#SBATCH -C gpu
#SBATCH --ntasks-per-node=1
#SBATCH -q regular
#SBATCH --time=02:00:00
#SBATCH --account=m4672
#SBATCH -c 32
#SBATCH --gpus-per-task=1
#SBATCH --gpu-bind=none

source setup_perlmutter.sh

export SLURM_CPU_BIND="cores"
export CRAY_ACCEL_TARGET="nvidia80"

cat > launch.sh << EoF_s
#! /bin/sh
export CUDA_VISIBLE_DEVICES=0,1,2,3
exec \$*
EoF_s
chmod +x launch.sh

$JULIA --project --check-bounds=no -e 'using Pkg; Pkg.instantiate()'

NWORK=$((NNODES * NTASKS))
echo $NWORK

cd ${FOLDER}

for i in $(seq 0 10); do

echo "case number ${i}"

export CASE=${i}

srun --ntasks-per-node 1 dcgmi profile --pause
srun ncu -o report_output${i} --target-processes all --set full ./launch.sh $JULIA --check-bounds=no --project hydrostatic_benchmark.jl 
srun --ntasks-per-node 1 dcgmi profile --resume

done
