#!/bin/bash -l
#SBATCH --job-name=roi_cue
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=05:00:00
#SBATCH -o ./log_cueepoch/roi_%A_%a.o
#SBATCH -e ./log_cueepoch/roi_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1
# ------------------------------------------------------------------------------
# Pain-pathway ROI averages for CUE-EPOCH single trials (unweighted regions),
# via CANlab extract_roi_averages. Cue-epoch twin of SUBMIT02_extractROI.sh.
# The .m derives main_dir from pwd (fileparts^3), so we cd into its dir first.
# ------------------------------------------------------------------------------
mkdir -p ./log_cueepoch
MAINDIR=$(git rev-parse --show-toplevel 2>/dev/null || echo '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue')
ROIDIR="${MAINDIR}/scripts/step10_nilearn/singletrialLSS"

module load matlab/r2020a
cd "${ROIDIR}"
matlab -nodisplay -nosplash -batch "\
addpath('/optnfs/el7/spm/spm12'); \
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); \
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate')); \
addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Atlases_and_parcellations')); \
step02_extract_ROI_cueepoch('cue');"
