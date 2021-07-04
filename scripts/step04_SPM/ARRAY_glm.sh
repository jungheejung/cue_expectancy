#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=24:00:00
#SBATCH -o ./log/preproc_%A_%a.o
#SBATCH -e ./log/preproc_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=5
## --array=1-17%5


subjects=( "0002" "0003" "0004" "0005" "0006" "0007" "0008" "0009" "0010" \
"0011" "0013" "0014" "0015" "0016" "0017" "0020")
#subjects=(2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,20)
PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID - 1 ))]}

# sub_list = {2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25}
module load matlab/r2018b
matlab -nodisplay -nosplash -r "addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'));
glm_discovery_job(${PARTICIPANT_LABEL});exit"
