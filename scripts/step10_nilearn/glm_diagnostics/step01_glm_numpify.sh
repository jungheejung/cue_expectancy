#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=12gb
#SBATCH --time=01:00:00
#SBATCH -o ./log/rsa_%A_%a.o
#SBATCH -e ./log/rsa_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-133%10


conda activate rsa
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR='/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
python ${MAINDIR}/scripts/step10_nilearn/glm_diagnostics/step01_glm_numpify_ttest.py --slurm-id ${ID}
