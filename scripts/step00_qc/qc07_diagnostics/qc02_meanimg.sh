#!/bin/bash
#SBATCH --job-name=qc
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1 
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=03:00:00
#SBATCH -o ./log_qc/meanimg_%A_%a.o
#SBATCH -e ./log_qc/meanimg_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard

module load python/3.7-Anaconda
source /optnfs/common/miniconda3/etc/profile.d/conda.sh 
conda activate spacetop_env
python qc02_temp_meanimg.py
