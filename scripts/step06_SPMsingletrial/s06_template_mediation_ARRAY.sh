#!/bin/bash -l
#SBATCH --job-name=med
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1 
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=01:00:00
#SBATCH -o ./log_med/med_%A_%a.o
#SBATCH -e ./log_med/med_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-8

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



echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
IND=$((SLURM_ARRAY_TASK_ID+1))
INFILE=`awk -F '\r\t\n' "NR==${SLURM_ARRAY_TASK_ID}" ./s06_mediation_list.txt`
INFILE=`awk -F ','  "NR==${IND}" ./s06_mediation_list.txt`
echo $INFILE
task=$(echo $INFILE | cut -d, -f1)
x_event=$(echo $INFILE | cut -d, -f2)
csv=$(echo $INFILE | cut -d, -f3)
y_rating=$(echo $INFILE | cut -d, -f4)

task=$(echo $INFILE | cut -d$' ' -f1)
x_event=$(echo $INFILE | cut -d$' ' -f2)
csv=$(echo $INFILE | cut -d$' ' -f3)
y_rating=$(echo $INFILE | cut -d$' ' -f4)
echo ${task} ${x_event} ${csv} ${y_rating}

# create folder and move template script to said folder
FOLDER="smooth-6mm_task-social_run-${task}_med-cue-${csv}"
echo ${FOLDER}
mkdir -p ${FOLDER}
cp s06_template_mediation.m ${FOLDER}
cd ${FOLDER}
# mediation
run ./s06_template_mediation(${task},${x_event},${csv},${y_rating})