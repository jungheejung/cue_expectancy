#!/bin/bash -l
#SBATCH --job-name=med_gen_cue
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=1-12:00:00
#SBATCH -o ./log_gen/med_%A_%a.o
#SBATCH -e ./log_gen/med_%A_%a.e
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

matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath(${SPM12_DIR}); addpath(genpath(${CANLABCORE_DIR})); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step06_SPMsingletrial')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox')); pdm_03general_l2_cue"
