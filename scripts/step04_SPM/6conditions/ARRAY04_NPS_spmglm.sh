#!/bin/bash -l
#SBATCH --job-name=nps
#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=02:00:00
#SBATCH -o ./log_nps/nps_%A_%a.o
#SBATCH -e ./log_nps/nps_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=4-15,16-50%10

# SLURM_ARRAY_TASK_ID is the contrast number
MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
module load matlab/r2020a
matlab -nodisplay -nosplash -batch "addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate/Masks_private/2013_Wager_NEJM_NPS')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step04_SPM/6conditions')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate')); s04_applyNPS_spmglm(${SLURM_ARRAY_TASK_ID}, '${MAIN_DIR}');"

