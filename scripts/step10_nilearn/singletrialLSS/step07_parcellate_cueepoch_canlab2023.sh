#!/bin/bash -l
#SBATCH --job-name=parcel
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=16gb
#SBATCH --time=06:00:00
#SBATCH -o ./dartfs-hpc/scratch/f0042x1/parcel/GLM_%A_%a.o
#SBATCH -e ./dartfs-hpc/scratch/f0042x1/parcel/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard

conda activate spacetop_env
# RUNTYPELIST=("pain" "vicarious" "cognitive")
# RUNTYPE=${RUNTYPELIST[${SLURM_ARRAY_TASK_ID}]}
# echo ${RUNTYPE}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR='/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
python ${MAINDIR}/scripts/step10_nilearn/singletrialLSS/step07_parcellate_cueepoch_canlab2023.py --slurm_id ${ID} #--runtype "pain"
