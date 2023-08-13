import os
import glob
import nibabel as nib
import gzip
import argparse

# ----------------------------------------------------------------------
#                           paramters
# ----------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int,
                    help="specify slurm array id")
args = parser.parse_args()
slurm_id = args.slurm_id # e.g. 1, 2

fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'

sub_folders = next(os.walk(fmriprep_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
sub = sub_list[slurm_id] #f'sub-{sub_list[slurm_id]:04d}'

# data_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'
nii_gz_files = glob.glob(os.path.join(fmriprep_dir, 'sub-*', '**', 'func', '*task-social*space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'), recursive=True)

for nii_gz_file in nii_gz_files:
    nii_file = nii_gz_file[:-3]  # Remove '.gz' extension
    with gzip.open(nii_gz_file, 'rb') as f_in:
        with open(nii_file, 'wb') as f_out:
            f_out.write(f_in.read())
