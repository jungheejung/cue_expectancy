#!/bin/bash -l
#SBATCH --job-name=med
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1 
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=05:00:00
#SBATCH -o ./med_%A_%a.o
#SBATCH -e ./med_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard

#================================================================
# HEADER
#================================================================
# INPUT
#     s06_mediation_list.txt
#     : mainly contains task, rating name,
#================================================================
# DESCRIPTION: 
# 1. based on INPUT, script is copied over to corresponding folder
# 2. CANlab multilevel mediation analysis

#================================================================
# task 
# - pain
# - vicarious
# - cognitive
# - general 

# event 
# - cue-cue-expect 
# - cue-stim-actual 

CANLABCORE_DIR="'/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'"
SPM12_DIR="'/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'"

module load matlab/r2020a
#echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
#IND=$((SLURM_ARRAY_TASK_ID+1))
#INFILE=`awk -F '\r\t\n' "NR==${IND}" ./s06_mediation_list.txt`
#INFILE=`awk -F ','  "NR==${IND}" ./s06_mediation_list.txt`
#echo $INFILE
#task=$(echo $INFILE | cut -d, -f1)
#x_event=$(echo $INFILE | cut -d, -f2)
#csv=$(echo $INFILE | cut -d, -f3)
#y_rating=$(echo $INFILE | cut -d, -f4)
#echo ${task} ${x_event} ${csv} ${y_rating}

# create folder and move template script to said folder
#FOLDER=task-smooth-${task}_med-cue-${csv}
#FOLDER="smooth-6mm_task-social_run-${task}_med-cue-${csv}"
#FOLDER_FULLPATH="'/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step06_SPMsingletrial/${FOLDER}'"
#mkdir -p ${FOLDER}
#cp s06_template_mediation.m ${FOLDER}
#cd ${FOLDER}
# mediation
task=\'${task}\'
x_event=\'${x_event}\'
csv=\'${csv}\'
y_rating=\'${y_rating}\'
matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath(${SPM12_DIR}); addpath(genpath(${CANLABCORE_DIR})); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step06_SPMsingletrial'));s06_template_mediation"
