#!/bin/bash -l
#SBATCH --job-name=fsl
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1 
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=03:00:00
#SBATCH -o ./log/FSL_%A_%a.o
#SBATCH -e ./log/FSL_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1071-5000%60

module load fsl/6.0.4
conda activate spacetop_env

FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep"
PWD_DIR=${PWD}
MAIN_DIR=$(dirname $(dirname ${PWD_DIR}))
# EV_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_ev"
# NIFTI_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_nifti"
# SCRIPT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step03_FSL"
EV_DIR=${MAIN_DIR}/analysis/fmri/fsl/multivariate/isolate_ev
NIFTI_DIR=${MAIN_DIR}/analysis/fmri/fsl/multivariate/isolate_nifti
SCRIPT_DIR=${MAIN_DIR}/scripts/step03_FSL
ARRAY_FILE=${SCRIPT_DIR}/fsl05_jobarraylist.txt

IND=$((SLURM_ARRAY_TASK_ID-1))
INFILE=`awk -F "," -v RS="\n" "NR==${IND}" ${ARRAY_FILE}`
SUB=$(echo $INFILE | cut -f1 -d,)
SES=$(echo $INFILE | cut -f2 -d,)
RUN=$(echo $INFILE | cut -f3 -d,)
EV=$(echo $INFILE | cut -f4 -d,)
FPATH=$(echo $INFILE | cut -f5 -d,)
CHECK=$(echo $INFILE | cut -f6 -d,)
RUN_NUM=$(echo ${RUN} | sed 's/[^1-9]*//g')

# TODO: if CHECK is empty, execute model
# if [ -z "$CHECK" ]; then  
if [[ "${CHECK}" == "False" ]]; then
    # conduct FSL single trial model analysis
    BOLD=${FMRIPREP_DIR}/${SUB}/${SES}/func/${SUB}_${SES}_task-social_acq-mb8_run-${RUN_NUM}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
    NII=${FMRIPREP_DIR}/${SUB}/${SES}/func/${SUB}_${SES}_task-social_acq-mb8_run-${RUN_NUM}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii

    if test -f "${BOLD}"; then
        echo "INFO: ${SUB},${SES},${RUN},${EV}"
        echo "STEP01: brain data exists. PROCEED with model"
        # TODO: delete .nii; otherwise, FSL will error and say there are redundant basenames
        if test -f "${NII}"; then 
	    echo "STEP02: deleting .nii..."
            rm -rf ${NII}
        fi
        cd ${EV_DIR}/${SUB}/${SES}/${RUN}/${EV}
        echo "STEP03: starting FEAT"
        feat isolated_model.fsf
        echo "JOB COMPLETE: ${SUB},${SES},${RUN},${EV}"
        
        echo "STEP04: updating list - mark as complete"
            # TODO: 5. cp beta maps "pe.nii.gz" over to isolate_nifti 
        SINGLE=${EV_DIR}/${SUB}/${SES}/${RUN}/${EV}/isolate_model.feat/stats/pe1.nii.gz
        NEW_PE=${SUB}_${SES}_${RUN}_${EV}.nii.gz
        mkdir -p ${NIFTI_DIR}/${SUB}
        cp ${SINGLE} ${NIFTI_DIR}/${SUB}/${NEW_PE}
        echo "STEP05: COPY FILE TO ${NIFTI_DIR}/${SUB}/${NEW_PE}"
        # TODO: 6. remove models. 
        echo "STEP06: Deleting FEAT files"
        ls | grep -v "${EV_DIR}/${SUB}/${SES}/${RUN}/${EV}/isolate_model.feat/stats" | xargs rm -rf
        # TODO: 4. Append DONE to the textfiles once jobs complete. 
        awk -v n=${IND} -v string=',DONE' 'NR==n { $0 = $0 string} 1' ${ARRAY_FILE}  > tmp && mv tmp ${ARRAY_FILE}
    else 
        echo "NO BRAIN DATA"
        exit
    fi

    
else 
    if [ "$CHECK" == "True" ]; then
    echo "ALREADY COMPLETE"
    exit
    fi
fi


