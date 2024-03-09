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
#SBATCH --array=1-13


CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep"
SCRIPT_DIR="$(realpath "${PWD}/..")"
MAIN_DIR="$(realpath "${SCRIPT_DIR}/..")"
SAVE_DIR="${MAIN_DIR}/analysis/fmri/smooth6mm"
mylist=($(find ${FMRIPREP_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
PARTICIPANT_LABEL="$(basename "${mylist[$((SLURM_ARRAY_TASK_ID))]}")"
quoted_FMRIPREP_DIR="$(printf " %q" "${FMRIPREP_DIR}")"
quoted_CANLABCORE_DIR="$(printf " %q" "${CANLABCORE_DIR}")"
echo "* total of ${#mylist[@]} participants in ${FMRIPREP_DIR}"
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
echo ${MAIN_DIR}
module load matlab/r2020a

echo matlab -nodisplay -nosplash -batch 'addpath("/optnfs/el7/spm/spm12");
addpath(genpath('"'${CANLABCORE_DIR}'"'));
addpath(genpath('"'${MAIN_DIR}'"'));
addpath(genpath('"'${FMRIPREP_DIR}'"'));
./s00_smooth('"'${PARTICIPANT_LABEL}'"','"'${FMRIPREP_DIR}'"','"'${SAVE_DIR}'"','"'${MAIN_DIR}'"');'


matlab -nodisplay -nosplash -batch 'addpath("/optnfs/el7/spm/spm12");addpath(genpath('"'${CANLABCORE_DIR}'"'));addpath(genpath('"'${MAIN_DIR}'"'));addpath(('"'${SCRIPT_DIR}'"'));addpath(genpath('"'${FMRIPREP_DIR}'"'));s00_smooth('"'${PARTICIPANT_LABEL}'"','"'${FMRIPREP_DIR}'"','"'${SAVE_DIR}'"','"'${MAIN_DIR}'"');'
