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



module load matlab/r2020a
matlab -nodesktop -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3'; addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12')); rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step06_SPMsingletrial/task-smooth-pain_med-cue-stim-actual')); s06_template_mediation"
