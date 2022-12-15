#!/bin/bash -l
#SBATCH --job-name=smooth
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=05:00:00
#SBATCH -o ./smooth/smooth_%A_%a.o
#SBATCH -e ./smooth/smooth_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-133%10

# subjects=(1 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 24 25 26 28 29 30 31 32 33 34 35 36 37 38 39 40 41 43 44 46 47 50 51 52 53 55 56 57 58 59 60 61 62 63 64 65 66 68 69 70 71 73 74 75 76 77 78 79 80 81 82 84 85 86 87 88 89 92)
# PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID))]}

CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep"
SCRIPT_DIR="$(realpath "${PWD}/..")"
MAIN_DIR="$(realpath "${SCRIPT_DIR}/..")"
SAVE_DIR="${MAIN_DIR}/analysis/fmri/smooth6mm"
mylist=($(find ${FMRIPREP_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
PARTICIPANT_LABEL=${mylist[$((SLURM_ARRAY_TASK_ID))]}
echo "total of ${#mylist[@]} participants in ${FMRIPREP_DIR}"
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}

module load matlab/r2020a

# matlab -nodisplay -nosplash -batch "addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM')); s00_smooth($PARTICIPANT_LABEL);"
matlab -nodisplay -nosplash -batch 'addpath('"/optnfs/el7/spm/spm12"'); \
addpath(genpath('"${CANLABCORE_DIR}"')); \
addpath(genpath('"${MAIN_DIR}"')); \
addpath(genpath('"${FMRIPREP_DIR}"')); \
s00_smooth('${PARTICIPANT_LABEL}', '${FMRIPREP_DIR}', '${SAVE_DIR}', '${MAIN_DIR}');"

