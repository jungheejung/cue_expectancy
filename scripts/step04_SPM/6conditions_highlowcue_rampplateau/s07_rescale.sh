#!/bin/bash -l
#SBATCH --job-name=rescale
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=01:00:00
#SBATCH -o ./output/GLM_%A_%a.o
#SBATCH -e ./output/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=4-6

CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SPM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"
MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue" #"$(realpath "${PWD}/../..")"
SPM_DIR="${MAIN_DIR}/analysis/fmri/spm/univariate/model01_6cond_highlowcue_rampplateau";
TASK="pain"
mylist=($(find ${SPM_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
IFS=$'\n' sorted=($(sort <<<"${mylist[*]}") )
PARTICIPANT_LABEL="$(basename "${sorted[$((SLURM_ARRAY_TASK_ID-1))]}")"
echo "* total of ${#mylist[@]} participants in ${INPUT_DIR}"
echo "* array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}

module load matlab/r2020a
matlab -nodesktop -nosplash -batch 'opengl("save","hardware"); rootgroup = settings;rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = "v7.3"; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = "v7.3"; addpath(genpath('"'${CANLABCORE_DIR}'"')); addpath(genpath('"'${SPM_DIR}'"')); addpath(genpath('"'${PWD}'"')); s07_rescalecontrasts('"'${PARTICIPANT_LABEL}'"','"'${MAIN_DIR}'"', '"'${SPM_DIR}'"', '"'${TASK}'"');'
