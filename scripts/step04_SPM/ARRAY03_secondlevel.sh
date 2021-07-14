#!/bin/bash -l
#SBATCH --job-name=2ndlvl
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=06:30:00
#SBATCH -o ./log_2nd/2ndlevel_%A_%a.o
#SBATCH -e ./log_2nd/2ndlevel_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=preemptable
#SBATCH --array=3
## --array=1-17%5


module load matlab/r2020a
matlab -nodisplay -nosplash -batch "opengl('save','hardware'); addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step04_SPM'));run('./s03_secondlevel.m');"

