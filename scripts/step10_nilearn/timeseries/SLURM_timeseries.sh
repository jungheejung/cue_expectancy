#!/bin/bash -l
#SBATCH --job-name=subcortex
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem-per-cpu=40G
#SBATCH --time=01:00:00
#SBATCH -o ./log/sc_%A_%a.o
#SBATCH -e ./log/sc_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard

conda activate spacetop_env

MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
ID=$((SLURM_ARRAY_TASK_ID-1))
python ${PWD}/timeseries_extract.py --slurm-id ${ID}
