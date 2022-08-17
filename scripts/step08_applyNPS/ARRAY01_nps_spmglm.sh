#!/bin/bash -l
#SBATCH --job-name=nps
#SBATCH --nodes=1
#SBATCH --ntasks=3
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=06:00:00
#SBATCH -o ./log/nps_%A_%a.o
#SBATCH -e ./log/nps_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=20-29%5
module load matlab/r2020a

matlab -nodisplay -nosplash -batch "addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step08_applyNPS')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate')); applyNPS_spmglm(${SLURM_ARRAY_TASK_ID});"

