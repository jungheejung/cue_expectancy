#!/bin/bash -l
#SBATCH --job-name=glmsingle
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=10:00:00
#SBATCH -o ./log/single_%A_%a.o
#SBATCH -e ./log/single_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#####SBATCH --array=1-2

SLURM_ID=${SLURM_ARRAY_TASK_ID}
conda activate spacetop_env
python g01_glmsingle.py --slurm_id 73  --runtype "pain"
