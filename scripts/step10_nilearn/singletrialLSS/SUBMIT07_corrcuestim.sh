#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=16gb
#SBATCH --time=06:00:00
#SBATCH -o ./log_corr/GLM_%A_%a.o
#SBATCH -e ./log_corr/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-5
##5
##5
##5
##5
##99

conda activate spacetop_env
# RUNTYPELIST=("pain" "vicarious" "cognitive")
# RUNTYPE=${RUNTYPELIST[${SLURM_ARRAY_TASK_ID}]}
# echo ${RUNTYPE}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR='/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
python ${MAINDIR}/scripts/step10_nilearn/singletrialLSS/step07_corr_cue_stim.py --slurm_id ${ID} #--runtype "pain"
