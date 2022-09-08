#!/usr/bin/env python3
"""
concatenate single trial nifti files and keep a running list of the included files

# TODO: use nibabel to stack niftis
# subject, environment variable
# directories

#TODO: glob all the nififiles while excluding those within "exclude"
# niis = [log for log in glob.glob(os.path.join(sub_nifti_dir, '*.nii.gz')) if not os.path.isdir(log)]
"""

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

def _rewrite_concatfname(txt_fname, nifti_list):
    if os.path.exists(txt_fname):
        os.remove(txt_fname)

    with open(txt_fname, "w") as f:
        for item in nifti_list:
            f.write("%s\n" % item)

# parameter ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
nifti_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's02_isolatenifti')
outputnifti_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's03_concatnifti')
sub_folders = next(os.walk(nifti_dir))[1]
sub_list = [i for i in sub_folders if i.startswith('sub-')]
items_to_remove = ['sub-0001','sub-0026' ]
for item in items_to_remove:
    if item in sub_list:
        sub_list.remove(item)
sub_list = sorted(sub_list)

runtype_list = ['pain*', 'vicarious', 'cognitive'] #, 'pain-early', 'pain-late', 'pain-post', 'pain-plateau']
event_list = ['cue', 'stim']
total_list = list(itertools.product(sub_list, runtype_list, event_list))
for i, (sub, run_type, event) in enumerate(total_list):

    print("nilearn file concatenation")
    print(f"subject: {sub}")
    niis = glob.glob(join(nifti_dir, sub, f"{sub}_*_run-*-{run_type}_task-social_ev-{event}*.nii"))
    if niis:
        concat_dir = join(outputnifti_dir, sub)
        Path(join(concat_dir)).mkdir(parents=True, exist_ok=True)
        if run_type=='vicarious' or run_type=='cognitive':
            nifti_list = sorted(niis)
            concat_nii = nl.image.concat_imgs(nifti_list, memory_level=0, auto_resample=False, verbose=0)
            concat_fname = join(concat_dir, f"{sub}_task-social_run-{run_type}_ev-{event}.nii")
            concat_nii.to_filename(concat_fname)
            concat_txt_fname = join(concat_dir, f"niftifname_{sub}_task-social_run-{run_type}_ev-{event}.txt")
            _rewrite_concatfname(concat_txt_fname, nifti_list)
            print(f"runtype: {run_type}, {concat_fname}")

        if run_type=='pain*':
            nifti_list = sorted(niis)
            concat_nii = nl.image.concat_imgs(nifti_list, memory_level=0, auto_resample=False, verbose=0)
            concat_fname = join(concat_dir, f"{sub}_task-social_run-pain_ev-{event}.nii")
            concat_nii.to_filename(concat_fname)
            concat_txt_fname = join(concat_dir, f"niftifname_{sub}_task-social_run-pain_ev-{event}.txt")
            _rewrite_concatfname(concat_txt_fname, nifti_list)
            print(f"runtype: {run_type}, {concat_fname}")
    else:
        print("file empty")
