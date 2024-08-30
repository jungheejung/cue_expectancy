#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=12gb
#SBATCH --time=01:00:00
#SBATCH -o ./log_PE/PE_%A_%a.o
#SBATCH -e ./log/PE_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-5
##20-133%100

conda activate spacetop_env
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
SAVEDIR="${MAINDIR}/analysis/fmri/nilearn/deriv04_covariate/"
CANLABCORE="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore"
python ${MAINDIR}/scripts/step10_nilearn/covariates/singletrial_covPE.py \
--slurm_id ${ID} \
--tasktype "pain" \
--fmri-event "stimulus" \
--beh-regressor "PE_mdl2" \
--beh-savename "cov_PE" \
--maindir ${MAINDIR} \
--savedir ${SAVEDIR} \
--canlabcore ${CANLABCORE}
