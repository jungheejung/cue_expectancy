#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --task=4
#SBATCH --mem-per-cpu=16gb
#SBATCH --time=05:00:00
#SBATCH -o ./log_glm_cueonly/GLM_%A_%a.o
#SBATCH -e ./log_glm_cueonly/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=4-30%20
#80%20

mkdir -p log_glm_cueonly
# 7,8,10,11,24,28,29,30,31,32,33,34,35,36,37,38,39,40,41,43,44,46,47,50,51,52,53,55,56,57,58,59,60,61,62,64,65 complete
#subjects=(2 3 4 5 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 25 26 28 29 30 31 32 33 34 35 36 37 38 39 40 41 43 44 46 47 50 51 52 53 55 56 57 58 59 60 61 62 63 64 65 66 68 69 70 71 73 74 75 76 77 78 79 80 81 82 83 84 85 86 88 89 92)
subjects=(6 9 13 18 19 20 21 24 29 32 34 37 38 39 40 44 46 50 57 58 62 63 64 70 73 74 76 78 81 82 83 86 88 89 92)
PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID - 1 ))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SCRIPT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM"
FMRIPREP_DIR="'/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep'"
SMOOTH_DIR="'/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/smooth_6mm'"
MAIN_DIR="'/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social'"


module load matlab/r2021a 
#-nosplash -nojvm -nodesktop -r
matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM/model03_CEScsA_24motion')); s01_glm_cueonly(${PARTICIPANT_LABEL});"
