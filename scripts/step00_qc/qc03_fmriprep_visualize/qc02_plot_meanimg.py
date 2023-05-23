#!/usr/bin/env python3
# %%
# load library
import sys; sys.path = [''] + sys.path
import os, glob
from nilearn import plotting
from nilearn import datasets
from nilearn import image
import matplotlib.pyplot as plt
from pathlib import Path 
import itertools

# help -----
# https://stackoverflow.com/questions/64331987/removing-hiding-empty-subplots-in-matplotlib-when-plotting-a-flexible-grid
# https://neuros    tars.org/t/multi-subjects-figures-with-nilearn-plotting/6042
# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
# fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep'
# load image filename
# calculate mean image

fmriprep_dir = '/Volumes/spacetop_data/derivatives/fmriprep/results/fmriprep/'
fmriprep_dir = '/Users/h/Desktop'
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep/'
fmriprep_dir = '/Volumes/spacetop_data/derivatives/fmriprep/results/fmriprep/'
plot_dir = ''
sub_list = ['sub-0070', 'sub-0071']
# TODO: glob the data, not assume that every participant has 6 runs
sub = 'sub-0071'
flist = glob.glob(os.path.join(fmriprep_dir, sub, "*", "func", f"{sub}_*_task-social_acq-mb8_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"))
# {sub}_*_task-social_acq-mb8_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
filename = '/Users/h/Desktop/sub-0071/ses-01/func/sub-0071_ses-01_task-social_acq-mb8_run-6_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'
for i, filename in enumerate(flist): 
# %%
# ses_list = [1,3,4]
# run_list = [1,2,3,4,5,6]
# total_list = list(itertools.product(sub_list, ses_list, run_list))
# # cuts = np.arange(i,j,k)
# create a figure with multiple axes to plot each anatomical image
# %%
    fig, axes = plt.subplots(nrows=9, ncols=6, figsize=(14, 20))

# axes is a 2 dimensional numpy array
# for i, (sub, ses, run) in enumerate(total_list):
    # print( sub, ses, run)
# for ax in axes.flatten():
    # axes.flat[i]
    # filename = f"{sub}_ses-{ses:02d}_task-social_acq-mb8_run-{run}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"
    # fullpath = Path(os.path.join(fmriprep_dir, sub, f"ses-{ses:02d}", "func", filename))
    
    # if fullpath.is_file():
    brain = image.load_img(filename)
    meanimg = image.mean_img(brain)
    display = plotting.plot_anat(meanimg, axes=axes.flat[i])

# save the output figure with all the anatomical images
fig.savefig("task-social_desc-mean-img-per-run.png")

# %%
