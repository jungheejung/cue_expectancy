#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=00:20:00
#SBATCH -o ./log_con/contrast_%A_%a.o
#SBATCH -e ./log_con/contrast_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=3-40
## --array=1-17%5

#subjects=( "'0002'" "'0003'" "'0004'" "'0005'" "'0006'" "'0007'" "'0008'" "'0009'" "'0010'" "'0011'" \
#"'0013'" "'0014'" "'0015'" "'0016'" "'0017'" "'0018'" "'0019'"  "'0020'" "'0021'" "'0023'" \
#"'0024'" "'0025'" "'0026'" "'0028'" "'0029'")

subjects=( "'sub-0002'" "'sub-0003'" "'sub-0004'" "'sub-0005'" "'sub-0006'" "'sub-0007'" "'sub-0008'" "'sub-0009'" "'sub-0010'" \
"'sub-0011'" "'sub-0013'" "'sub-0014'" "'sub-0015'" "'sub-0016'" "'sub-0017'" "'sub-0018'" "'sub-0019'"  "'sub-0020'" \
"'sub-0021'" "'sub-0023'" "'sub-0024'" "'sub-0025'" "'sub-0026'" "'sub-0028'" "'sub-0029'" \
"'sub-0030'" "'sub-0031'" "'sub-0032'" "'sub-0033'" "'sub-0035'" \
"'sub-0037'" "'sub-0043'" "'sub-0047'" "'sub-0051'" "'sub-0053'" "'sub-0055'" \
"'sub-0058'" "'sub-0060'")

#subjects=(2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,20)
PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID -1))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
CANLABCORE_DIR="'/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'"
SCRIPT_DIR="'/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM/model02_CcEScA_canlabsettings'"
SUBJECT=${SLURM_ARRAY_TASK_ID//[!0-9]/}
echo ${SUBJECT}
# sub_list = {2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25}
module load matlab/r2020a
matlab -nodisplay -nosplash -batch "addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM/model02_CcEScA_canlabsettings')); s02_contrast_cueonly($PARTICIPANT_LABEL);"

