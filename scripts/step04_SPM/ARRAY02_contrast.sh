#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=00:30:00
#SBATCH -o ./log_con/contrast_%A_%a.o
#SBATCH -e ./log_con/contrast_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=preemptable
#SBATCH --array=0-15%7
## --array=1-17%5


subjects=( "'0002'" "'0003'" "'0004'" "'0005'" "'0006'" "'0007'" "'0008'" "'0009'" "'0010'" \
"'0011'" "'0013'" "'0014'" "'0015'" "'0016'" "'0017'" "'0020'")
#subjects=(2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,20)
PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SCRIPT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step04_SPM"
SUBJECT=${SLURM_ARRAY_TASK_ID//[!0-9]/}
echo ${SUBJECT}
# sub_list = {2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25}
module load matlab/r2020a
matlab -nodisplay -nosplash -batch "addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step04_SPM')); firstlevel02_contrast($PARTICIPANT_LABEL);"

