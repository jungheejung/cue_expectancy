#!/bin/bash -l
#SBATCH --job-name=vif
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=16gb
#SBATCH --time=0:30:00
#SBATCH -o ./vif_log/vif_%A_%a.o
#SBATCH -e ./vif_log/vif_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-130

# SPM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"
# MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue" #"$(realpath "${PWD}/../..")"
# INPUT_DIR="${MAIN_DIR}/analysis/fmri/smooth6mm"
FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep"
mylist=($(find ${FMRIPREP_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
IFS=$'\n' sorted=($(sort <<<"${mylist[*]}") )
SUB_ID="$(basename "${sorted[$((SLURM_ARRAY_TASK_ID-1))]}")"
echo "* total of ${#mylist[@]} participants in ${INPUT_DIR}"
echo "* array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${SUB_ID}

OUTPUT_FNAME="vif_${SUB_ID}"
OUTPUT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/qc"
NB_ARGS=${SUB_ID} jupyter nbconvert \
--execute \
--to html_toc \
--no-input vif_calc_QC.ipynb \
--ExecutePreprocessor.timeout=300 \
--output ${OUTPUT_FNAME } \
--output-dir ${OUTPUT_DIR}