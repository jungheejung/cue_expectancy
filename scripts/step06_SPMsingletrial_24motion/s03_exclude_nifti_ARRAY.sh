#!/bin/bash -l
#SBATCH --job-name=exclude
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=5gb
#SBATCH --time=01:00:00
#SBATCH -o ./log/exclude_%A_%a.o
#SBATCH -e ./log/exclude_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-90

source /optnfs/common/miniconda3/etc/profile.d/conda.sh
conda activate spacetop_env

MAINDIR=/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step06_SPMsingletrial


echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
IND=$((SLURM_ARRAY_TASK_ID+1))
INFILE=`awk -F '\r\t\n' "NR==${SLURM_ARRAY_TASK_ID}" ./s03_exclude_list.txt`
echo $INFILE
SUB=$(echo $INFILE | cut -d$' ' -f1)
SES=$(echo $INFILE | cut -d$' ' -f2)
RUN=$(echo $INFILE | cut -d$' ' -f3)

hostname -s
python ./s03_exclude_nifti.py ${SUB} ${SES} ${RUN}
