#!/bin/bash -l
#SBATCH --job-name=lsa
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=10:00:00
#SBATCH -o ./log/single_%A_%a.o
#SBATCH -e ./log/single_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-2

subjects=(0 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 24 25 26 28 29 30 31 32 33 35 37 43 47 51 53 55 58 60)
PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
MAIN_DIR=$(dirname $(dirname "$PWD"))
CANLABCORE_DIR='/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'
SPM12_DIR='/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'

# SUBJECT=${SLURM_ARRAY_TASK_ID//[!0-9]/}
# echo ${PARTICIPANT_LABEL}
module load matlab/r2020a
matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath(${SPM12_DIR}); addpath(genpath(${CANLABCORE_DIR})); addpath(genpath($PWD)); s01_singletrial_onesubject($PARTICIPANT_LABEL);"

