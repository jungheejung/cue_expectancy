#!/bin/bash -l

#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=01:00:00
#SBATCH -o ./log_glm/mem_%A_%a.o
#SBATCH -e ./log_glm/mem_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-5%10 

conda activate spacetop_env

ID=0
MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
SINGLETRIALDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupdown"
SAVEDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv01_signature/ttl2"
${MAINDIR}/scripts/step10_nilearn/singletrialLSS/step02_applysignature_recursive_memprofile.py \
--slurm-id ${ID} \
--input-niidir ${SINGLETRIALDIR} \
--output-savedir ${SAVEDIR}

