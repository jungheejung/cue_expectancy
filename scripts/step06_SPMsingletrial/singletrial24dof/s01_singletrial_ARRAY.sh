#!/bin/bash -l
#SBATCH --job-name=lsa
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=05:00:00
#SBATCH -o ./log/single_%A_%a.o
#SBATCH -e ./log/single_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=9-64%8

subjects=(0 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 24 25 26 28 29 30 31 32 33 35 37 43 47 51 53 55 58 60 61 62 63 64 65 66 68 69 70 71 73 74 75 76 77 78 79 80 81 82 84 85 86 87 88 89 92)
PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
MAIN_DIR=$(dirname $(dirname "$PWD"))
CANLABCORE_DIR="'/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'"
SPM12_DIR="'/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'"

# SUBJECT=${SLURM_ARRAY_TASK_ID//[!0-9]/}
# echo ${PARTICIPANT_LABEL}
module load matlab/r2020a
matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath(${SPM12_DIR}); addpath(genpath(${CANLABCORE_DIR})); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step06_SPMsingletrial')); s01_singletrial_onesubject($PARTICIPANT_LABEL);"
