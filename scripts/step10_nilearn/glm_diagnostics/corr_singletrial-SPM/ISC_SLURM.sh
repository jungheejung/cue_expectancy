#!/bin/bash -l
#SBATCH --job-name=glm
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem-per-cpu=40G
#SBATCH --time=01:00:00
#SBATCH -o ./logisc/isc_%A_%a.o
#SBATCH -e ./logisc/isc_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard


conda activate rsa
python ISC.py
