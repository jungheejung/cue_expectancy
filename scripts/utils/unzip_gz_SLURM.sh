#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=16G
#SBATCH --time=03:00:00
#SBATCH -o ./utils/fir_%A_%a.o
#SBATCH -e ./utils/fir_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-3%10

conda activate spacetop_env
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR='/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
python ${MAINDIR}/scripts/utils/unzip_gz.py \
--slurm-id ${ID} 