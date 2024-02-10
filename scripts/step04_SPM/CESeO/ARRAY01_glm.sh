#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=06:00:00
#SBATCH -o ./log_CESeO/GLM_%A_%a.o
#SBATCH -e ./log_CESeO/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-133%50


CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SPM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"
MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue" #"$(realpath "${PWD}/../..")"
INPUT_DIR="${MAIN_DIR}/analysis/fmri/smooth6mm"
FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep"
BADRUNJSON="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/bad_runs.json"
SAVE_DIR="/dartfs-hpc/scratch/f0042x1/spm/model02_CESeO" #/scratch/main_dir, 'analysis', 'fmri', 'spm', 'univariate', 'model01_6cond_ttl1'
mylist=($(find ${INPUT_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
IFS=$'\n' sorted=($(sort <<<"${mylist[*]}") )
PARTICIPANT_LABEL="$(basename "${sorted[$((SLURM_ARRAY_TASK_ID-1))]}")"
echo "* total of ${#mylist[@]} participants in ${INPUT_DIR}"
echo "* array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}

module load matlab/r2020a
matlab -nodesktop -nosplash -batch 'opengl("save","hardware"); rootgroup = settings;rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = "v7.3"; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = "v7.3";addpath(genpath('"'${CANLABCORE_DIR}'"'));addpath(genpath('"'${SPM_DIR}'"'));addpath(genpath('"'${MAIN_DIR}'"'));addpath(genpath('"'${INPUT_DIR}'"'));addpath(genpath('"'${PWD}'"'));s01_glm_pmodexpect('"'${PARTICIPANT_LABEL}'"','"'${INPUT_DIR}'"','"'${MAIN_DIR}'"', '"'${FMRIPREP_DIR}'"', '"'${BADRUNJSON}'"', '"'${SAVE_DIR}'"');'

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