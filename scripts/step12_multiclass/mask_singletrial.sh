#!/bin/bash -l
#SBATCH --job-name=mask
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=01:00:00
#SBATCH -o ./mask/np_%A_%a.o
#SBATCH -e ./mask/np_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-15%10

conda activate spacetop_env
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"

python ${MAINDIR}scripts/step12_multiclass/mask_singletrial.py \
--slurm-id ${ID} \
--main-dir ${MAINDIR} 

