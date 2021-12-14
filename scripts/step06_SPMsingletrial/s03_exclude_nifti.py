#!/usr/bin/env python
"""
remove contaminated nifti files
create new sub folder, move select niftifiles to sub folder
__author__ = "Heejung Jung"
__copyright__ = "Copyright 2021, The Cogent Project"
__credits__ = ["Heejung Jung"]
__license__ = "GPL"
__version__ = "1.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Production"
"""

# %% libraries ________________________________________________________________________
import os, sys, glob, shutil
import pdb
from pathlib import Path
import itertools

sub_num = int(float(sys.argv[1]))
ses = int(float(sys.argv[2]))
run = int(float(sys.argv[3]))
print(f"subject: {sub_num}, ses: {ses}, run: {run}, nifti")
# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
print(main_dir)
print(sub_num)
print(type(sub_num))
sub_str = f"sub-{sub_num:04d}"
sub_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's02_isolatenifti', sub_str)
print(sub_dir)
Path(os.path.join(sub_dir, 'exclude')).mkdir(parents=True, exist_ok=True)

key_input = {"ses": ses, "run": run}

print(f"sub-{sub_num:04d}_ses-{key_input['ses']:02d}_run-{key_input['run']:02d}*.nii")
exclude_files = glob.glob(os.path.join(sub_dir, f"sub-{sub_num:04d}_ses-{key_input['ses']:02d}_run-{key_input['run']:02d}*.nii"))
print(exclude_files)
for e_file in exclude_files:
    shutil.move(os.path.join(sub_dir, e_file), os.path.join(sub_dir, 'exclude'))
