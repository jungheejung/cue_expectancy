#!/bin/bash -l
#SBATCH --job-name=vps
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=02:00:00
#SBATCH -o ./log/vps_%A_%a.o
#SBATCH -e ./log/vps_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-13
module load matlab/r2020a

matlab -nodisplay -nosplash -batch "addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step08_applyNPS')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate')); applyVPS_spmglm(${SLURM_ARRAY_TASK_ID});"

