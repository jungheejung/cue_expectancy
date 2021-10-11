#!/bin/bash -l
#SBATCH --job-name=spctp_prprc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=8gb
#SBATCH --time=12:00:00
#SBATCH -o ./log/preproc_%A_%a.o
#SBATCH -e ./log/preproc_%A_%a.e
#SBATCH --account=DBIC
#SBATCH --partition=standard
#SBATCH --array=1-17%5
## --array=1-17%5

cd /dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/dartmouth

source /optnfs/common/miniconda3/etc/profile.d/conda.sh
conda activate spacetop_env

# parameters _________________________________________________________
IMAGE=/dartfs-hpc/rc/lab/C/CANlab/modules/mriqc-0.14.2.sif
MAINDIR=/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop
BIDS_DIRECTORY=${MAINDIR}/dartmouth
SCRATCH_DIR=/scratch/f0042x1/spacetop/preproc
SCRATCH_WORK=${SCRATCH_DIR}/work
OUTPUT_DIR=${MAINDIR}/dartmouth/derivatives/mriqc
OUTPUT_WORK=${OUTPUT_DIR}/work

subjects=("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" \
"11" "13" "14" "15" "16" "17" "20")
SUBJ=${subjects[$SLURM_ARRAY_TASK_ID]}
echo "array id: " ${SLURM_ARRAY_TASK_ID}, "subject id: " ${SUBJ}

# mriqc command _________________________________________________________
unset PYTHONPATH;
singularity run --cleanenv \
        -B ${BIDS_DIRECTORY}:${BIDS_DIRECTORY} \
        -B ${SCRATCH_DIR}:${SCRATCH_DIR} \
        ${IMAGE} \
        ${BIDS_DIRECTORY} \
        ${SCRATCH_DIR} \
        -w ${SCRATCH_WORK}
        participant --participant-label ${SUBJ} \
        --n_procs 16 \
        --mem_gb 8 \
        --ica \
        --start-idx 6 \
        --fft-spikes-detector \
        --write-graph \
        --correct-slice-timing \
        --fd_thres 0.9

echo "COMPLETING mriqc ... COPYING over"

cp ${SCRATCH_DIR} ${OUTPUT_DIR}
cp ${SCRATCH_WORK} ${OUTPUT_WORK}

echo "process complete"
