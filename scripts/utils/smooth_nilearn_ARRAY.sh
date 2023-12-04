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


CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SINGLETRIAL_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial"
SCRIPT_DIR="$(realpath "${PWD}/..")"
MAIN_DIR="$(realpath "${SCRIPT_DIR}/..")"
SAVE_DIR="/dartfs-hpc/scratch/f0042x1/singletrial_smooth"
mylist=($(find ${SINGLETRIAL_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
PARTICIPANT_LABEL="$(basename "${mylist[$((SLURM_ARRAY_TASK_ID))]}")"
# quoted_FMRIPREP_DIR="$(printf " %q" "${FMRIPREP_DIR}")"
# quoted_CANLABCORE_DIR="$(printf " %q" "${CANLABCORE_DIR}")"
echo "* total of ${#mylist[@]} participants in ${SINGLETRIAL_DIR}"
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
# echo ${MAIN_DIR}

conda activate space_env
python ${SCRIPT_DIR}/smooth_nilearn.py --sub ${PARTICIPANT_LABEL}