
# TODO: 
# 1. concatenate all tasks per participant. 
# e.g. sub-0020_ses-03_run-05-pain_ev-stim-0011.nii.gz 
#      sub-0020_ses-03_run-05-pain_ev-stim-0010.nii.gz 
#      >> OUTPUT: sub-0020_run-pain.nii.gz
# 2. save the trial filenames into metadata.
# 3. From this metadata, create a .csv file with behavioral ratings
# feed it into matlab multilevel analysis (step05_mediation)


module load fsl/6.0.4
# STEP01 grab relevant indices
SUB_NUM=20
SUB=$(printf "sub-%04d" $SUB_NUM)
TASK="pain"
EVENT="stim"

# STEP02 find all nifti files (single trials)
list=$(find  -type f -name "${SUB}*ses*run*${TASK}*${EVENT}*.nii.gz" | sort -t '\0' -n  )
OUTPUTNAME=${SUB}_task-${TASK}_ev-${EVENT}.nii.gz

# STEP03 fslmerge
fslmerge -t ${OUTPUTNAME} ${list}

echo "${#list[@]}"

echo ${list} | tr ' ' ','
comma_list=$(${list} | tr ' ' ',')
IFS=', ' read -r -a array <<< "$comma_list"
read -a arr <<< $list
