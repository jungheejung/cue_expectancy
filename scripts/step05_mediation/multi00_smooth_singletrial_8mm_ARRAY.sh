#!/bin/bash -l
#SBATCH --job-name=smooth
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=05:00:00
#SBATCH -o ./log/smooth_%A_%a.o
#SBATCH -e ./log/smooth_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1,14,24


#subjects=( "'0002'" "'0003'" "'0004'" "'0005'" "'0006'" "'0007'" "'0008'" "'0009'" "'0010'" "'0011'" \
#"'0013'" "'0014'" "'0015'" "'0016'" "'0017'" "'0018'"  "'0019'" "'0020'" "'0021'" "'0023'" \
#"'0024'" "'0025'" "'0026'" "'0028'" "'0029'" "'sub-0030'" "'sub-0031'" "'sub-0032'" "'sub-0033'" "'sub-0035'" \
#"'sub-0037'" "'sub-0043'" "'sub-0047'" "'sub-0051'" "'sub-0053'" "'sub-0055'" \
#"'sub-0058'" "'sub-0060'")

subjects=(0 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 24 25 26 28 29 30 31 32 33 35 37 43 47 51 53 55 58 60)
PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
CANLABCORE_DIR="/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore"
SCRIPT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step04_SPM"
SUBJECT=${SLURM_ARRAY_TASK_ID//[!0-9]/}
echo ${PARTICIPANT_LABEL}
module load matlab/r2020a

#matlab -nodisplay -nosplash -batch "addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step04_SPM')); s00_smooth($PARTICIPANT_LABEL);"

matlab -nodisplay -nosplash -batch "addpath('/optnfs/el7/spm/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step05_mediation')); multi00_smooth_singletrial_8mm($PARTICIPANT_LABEL);"
