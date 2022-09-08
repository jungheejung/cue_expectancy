#!/bin/bash -l
#SBATCH --job-name=mediation
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=12:00:00
#SBATCH -o ./log/M_%A_%a.o
#SBATCH -e ./log/M_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard

# echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SCRIPT_DIR=${PWD}

module load matlab/r2020a
matlab -nodesktop -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3'; addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12')); rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step06_SPMsingletrial/task-smooth-gen_med-cue-cue-expect')); s06_mediation"

echo "matlab -nodesktop -nosplash -batch 'opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/MediationToolbox'));addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'));addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'));rmpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12/external/fieldtrip/external/stats');addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step06_SPMsingletrial')); s06_mediation'"

