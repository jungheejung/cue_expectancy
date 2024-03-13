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
#SBATCH --array=3-39

mkdir -p log_glm_cueonly
subjects=( "'sub-0002'" "'sub-0003'" "'sub-0004'" "'sub-0005'" "'sub-0006'" "'sub-0007'" "'sub-0008'" "'sub-0009'" "'sub-0010'" \
"'sub-0011'" "'sub-0013'" "'sub-0014'" "'sub-0015'" "'sub-0016'" "'sub-0017'" "'sub-0018'" "'sub-0019'"  "'sub-0020'" \
"'sub-0021'" "'sub-0023'" "'sub-0024'" "'sub-0025'" "'sub-0026'" "'sub-0028'" "'sub-0029'" \
"'sub-0030'" "'sub-0031'" "'sub-0032'" "'sub-0033'" "'sub-0035'" \
"'sub-0037'" "'sub-0043'" "'sub-0047'" "'sub-0051'" "'sub-0053'" "'sub-0055'" \
"'sub-0058'" "'sub-0060'")


PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID - 1 ))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SCRIPT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM"
#SUBJECT=${SLURM_ARRAY_TASK_ID//[!0-9]/}
#echo ${SUBJECT}


module load matlab/r2020a
matlab -nodesktop -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM')); cd '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step04_SPM/model02_CcEScA_canlabsettings'; s01_glm_cueonly($PARTICIPANT_LABEL);"

#echo "matlab -nodesktop -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3';rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath(${CANLABCORE_DIR})); addpath(genpath(${SCRIPT_DIR}));s01_glm_cueonly($PARTICIPANT_LABEL);"
