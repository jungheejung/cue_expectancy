#!/bin/bash -l

#SBATCH --job-name=exclude
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=5gb
#SBATCH --time=01:00:00
#SBATCH -o ./log_fsl07/%A_%a.o
#SBATCH -e ./log_fsl07/%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-40%5

source /optnfs/common/miniconda3/etc/profile.d/conda.sh
conda activate spacetop_env

MAINDIR=/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step03_FSL

echo "SLURMSARRAY: " ${SLURM_ARRAY_TASK_ID}
IND=$((SLURM_ARRAY_TASK_ID+1))
INFILE=`awk -F '\t' "NR==${SLURM_ARRAY_TASK_ID}" ./fsl07_B_unwanted_list.txt`
echo $INFILE
SUB=$(echo $INFILE | cut -d$' ' -f1)
SES=$(echo $INFILE | cut -d$' ' -f2)
RUN=$(echo $INFILE | cut -d$' ' -f3)

hostname -s
python ./fsl07_B_mv_unwanted_nifti.py ${SUB} ${SES} ${RUN}
