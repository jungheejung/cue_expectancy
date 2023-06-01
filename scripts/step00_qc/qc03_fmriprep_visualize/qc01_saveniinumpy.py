"""
Thepurpose of this code is to save the fmriprepp'd nifti images to a numpy array
Concatenating each nilearn object is too large. 
I need to find a way to save virtual memory
"""
import os, glob
import numpy as np
from nilearn import image
import argparse
from pathlib import Path
# %% -------------------------------------------------------------------
#                               parameters 
# ----------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", 
                    type=int, help="slurm id in numbers")
parser.add_argument("--fmriprepdir", 
                    type=str, help="the top directory of fmriprep preprocessed files")
parser.add_argument("--outputdir", 
                    type=str, help="the directory where you want to save your files")
args = parser.parse_args()
slurm_id = args.slurm_id
fmriprep_dir = args.fmriprepdir
output_dir = args.outputdir
sub_folders = next(os.walk(fmriprep_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
print(sub_list)
sub = sub_list[slurm_id]
save_dir = os.path.join(output_dir, sub)
Path(save_dir).mkdir(parents=True, exist_ok=True)
task = 'task-social'
flist = glob.glob(os.path.join(fmriprep_dir, sub, "**", "func",  f"{sub}_*{task}*.nii.gz"), recursive = True)
for fpath in flist:
    nii = image.load_img(fpath)
    np.save(os.path.join(save_dir, os.path.splitext(os.path.splitext(os.path.basename(fpath))[0])[0] + '.npy'), nii.get_fdata())
    nii.uncache()
    del nii
