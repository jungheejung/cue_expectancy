#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=00:20:00
#SBATCH -o ./log_con/contrast_%A_%a.o
#SBATCH -e ./log_con/contrast_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-6
#5%10

CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SPM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"
MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue" #"$(realpath "${PWD}/../..")"
INPUT_DIR="${MAIN_DIR}/analysis/fmri/smooth6mm"

FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep"
SPMINPUT_DIR="${MAIN_DIR}/analysis/fmri/spm/univariate/model01_6cond/1stLevel"
#mylist=($(find ${SPMINPUT_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
#IFS=$'\n' sorted=($(sort <<<"${mylist[*]}") )
#PARTICIPANT_LABEL="$(basename "${sorted[$((SLURM_ARRAY_TASK_ID-1))]}")"
#echo "* total of ${#mylist[@]} participants in ${INPUT_DIR}"
#echo "* array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}

SUB=(0,13,14,18,19,24,26,28,32,33,35,36,37,38,39,41,47,52,56,57,60,61,62,64,66,68,69,71,74,75,76,77,78,80,83,84,85,86,88,89,93,95,98,99,101,103,104,106,107,109,112,115,116,119,120,123,124,126,128,129,130,131,132,133)
PARTICIPANT_LABEL=$(printf "sub-%04d" ${SUB[$((SLURM_ARRAY_TASK_ID - 1 ))]})

module load matlab/r2020a
matlab -nodisplay -nosplash -batch "addpath('${SPM_DIR}'); addpath(genpath('${CANLABCORE_DIR}')); addpath(genpath('${MAIN_DIR}')); s02_contrast_6cond('${PARTICIPANT_LABEL}', '${INPUT_DIR}', '${MAIN_DIR}');"
