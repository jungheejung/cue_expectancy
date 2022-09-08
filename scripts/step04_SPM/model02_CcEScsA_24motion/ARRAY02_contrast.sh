#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=00:30:00
#SBATCH -o ./log_con/contrast_%A_%a.o
#SBATCH -e ./log_con/contrast_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-61%5

subjects=(7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 24 28 29 30 31 32 33 35 36 37 38 39 40 41 43 44 46 47 50 51 52 53 55 56 57 58 59 60 61 62 64 65 66 68 69 70 71 73 74 75 76 77 78 79 80 81)
PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID - 1 ))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SCRIPT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM"
FMRIPREP_DIR="'/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep'"
SMOOTH_DIR="'/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/smooth_6mm'"
MAIN_DIR="'/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social'"


module load matlab/r2021a 
#-nosplash -nojvm -nodesktop -r
matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM/model02_CcEScsA_24motion')); s02_contrast_cueonly(${PARTICIPANT_LABEL});"
