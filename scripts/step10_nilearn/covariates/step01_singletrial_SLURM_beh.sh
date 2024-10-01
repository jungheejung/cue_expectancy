#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=12gb
#SBATCH --time=00:10:00
#SBATCH -o ./log_expect_p/outcome_%A_%a.o
#SBATCH -e ./log_expect_p/outcome_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-133%100

conda activate spacetop_env
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
SAVEDIR="${MAINDIR}/analysis/fmri/nilearn/deriv04_covariate/"
CANLABCORE="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore"


# task options: 'pain','vicarious','cognitive'
# beh-regressors options 'expectrating' 'coutomerating'
python ${MAINDIR}/scripts/step10_nilearn/covariates/step01_singletrial_covbeh_negexpect.py \
--slurm-id ${ID} \
--tasktype "pain" \
--fmri-event "stimulus" \
--beh-regressor "expectrating" \
--beh-savename "cov_negexpectrating" \
--maindir ${MAINDIR} \
--savedir ${SAVEDIR} \
--canlabcore ${CANLABCORE}
