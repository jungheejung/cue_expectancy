#!/bin/bash -l
#SBATCH --job-name=brainmask
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=02:00:00
#SBATCH -o brainmask_%A_%a.o
#SBATCH -e brainmask_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=preemptable
#SBATCH --array=0,2-17



subjects=("sub-0002" "sub-0003" "sub-0004" "sub-0005" "sub-0006" \
"sub-0007" "sub-0008" "sub-0009" "sub-0010" "sub-0011" \
"sub-0013" "sub-0014" "sub-0015" "sub-0016" "sub-0017" "sub-0020" )
sessions=("ses-01" "ses-03" "ses-04")
runs=("run-1" "run-2" "run-3" "run-4" "run-5" "run-6")
SUB=${subjects[$((SLURM_ARRAY_TASK_ID))]}
module load fsl/6.0.4
#export "$SUB"
echo ${SUB}
./s00_brainmask.sh ${SUB}

