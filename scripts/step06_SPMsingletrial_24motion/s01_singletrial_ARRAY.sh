#!/bin/bash -l
#SBATCH --job-name=lsa
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=10:00:00
#SBATCH -o ./log/single_%A_%a.o
#SBATCH -e ./log/single_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=6

# sub-0002  sub-0009  sub-0017  sub-0025  sub-0033  sub-0040  sub-0051  sub-0059  sub-0066  sub-0075  sub-0083
# sub-0003  sub-0010  sub-0018  sub-0026  sub-0034  sub-0041  sub-0052  sub-0060  sub-0068  sub-0076  sub-0084
# sub-0004  sub-0011  sub-0019  sub-0028  sub-0035  sub-0043  sub-0053  sub-0061  sub-0069  sub-0077  sub-0085
# sub-0005  sub-0013  sub-0020  sub-0029  sub-0036  sub-0044  sub-0055  sub-0062  sub-0070  sub-0078
# sub-0006  sub-0014  sub-0021  sub-0030  sub-0037  sub-0046  sub-0056  sub-0063  sub-0071  sub-0079
# sub-0007  sub-0015  sub-0023  sub-0031  sub-0038  sub-0047  sub-0057  sub-0064  sub-0073  sub-0080
# sub-0008  sub-0016  sub-0024  sub-0032  sub-0039  sub-0050  sub-0058  sub-0065  sub-0074  sub-0081
subjects=(0 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 24 25 26 28 29 30 31 32 33 34 35 36 37 38 39 40 41 43 46 47 50 51 52 53 55 56 57 58 60 61 62 63 64 65 66 68 69 70 71 73 74 75 76 77 78 79 80 81 82 84 85 86 87 88 89 92)
PARTICIPANT_LABEL=${subjects[$((SLURM_ARRAY_TASK_ID))]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${PARTICIPANT_LABEL}
MAIN_DIR=$(dirname $(dirname "$PWD"))
CANLABCORE_DIR="'/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore'"
SPM12_DIR="'/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'"
MAIN_DIR="'/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social'"

# SUBJECT=${SLURM_ARRAY_TASK_ID//[!0-9]/}
# echo ${PARTICIPANT_LABEL}
module load matlab/r2020a
matlab -nodisplay -nosplash -batch "opengl('save','hardware'); rootgroup = settings; rootgroup.matlab.general.matfile.SaveFormat.PersonalValue = 'v7.3'; rootgroup.matlab.general.matfile.SaveFormat.TemporaryValue = 'v7.3';  addpath('/dartfs-hpc/rc/lab/C/CANlab/modules/spm12'); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore')); addpath(genpath('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step06_SPMsingletrial_24motion')); s01_singletrial_onesubject($PARTICIPANT_LABEL);"
