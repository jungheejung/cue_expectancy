#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=06:00:00
#SBATCH -o ./log_glm/GLM_%A_%a.o
#SBATCH -e ./log_glm/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-133%10

CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SPM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"
MAIN_DIR="$(realpath "${PWD}/../..")"
INPUT_DIR="${MAIN_DIR}/analysis/fmri/smooth6mm"
mylist=($(find ${INPUT_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
PARTICIPANT_LABEL="$(basename "${mylist[$((SLURM_ARRAY_TASK_ID))]}")"
echo "* total of ${#mylist[@]} participants in ${INPUT_DIR}"
echo "* array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}

module load matlab/r2020a
matlab -nodesktop -nosplash -batch 'opengl("save","hardware"); rootgroup = settings;rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = "v7.3"; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = "v7.3";addpath(genpath('"'${CANLABCORE_DIR}'"'));addpath(genpath('"'${SPM_DIR}'"'));addpath(genpath('"'${MAIN_DIR}'"'));addpath(genpath('"'${INPUT_DIR}'"'));addpath(genpath('"'${PWD}'"'));s01_glm('"'${PARTICIPANT_LABEL}'"','"'${INPUT_DIR}'"','"'${MAIN_DIR}'"');'

echo "matlab -nodesktop -nosplash -batch 'opengl("save","hardware"); 
rootgroup = settings; 
rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = "v7.3"; 
rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = "v7.3";
addpath(genpath('"'${CANLABCORE_DIR}'"'));
addpath(genpath('"'${SPM_DIR}'"')); 
addpath(genpath('"'${MAIN_DIR}'"')); 
addpath(genpath('"'${INPUT_DIR}'"')); 
addpath(genpath('"'${PWD}'"'))
s01_glm('"'${PARTICIPANT_LABEL}'"','"'${INPUT_DIR}'"','"'${MAIN_DIR}'"');'"