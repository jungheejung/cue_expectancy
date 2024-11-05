#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=40gb
#SBATCH --time=01:00:00
#SBATCH -o ./log_roi/GLM_%A_%a.o
#SBATCH -e ./log_roi/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-10

echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
ID=$((SLURM_ARRAY_TASK_ID-1))
MAINDIR='/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
INPUT_DIR = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_brainmask';
SINGLETRIAL='/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau';

module load matlab/r2020a
matlab -nodisplay -nosplash -batch 'addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'));  addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MasksPrivate'));addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Atlases_and_parcellations')); /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step10_nilearn/singletrialLSS/step02_apply_NPSbatch('"'${ID}'"', '"'${INPUT_DIR}'"', '"'${SINGLETRIAL}'"');'


#!/bin/bash

# Metadata information
CODE_NAME="step02_apply_NPSbatch_corr"
CODE_PATH=scripts/step10_nilearn/signature/step02_apply_NPSbatch_corr.m
DESCRIPTION="This code applies NPS to extracted single trials from fMRI data, loading fMRI single-trial filenames, applying SIIPS correlations, and saving results as a CSV file."
INPUT_FILES_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau"
OUTPUT_DIR="/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab_corr"
OUTPUT_PATH="$OUTPUT_DIR/TODOmetadata.json"


# Gather input files
if [ -d "$INPUT_FILES_DIR" ]; then
    INPUT_FILES=$(ls "$INPUT_FILES_DIR"/*.nii.gz | xargs -n 1 basename | jq -R . | jq -s .)
else
    INPUT_FILES="\"Directory does not exist\""
fi

# Create JSON
cat <<EOF > "$OUTPUT_PATH"
{
    "code_name": "$CODE_NAME",
    "code_path": "$CODE_PATH",
    "description": "$DESCRIPTION",
    "input_files_directory": "$INPUT_FILES_DIR",
    "input_files": $INPUT_FILES,
    "output_directory": "$OUTPUT_DIR"
}
EOF

echo "Metadata JSON created at $OUTPUT_PATH"


