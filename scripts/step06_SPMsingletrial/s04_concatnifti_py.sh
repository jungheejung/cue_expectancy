#!/bin/bash -l
#SBATCH --job-name=concat
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=5gb
#SBATCH --time=01:00:00
#SBATCH -o ./log/concat_%A_%a.o
#SBATCH -e ./log/concat_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard

source /optnfs/common/miniconda3/etc/profile.d/conda.sh
conda activate spacetop_env

MAINDIR=/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step06_SPMsingletrial

hostname -s
python ./s04_SIDEPROJECT_concatnifti.py
