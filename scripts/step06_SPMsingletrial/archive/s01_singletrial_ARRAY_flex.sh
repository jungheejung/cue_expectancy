#!/bin/bash -l
#SBATCH --job-name=flex_plateau
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=10:00:00
#SBATCH -o ./log/single_%A_%a.o
#SBATCH -e ./log/single_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-3

# find the conjunction of biopac TTL directories and 
# fmriprepped derectories. 
# TODO: if participant has TTL data, use it
# if not, 
# subjects=(6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 24 25 26 28 29 30 31 32 33 35 37 43 47 51 53 55 58 60)
subjects=(6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 24 25 26 28 29 30 31 32 33 34 35 36 37 38 39 40 41 43 44 46 47 50 51 52 53 55 56 57 58 59 60 61 62 63 64 65 66 68 69 70 71 73 74 75 76 77 78 79 80 81 82 84 85 86 87 88 89 92)
# SUB_DIRS=$(find . -maxdepth 1 -type d  -name "sub-*")
# for i in ${SUB_DIRS[@]}
# do
# SUB_DIR="$(basename -- ${i})"
# echo "${SUB_DIR}
# done


KEYWORD="'plateau'" #"'early'" "'late'" "'plateau'" "'post'" "'nottl'"

# PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SCRIPT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step04_SPM"
# SUBJECT=${SLURM_ARRAY_TASK_ID//[!0-9]/}
echo ${SLURM_ARRAY_TASK_ID} ${KEYWORD}
module load matlab/r2020a

#matlab -nodisplay -nosplash -batch "addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step04_SPM')); s00_smooth($PARTICIPANT_LABEL);"

matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step06_SPMsingletrial')); s01_singletrial_onesubject_flex(${SLURM_ARRAY_TASK_ID}, ${KEYWORD});"

