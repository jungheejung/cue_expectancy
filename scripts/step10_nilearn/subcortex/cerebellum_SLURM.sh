#!/bin/bash -l
#SBATCH --job-name=subcortex
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem-per-cpu=40G
#SBATCH --time=01:00:00
#SBATCH -o ./log/sc_%A_%a.o
#SBATCH -e ./log/sc_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard

conda activate spacetop_env

MAINDIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue"
TASK="pain"
CEREBELLUM_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/other_repos/cerebellar_atlases"
REFIMG="${MAINDIR}/analysis/fmri/nilearn/singletrial/sub-0061/sub-0061_ses-04_run-06_runtype-pain_event-stimulus_trial-011_cuetype-low_stimintensity-low.nii.gz"

python ${PWD}/cerebellar_atlas.py \
--maindir ${MAINDIR} \
--task ${TASK} \
--cerebellumdir ${CEREBELLUM_DIR} \
--refimg ${REFIMG}
