#!/bin/bash -l
#SBATCH --job-name=rsamodel
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=12gb
#SBATCH --time=06:00:00
#SBATCH -o ./log_model/model_%A_%a.o
#SBATCH -e ./log_model/model_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard

conda activate rsa
MAINDIR='/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
python ${MAINDIR}/scripts/step10_nilearn/RSA/RSA03_model.py
