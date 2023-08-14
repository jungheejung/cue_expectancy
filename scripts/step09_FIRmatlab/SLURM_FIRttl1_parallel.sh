#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=24G
#SBATCH --time=3-00:00:00
#SBATCH -o ./log_glm/GLM_%A_%a.o
#SBATCH -e ./log_glm/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-13

CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
ONSET_DIR="${MAIN_DIR}/data/fmri/fmri01_onset/onset02_SPM"
FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep"
BADRUNJSON="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/bad_runs.json"
SAVE_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/spm/fir/ttl1par"
SPM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/spm12"
ATLAS_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/Neuroimaging_Pattern_Masks/Atlases_and_parcellations"
mylist=($(find ${FMRIPREP_DIR} -maxdepth 1 -mindepth 1 -type d -iname "sub-*"))
IFS=$'\n' sorted=($(sort <<<"${mylist[*]}") )
PARTICIPANT_LABEL="$(basename "${sorted[$((SLURM_ARRAY_TASK_ID-1))]}")"
echo "* total of ${#mylist[@]} participants in ${INPUT_DIR}"
echo "* array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
KEYWORD="rINS"

module load matlab/r2020a
matlab -nodesktop -nosplash -batch 'opengl("save","hardware"); rootgroup = settings;rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = "v7.3"; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = "v7.3";addpath(genpath('"'${CANLABCORE_DIR}'"'));addpath(genpath('"'${SPM_DIR}'"'));addpath(genpath('"'${ATLAS_DIR}'"'));addpath(genpath('"'${MAIN_DIR}'"'));addpath(genpath('"'${ONSET_DIR}'"'));addpath(genpath('"'${PWD}'"'));FIR_spm_ttl1('"'${PARTICIPANT_LABEL}'"','"'${ONSET_DIR}'"','"'${MAIN_DIR}'"', '"'${FMRIPREP_DIR}'"', '"'${BADRUNJSON}'"',  '"'${SAVE_DIR}'"', '"'${KEYWORD}'"');'

echo "\n\nCODE:\nmatlab -nodesktop -nosplash -batch 'opengl("save","hardware"); 
rootgroup = settings; 
rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = "v7.3"; 
rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = "v7.3";
addpath(genpath('"'${CANLABCORE_DIR}'"'));
addpath(genpath('"'${SPM_DIR}'"')); 
addpath(genpath('"'${MAIN_DIR}'"')); 
addpath(genpath('"'${INPUT_DIR}'"')); 
addpath(genpath('"'${PWD}'"'))
FIR_spm_ttl1_parallel('"'${PARTICIPANT_LABEL}'"','"'${INPUT_DIR}'"','"'${MAIN_DIR}'"','"'${FMRIPREP_DIR}'"', '"'${BADRUNJSON}'"');'"


# rois.PHG = [251,252,309,310,253,254]; %[126, 155, 127];
# rois.V1 = [1,2];%[1];
# rois.SM =[15,16,17,18,101,102,103,104,105,106];%[8,9,51,52,53];
# rois.MT = [3,4,45,46]; %[2,23];
# rois.RSC =[27,28];%[14];
# % rois.LO_DEP = [] %[20,21,159,156,157];
# rois.LOC = [279,280,281,282,313,314,311,312,317,318,3,4,45,46]; %[140,141,157,156,159,2,23];
# rois.FFC= [35,37];%[18];
# rois.PIT= [43,44]; %[22];
# rois.TPJ= [277,278,279,280,281,282];%[139,140,141];
# rois.pSTS= [55,56,277,278]; %[28,139];
# rois.AIP= [233,234,231,232,295,296,293,294]; %[117, 116, 148, 147];
# rois.premotor= [155,156,159,160]; %[78,80];
# rois.rINS = [216,218,226];
# rois.dACC = [82,115,116];
