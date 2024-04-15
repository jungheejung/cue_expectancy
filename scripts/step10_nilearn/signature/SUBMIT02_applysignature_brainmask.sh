#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=02:00:00
#SBATCH -o ./log_glm/GLM_%A_%a.o
#SBATCH -e ./log_glm/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-50%10
#50%10 

conda activate spacetop_env
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR=$(git rev-parse --show-toplevel) #"/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
SINGLETRIALDIR="${MAINDIR}/analysis/fmri/nilearn/singletrial_rampupplateau"
SAVEDIR="${MAINDIR}/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_brainmask_resolution"
python ${MAINDIR}/scripts/step10_nilearn/signature/step02_applysignature_recursive_brainmask_resolution.py \
--slurm-id ${ID} \
--input-niidir ${SINGLETRIALDIR} \
--output-savedir ${SAVEDIR}

