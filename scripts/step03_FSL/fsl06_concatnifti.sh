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
#SBATCH --array=14-16

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
SINGLENIFTI_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_nifti"
ARRAY_FILE=./fsl06_concatlist.txt
IND=$((SLURM_ARRAY_TASK_ID))
INFILE=`awk -F "," -v RS="\n" "NR==${IND}" ${ARRAY_FILE}`
SUB_NUM=$(echo $INFILE | cut -f1 -d,)

echo "STARTING fslmerge ___________________________________________"
# for SUB_NUM in `cat fsl06_concatlist.txt`; do echo ${SUB_NUM};
# STEP01 grab relevant indices
SUB=$(printf "sub-%04d" $SUB_NUM)
for TASK in "pain" "vicarious" "cognitive"; do
    for EVENT in "cue" "stim"; do

        cd ${SINGLENIFTI_DIR}/${SUB}
        # STEP02 find all nifti files (single trials)
        list=$(find -type f -name "${SUB}*ses*run*${TASK}*${EVENT}*.nii.gz" | sort -t '\0' -n  )
        OUTPUTNAME=${SUB}_task-${TASK}_ev-${EVENT}.nii.gz

        # STEP03 fslmerge
        fslmerge -t ${OUTPUTNAME} ${list}

        # STEP04 save file sequence
        printf "%s" "$list" > niftifname_${SUB}_task-${TASK}_ev-${EVENT}.txt 
    done
done
# done


# echo "${#list[@]}"

# echo ${list} | tr ' ' ','
# comma_list=$(${list} | tr ' ' ',')
# IFS=', ' read -r -a array <<< "$comma_list"
# read -a arr <<< $list

    # STEP01 grab relevant indices
    for EVENT in "cue" "stim"; do
        cd ${SINGLENIFTI_DIR}/${SUB}
        # STEP02 find all nifti files (single trials)
        list=$(find -type f -name "${SUB}*ses*run*${EVENT}*.nii.gz" | sort -t '\0' -n  )
        OUTPUTNAME=${SUB}_task-general_ev-${EVENT}.nii.gz

        # STEP03 fslmerge
        fslmerge -t ${OUTPUTNAME} ${list}

        # STEP04 save file sequence
        printf "%s" "$list" > niftifname_${SUB}_task-general_ev-${EVENT}.txt 
    done


echo "_______________________ PROCESS COMPLETE ${SUB}"
