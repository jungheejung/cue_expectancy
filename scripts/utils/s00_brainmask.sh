#!/bin/bash -l


# #cd ${FMRIPREP_DIR}
# FUNC=$(find . -type f -name "*/*/func/smooth_*_bold*")
FMRIPREP_DIR=/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep
#subjectsi=("sub-0002" "sub-0003" "sub-0004" "sub-0005" "sub-0006" \
#"sub-0007" "sub-0008" "sub-0009" "sub-0010" "sub-0011" \
#"sub-0013" "sub-0014" "sub-0015" "sub-0016" "sub-0017" "sub-0020" )

sessions=("ses-01" "ses-03" "ses-04")

runs=("run-1" "run-2" "run-3" "run-4" "run-5" "run-6")
#SUB=${subjects[$((SLURM_ARRAY_TASK_ID))]}

SUB=${1}
echo ${SUB}

for SES in ${sessions[*]}; do
for RUN in ${runs[*]}; do
echo ${SES} ${RUN}
# smooth_5mm_sub-0003_ses-01_task-social_acq-mb8_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii
INPUT_FUNC=${FMRIPREP_DIR}/${SUB}/${SES}/func/smooth_5mm_${SUB}_${SES}_task-social_acq-mb8_${RUN}_space-MNI152NLin2009cAsym_desc-preproc_bold
NEWFILENAME=${INPUT_FUNC}_masked
BRAINMASK=${FMRIPREP_DIR}/${SUB}/${SES}/func/${SUB}_${SES}_task-social_acq-mb8_${RUN}_space-MNI152NLin2009cAsym_desc-brain_mask.nii

echo $INPUT_FUNC
{
if [ ! -f "${INPUT_FUNC}.nii" ]; then
    echo "File not found!"
    exit 0
else 
    echo ${INPUT_FUNC}
    fslmaths ${INPUT_FUNC}.nii -mul ${BRAINMASK} ${NEWFILENAME}.nii
fi
}
done
done

