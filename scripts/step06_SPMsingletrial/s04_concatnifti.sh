#!/bin/bash -l
#SBATCH --job-name=fsl
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1 
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=01:00:00
#SBATCH -o ./log_concat/FSL_%A_%a.o
#SBATCH -e ./log_concat/FSL_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-10

#================================================================
# HEADER
#================================================================
# INPUT
#     fsl06_concatlist.txt
#     : mainly contains participant number
#================================================================
# DESCRIPTION: 
# 1. based on INPUT, script concatenates all nifti files per participant 
#    via fslmerge
#    e.g. SUB=20, TASK="pain", EVENT="cue"
#         sub-0020_ses-03_run-05-pain_ev-stim-0011.nii.gz 
#         sub-0020_ses-03_run-05-pain_ev-stim-0010.nii.gz 
#         >> OUTPUT: sub-0020_task-pain_ev-stim.nii.gz
# 2. save the trial filenames into metadata (.txt)
# 3. TODO: From this metadata, create a .csv file with behavioral ratings
# feed it into matlab multilevel analysis (step05_mediation)
#================================================================
# OUTPUT
#     subject wise concatenated nifti files. (per task, per event type)
#     : sub-0020_task-pain_ev-stim.nii.gz
#================================================================
#- IMPLEMENTATION
#-    version         fsl06_concatnifti.sh
#-    author          Heejung Jung
#-    copyright       NA
#-    license         GNU General Public License
#-    script_id       NA
#================================================================
# END_OF_HEADER
#================================================================


module load fsl/6.0.4
MAIN_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/spm/multivariate"
PAIN_DIR="singletrial_SPM_01-pain-early" # "singletrial_SPM_02-pain-late" "singletrial_SPM_03-pain-post" "singletrial_SPM_04-pain-plateau"
SINGLENIFTI_DIR="${MAIN_DIR}/s02_isolatenifti"
#ARRAY_FILE=./fsl06_concatlist.txt
# IND=$((SLURM_ARRAY_TASK_ID))
# INFILE=`awk -F "," -v RS="\n" "NR==${IND}" ${ARRAY_FILE}`
# SUB_NUM=$(echo $INFILE | cut -f1 -d,)

subjects=(0 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17 18 19 20 21 23 24 25 26 28 29 30 31 32 33 35 37 43 47 51 53 55 58 60)
SUB_NUM=${subjects[$((SLURM_ARRAY_TASK_ID))]}
OUTPUTNIFTI_DIR="${MAIN_DIR}/s03_concatnifti/${PAIN_DIR}"

echo "STARTING fslmerge ___________________________________________"
# for SUB_NUM in `cat fsl06_concatlist.txt`; do echo ${SUB_NUM};
# STEP01 grab relevant indices

SUB=$(printf "sub-%04d" $SUB_NUM)
for TASK in "pain" "vicarious" "cognitive" "pain-early" "pain-late" "pain-post" "pain-plateau"; do
    for EVENT in "cue" "stim"; do
        echo ${TASK}
        echo ${EVENT}

        cd ${SINGLENIFTI_DIR}/${SUB}
        # STEP02 find all nifti files (single trials)
        list=$(find -type f -not -path "*exclude/*"  -name "${SUB}*ses*run*${TASK}_*${EVENT}*.nii" | sort -t '\0' -n  )
        mkdir -p ${OUTPUTNIFTI_DIR}/${SUB}
        OUTPUTNAME=${OUTPUTNIFTI_DIR}/${SUB}/${SUB}_task-${TASK}_ev-${EVENT}.nii

        # STEP03 fslmerge
        fslmerge -t ${OUTPUTNAME} ${list}

        # STEP04 save file sequence
        printf "%s" "$list" > ${OUTPUTNIFTI_DIR}/${SUB}/niftifname_${SUB}_task-${TASK}_ev-${EVENT}.txt 
    done
done
# done


# echo "${#list[@]}"

# echo ${list} | tr ' ' ','
# comma_list=$(${list} | tr ' ' ',')
# IFS=', ' read -r -a array <<< "$comma_list"
# read -a arr <<< $list
    echo "merge general files ___________________________________________"
    # STEP01 grab relevant indices
    for EVENT in "cue" "stim"; do
        cd ${SINGLENIFTI_DIR}/${SUB}
        # STEP02 find all nifti files (single trials)
        list=$(find -type f -not -path "*exclude/*" -name "${SUB}*ses*run*${EVENT}*.nii" | sort -t '\0' -n  )
        mkdir -p ${OUTPUTNIFTI_DIR}/${SUB}
        OUTPUTNAME=${OUTPUTNIFTI_DIR}/${SUB}/${SUB}_task-general_ev-${EVENT}.nii
        
        # STEP03 fslmerge
        fslmerge -t ${OUTPUTNAME} ${list}

        # STEP04 save file sequence
        printf "%s" "$list" > ${OUTPUTNIFTI_DIR}/${SUB}/niftifname_${SUB}_task-general_ev-${EVENT}.txt 
    done


echo "_______________________ PROCESS COMPLETE ${SUB}"
