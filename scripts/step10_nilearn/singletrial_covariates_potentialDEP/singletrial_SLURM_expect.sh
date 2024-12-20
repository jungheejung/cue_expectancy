#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=12gb
#SBATCH --time=01:00:00
#SBATCH -o ./log/expect_%A_%a.o
#SBATCH -e ./log/expect_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-133%100

# TODO:
# [ ] submit PE per participant
# [ ] make sure log dir name changed
# [ ] mkdir log dir
# [ ] other parameters to change?
conda activate spacetop_env
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
SAVEDIR="${MAINDIR}/analysis/fmri/nilearn/covariate/"
python ${MAINDIR}/scripts/step10_nilearn/singletrial_covariates/singletrial_cov.py \
--slurm_id ${ID} \
--tasktype "cognitive" \
--fmri-event "stimulus" \
--beh-regressor "event02_expect_angle" \
--beh-savename "expectrating" \
--savedir ${SAVEDIR}
