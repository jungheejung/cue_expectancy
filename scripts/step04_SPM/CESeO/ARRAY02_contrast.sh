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
#SBATCH --array=1-133%20

CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SPM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"
MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue" #"$(realpath "${PWD}/../..")"
INPUT_DIR="/dartfs-hpc/scratch/f0042x1/spm/model02_CESeO"
SAVE_DIR="/dartfs-hpc/scratch/f0042x1/spm/model02_CESeO/1stlevel"
FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep"
SPMINPUT_DIR="${MAIN_DIR}/analysis/fmri/spm/univariate/model02_CESeO/"
mylist=($(find ${SPMINPUT_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
IFS=$'\n' sorted=($(sort <<<"${mylist[*]}") )
PARTICIPANT_LABEL="$(basename "${sorted[$((SLURM_ARRAY_TASK_ID-1))]}")"
echo "* total of ${#mylist[@]} participants in ${INPUT_DIR}"
echo "* array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}

module load matlab/r2020a
matlab -nodisplay -nosplash -batch "addpath('${SPM_DIR}'); addpath(genpath('${CANLABCORE_DIR}')); addpath(genpath('${MAIN_DIR}')); s02_contrast('${PARTICIPANT_LABEL}', '${INPUT_DIR}', '${MAIN_DIR}');"
