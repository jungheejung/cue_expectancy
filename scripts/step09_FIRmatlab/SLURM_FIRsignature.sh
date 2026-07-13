#!/bin/bash -l
#SBATCH --job-name=firsig
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=5:00:00
#SBATCH -o ./log_signature/firsig_%A_%a.o
#SBATCH -e ./log_signature/firsig_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-100%50
# -----------------------------------------------------------------------------
# Signature (NPS / NPSpos / SIIPS) FIR timecourses -> per-TR pattern-expression.
# Mirror of SLURM_FIRttl2_atlas_pathway.sh but calls FIR_spm_signature and writes
# to a separate save dir. Same 6-arg signature:
#   FIR_spm_signature(sub, onset_dir, main_dir, fmriprep_dir, badruns_json, save_dir)
# -----------------------------------------------------------------------------
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
ONSET_DIR="${MAIN_DIR}/data/fmri/fmri01_onset/onset02_SPM"
FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep"
BADRUNJSON="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/bad_runs.json"
SAVE_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/fir/signature"
SPM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"
MASK_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks"

mkdir -p ./log_signature "${SAVE_DIR}"
mylist=($(find ${FMRIPREP_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
IFS=$'\n' sorted=($(sort <<<"${mylist[*]}") )
PARTICIPANT_LABEL="$(basename "${sorted[$((SLURM_ARRAY_TASK_ID-1))]}")"
echo "* array id: ${SLURM_ARRAY_TASK_ID}, subject id: ${PARTICIPANT_LABEL}"

module load matlab/r2024a
matlab -nodesktop -nosplash -batch 'opengl("save","hardware"); rootgroup = settings;rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = "v7.3"; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = "v7.3";addpath(genpath('"'${CANLABCORE_DIR}'"'));addpath(genpath('"'${SPM_DIR}'"'));addpath(genpath('"'${MASK_DIR}'"'));addpath(genpath('"'${MAIN_DIR}'"'));addpath(genpath('"'${ONSET_DIR}'"'));addpath(genpath('"'${PWD}'"'));FIR_spm_signature('"'${PARTICIPANT_LABEL}'"','"'${ONSET_DIR}'"','"'${MAIN_DIR}'"', '"'${FMRIPREP_DIR}'"', '"'${BADRUNJSON}'"',  '"'${SAVE_DIR}'"');'
