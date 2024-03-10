import os
import glob
import nibabel as nib
import gzip
import argparse
from pathlib import Path

# ----------------------------------------------------------------------
#                           paramters
# ----------------------------------------------------------------------
# parser = argparse.ArgumentParser()
# parser.add_argument("--slurm-id", type=int,
#                     help="specify slurm array id")
# args = parser.parse_args()
# slurm_id = args.slurm_id # e.g. 1, 2

func_dir = '/Volumes/seagate/cue_singletrials/singletrial_rampupplateau'
save_dir = '/Volumes/seagate/cue_singletrials/uncompressed_singletrial_rampupplateau'
sub_folders = next(os.walk(func_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
# sub = sub_list[slurm_id] #f'sub-{sub_list[slurm_id]:04d}'

for sub in sub_list:
    # data_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'
    # nii_gz_files = glob.glob(os.path.join(func_dir, 'sub-*', '**', 'func', '*task-social*space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'), recursive=True)
    Path(os.path.join(save_dir, sub)).mkdir(exist_ok=True,parents=True)
    nii_gz_files = glob.glob(os.path.join(func_dir, sub,'**', f'{sub}_ses-*_run-*_runtype-*_event-*trial-*.nii.gz'), recursive=True)

    for nii_gz_file in nii_gz_files:
        base_fname = os.path.basename(nii_gz_file[:-3])  # Remove '.gz' extension
        new_file_location = os.path.join(save_dir, sub, base_fname)
        with gzip.open(nii_gz_file, 'rb') as f_in:
            with open(new_file_location, 'wb') as f_out:
                f_out.write(f_in.read())
