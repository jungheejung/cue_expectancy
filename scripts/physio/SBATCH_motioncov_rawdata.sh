#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=06:00:00
#SBATCH -o ./log_phys/GLM_%A_%a.o
#SBATCH -e ./log_phys/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=13-23%10

conda activate biopac
echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
${MAINDIR}/scripts/physio/plot_motioncov_rawdata.py --slurm_id ${ID} --session-num 1
