#!/bin/bash -l
#SBATCH --job-name=cc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem-per-cpu=40G
#SBATCH --time=3-00:00:00
#SBATCH -o ./log/skl_%A_%a.o
#SBATCH -e ./log/skl_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=2
conda activate spacetop_env
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
SINGLETRIALDIR=${MAINDIR}/analysis/fmri/nilearn/singletrial
OUTPUTDIR=${MAINDIR}/analysis/fmri/nilearn/crossprediction
CANLABCOREDIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore"

python ${PWD}/c01_crossprediction_snaglab.py \
--slurm-id ${ID} \
--maindir ${MAINDIR} \
--singletrialdir ${SINGLETRIALDIR} \
--outputdir ${OUTPUTDIR} \
--canlabcoredir ${CANLABCOREDIR}
