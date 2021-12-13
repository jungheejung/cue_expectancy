#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1 
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=12:00:00
#SBATCH -o ./log_glm_cueonly/GLM_%A_%a.o
#SBATCH -e ./log_glm_cueonly/GLM_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-6,8-14

mkdir -p log_glm_cueonly
subjects=("'sub-0030'" "'sub-0031'" "'sub-0032'" "'sub-0033'" "'sub-0035'" \
"'sub-0037'" "'sub-0043'" "'sub-0047'" "'sub-0051'" "'sub-0053'" "'sub-0055'" \
"'sub-0058'" "'sub-0060'")
#subjects=( "'0002'" "'0003'" "'0004'" "'0005'" "'0006'" "'0007'" "'0008'" "'0009'" "'0010'" "'0011'" \
#"'0013'" "'0014'" "'0015'" "'0016'" "'0017'" "'0018'" "'0019'"  "'0020'" "'0021'" "'0023'" \
#"'0024'" "'0025'" "'0026'" "'0028'" "'0029'")
#subjects=(2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,20)
#PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID))]}

PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID - 1 ))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SCRIPT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM"
#SUBJECT=${SLURM_ARRAY_TASK_ID//[!0-9]/}
#echo ${SUBJECT}
# sub_list = {2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25}


module load matlab/r2020a
matlab -nodesktop -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM')); cd '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM'; s01_glm_cueonly($PARTICIPANT_LABEL);"

#echo "matlab -nodesktop -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3';rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath(${CANLABCORE_DIR})); addpath(genpath(${SCRIPT_DIR}));s01_glm_cueonly($PARTICIPANT_LABEL);"
