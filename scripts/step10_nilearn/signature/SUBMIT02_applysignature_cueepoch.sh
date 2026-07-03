#!/bin/bash -l
#SBATCH --job-name=sig_cue
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=12gb
#SBATCH --time=03:00:00
#SBATCH -o ./log_cueepoch/sig_%A_%a.o
#SBATCH -e ./log_cueepoch/sig_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1
# ------------------------------------------------------------------------------
# Apply SIIPS (+ NPS cross-check) as weighted PATTERNS to CUE-EPOCH single
# trials, via CANlab apply_mask(...,'pattern_expression'). MATLAB twin of the
# python signature pipeline; based on SUBMIT02_extractROI.sh.
#
# NOTE 1: single array task -- step02_applysignature_cueepoch.m loops the
#         signatures internally (no --slurm-id array like the python version).
# NOTE 2: the .m derives main_dir from pwd (fileparts^3), so we cd into the
#         script's own dir first; otherwise main_dir resolves wrong.
# NOTE 3: SIIPS/NPS weight maps live in Multivariate_signature_patterns +
#         MasksPrivate -- both added below (the ROI sbatch only needs the atlas).
# ------------------------------------------------------------------------------
mkdir -p ./log_cueepoch
MAINDIR=$(git rev-parse --show-toplevel 2>/dev/null || echo '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue')
SIGDIR="${MAINDIR}/scripts/step10_nilearn/signature"

module load matlab/r2020a
cd "${SIGDIR}"
matlab -nodisplay -nosplash -batch "\
addpath('/optnfs/el7/spm/spm12'); \
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); \
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate')); \
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks')); \
step02_applysignature_cueepoch('cue');"
