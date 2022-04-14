#!/usr/bin/env python3
"""
concatenate single trial nifti files and keep a running list of the included files
"""
# TODO: use nibabel to stack niftis
# subject, environment variable
# directories
# %% libraries ________________________________________________________________________
import os, sys, glob, shutil
from os.path import join
import pdb
from pathlib import Path
import itertools
import nilearn as nl
import nilearn.image as image
import nibabel

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

# parameter ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social

# sub_num = int(float(sys.argv[1]))
# sub = f"sub-{sub_num:04d}"
# ses = int(float(sys.argv[2]))
# run = int(float(sys.argv[3]))
nifti_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's02_isolatenifti')
# sub_nifti_dir = os.path.join(main_dir, 'analysis/fmri/spm/multivariate', 's02_isolatenifti')
outputnifti_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's03_concatnifti')
sub_folders = next(os.walk(nifti_dir))[1]
sub_list = [i for i in sub_folders if i.startswith('sub-')]
<<<<<<< HEAD
items_to_remove = ['sub-0001','sub-0026' ]
for item in items_to_remove:
    if item in sub_list:
        sub_list.remove(item)
sub_list = sorted(sub_list)

task_list = ['pain', 'vicarious', 'cognitive']# 'pain-early', 'pain-late', 'pain-post', 'pain-plateau']
=======
task_list = ['pain*', 'vicarious', 'cognitive'] #, 'pain-early', 'pain-late', 'pain-post', 'pain-plateau']
>>>>>>> ad37389d4cca8b3dbcc9293a862f82a398afa1e4
event_list = ['cue', 'stim']
total_list = list(itertools.product(sub_list, task_list, event_list))
for i, (sub, task, event) in enumerate(total_list):

    #TODO: glob all the nififiles while excluding those within "exclude"
    # niis = [log for log in glob.glob(os.path.join(sub_nifti_dir, '*.nii.gz')) if not os.path.isdir(log)]
    print("nilearn file concatenation")
    print(f"subject: {sub}")
    niis = glob.glob(join(nifti_dir, sub, f"{sub}_*_run-*-{task}_task-social_ev-{event}*.nii"))
    if niis:
        nifti_list = sorted(niis)
        concat_nii = nl.image.concat_imgs(nifti_list, memory_level=0, auto_resample=False, verbose=0)
        concat_fname = join(outputnifti_dir, sub, f"{sub}_task-{task}_ev-{event}.nii")
        concat_txt_fname = join(outputnifti_dir, sub, f"niftifname_{sub}_task-{task}_ev-{event}.txt")
        concat_nii.to_filename(concat_fname)
        print(concat_fname)
        # if concat_txt_fname:
        if os.path.exists(concat_txt_fname):
            os.remove(concat_txt_fname)

        with open(concat_txt_fname, "w") as f:
            for item in nifti_list:
                f.write("%s\n" % item)
                # output.write(str(nifti_list))
    else:
        print("file empty")
