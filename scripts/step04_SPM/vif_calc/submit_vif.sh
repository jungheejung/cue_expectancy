#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=16gb
#SBATCH --time=01:00:00
#SBATCH -o ./vif_log/GLM_%A_%a.o
#SBATCH -e ./vif_log/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=16

# NOTE: STEPS:
# 1. identify subject list
# 2. list the required variables
#     spm_dir, main_dir, input_dir, input, save output_dir
# 3. run plot_vif.m 
# 4. this will run the vif_calc.m
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"

MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue" #"$(realpath "${PWD}/../..")"
GLM_DIR="${MAIN_DIR}/analysis/fmri/spm/univariate/model01_6cond/1stLevel"
GLM_MODELNAME="6conditions"
FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep"
OUTPUT_DIR="${MAIN_DIR}/analysis/fmri/spm/univariate/model01_6cond/vif"
mylist=($(find ${GLM_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
IFS=$'\n' sorted=($(sort <<<"${mylist[*]}") )
PARTICIPANT_LABEL="$(basename "${sorted[$((SLURM_ARRAY_TASK_ID-1))]}")"
echo "* total of ${#mylist[@]} participants in ${INPUT_DIR}"
echo "* array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}

module load matlab/r2020a
matlab -nodesktop -nosplash -batch 'opengl("save","hardware"); rootgroup = settings;rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = "v7.3"; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = "v7.3";addpath(genpath('"'${CANLABCORE_DIR}'"'));addpath(genpath('"'${GLM_DIR}'"'));addpath('"'${MAIN_DIR}'"');addpath('"'${FMRIPREP_DIR}'"');addpath(genpath('"'${PWD}'"'));plot_vif('"'${MAIN_DIR}'"','"'${GLM_DIR}'"','"'${GLM_MODELNAME}'"', '"'${FMRIPREP_DIR}'"', '"'${OUTPUT_DIR}'"','"'${PARTICIPANT_LABEL}'"');'

echo "matlab -nodesktop -nosplash -batch 'opengl("save","hardware"); 
rootgroup = settings;rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = "v7.3"; 
rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = "v7.3";
addpath(genpath('"'${CANLABCORE_DIR}'"'));addpath(genpath('"'${GLM_DIR}'"'));
addpath(genpath('"'${MAIN_DIR}'"'));addpath(genpath('"'${FMRIPREP_DIR}'"'));
addpath(genpath('"'${PWD}'"'));
plot_vif('"'${MAIN_DIR}'"','"'${GLM_DIR}'"','"'${GLM_MODELNAME}'"', '"'${FMRIPREP_DIR}'"', '"'${OUTPUT_DIR}'"','"'${PARTICIPANT_LABEL}'"');"



