#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=12gb
#SBATCH --time=01:00:00
#SBATCH -o ./log/PE_%A_%a.o
#SBATCH -e ./log/PE_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-133
##20-133%100

# TODO:
# [x] submit PE per participant
# [x] make sure log dir name changed
# [x] mkdir log dir
# [ ] other parameters to change?
conda activate spacetop_env
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
BETADIR="${MAINDIR}/analysis/fmri/nilearn/singletrial_rampupplateau"
SAVEDIR="${MAINDIR}/analysis/fmri/nilearn/deriv04_covariate"
python ${MAINDIR}/scripts/step10_nilearn/singletrial_covariates/step01_numpify.py \
--slurm-id ${ID} \
--input-betadir ${BETADIR} \
--save-npydir ${SAVEDIR}
