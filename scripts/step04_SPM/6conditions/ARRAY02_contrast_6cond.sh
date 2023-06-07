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
#SBATCH --array=1-100%10


CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SPM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"
MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue" #"$(realpath "${PWD}/../..")"
SPMINPUT_DIR="${MAIN_DIR}/analysis/fmri/spm/univariate/model01_6cond/1stLevel"

### GPT
FILE="${MAIN_DIR}/scripts/step00_qc/qc03_fmriprep_visualize/bad_runs.json"
BAD=$(jq -r 'keys[]' ${FILE})   
IFS=$'\n' bad_array=($BAD)
subdirectories=($(find "$SPMINPUT_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))

filtered_subdirectories=()
for subdirectory in "${subdirectories[@]}"; do
    skip=false
    for bad_participant in "${bad_array[@]}"; do
        if [[ $subdirectory == $bad_participant ]]; then
            skip=true
            break
        fi
    done
    if ! $skip; then
        filtered_subdirectories+=("$subdirectory")
    fi
done
# Print the filtered subdirectories
sorted_subdirectories=($(printf '%s\n' "${filtered_subdirectories[@]}" | sort))
printf '%s\n' "${sorted_subdirectories[@]}"
PARTICIPANT_LABEL="$(basename "${sorted_subdirectories[$((SLURM_ARRAY_TASK_ID-1))]}")"

echo ${PARTICIPANT_LABEL}
module load matlab/r2020a
matlab -nodisplay -nosplash -batch "addpath('${SPM_DIR}'); addpath(genpath('${CANLABCORE_DIR}')); addpath(genpath('${MAIN_DIR}')); s02_contrast_6cond_scale('${PARTICIPANT_LABEL}', '${SPMINPUT_DIR}', '${MAIN_DIR}');"
