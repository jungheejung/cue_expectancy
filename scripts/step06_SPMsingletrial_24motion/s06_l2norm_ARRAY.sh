#!/bin/bash -l
#SBATCH --job-name=exclude
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=5gb
#SBATCH --time=01:00:00
#SBATCH -o ./log_l2norm/exclude_%A_%a.o
#SBATCH -e ./log_l2norm/exclude_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=2-10

echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
IND=$((SLURM_ARRAY_TASK_ID+1))
INFILE=`awk -F '\r\t\n' "NR==${SLURM_ARRAY_TASK_ID}" ./s06_l2normtasklist.txt`
echo $INFILE
TASK=$(echo $INFILE | cut -d$' ' -f1)
EVENT=$(echo $INFILE | cut -d$' ' -f2)

module load matlab/r2020a
matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step06_SPMsingletrial')); s06_l2normniftis('"${TASK}"', '"${EVENT}"');"



