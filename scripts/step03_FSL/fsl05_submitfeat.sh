#!/bin/bash -l
#SBATCH --job-name=fsl
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1 
#SBATCH --mem-per-cpu=8gb
#SBATCH --time=03:00:00
#SBATCH -o ./log_fsl/FSL_%A_%a.o
#SBATCH -e ./log_fsl/FSL_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=601-700%20

module load fsl/6.0.4
conda activate spacetop_env

FMRIPREP_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep"
EV_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_ev"
SCRIPT_DIR="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step03_FSL"
ARRAY_FILE=${SCRIPT_DIR}/fsl05_jobarraylist.txt

IND=$((SLURM_ARRAY_TASK_ID-1))
INFILE=`awk -F "," -v RS="\n" "NR==${IND}" ${ARRAY_FILE}`
SUB=$(echo $INFILE | cut -f1 -d,)
SES=$(echo $INFILE | cut -f2 -d,)
RUN=$(echo $INFILE | cut -f3 -d,)
EV=$(echo $INFILE | cut -f4 -d,)
CHECK=$(echo $INFILE | cut -f5 -d,)
RUN_NUM=$(echo ${RUN} | sed 's/[^1-9]*//g')

# TODO: if CHECK is empty, execute model
if [ -z "$CHECK" ];
    then  
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
    fi
    echo "JOB COMPLETE: ${SUB},${SES},${RUN},${EV}"
    # TODO: 4. Append DONE to the textfiles once jobs complete. 
    awk -v n=${IND} -v string=',DONE' 'NR==n { $0 = $0 string} 1' ${ARRAY_FILE}  > tmp && mv tmp ${ARRAY_FILE}
    echo "STEP04: updating list - mark as complete"
    
else 
    if [ "$CHECK" = "DONE" ]; then
    echo "ALREADY COMPLETE"
    exit
    fi
fi

