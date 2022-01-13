# %% load libraries ________________________________________________________________________________________________
import os, glob, itertools
from pathlib import Path
import nilearn as nl
import nilearn.image as image
from nilearn.input_data import NiftiMasker
import numpy as np
import pandas as pd

# fmriprep_dir = '/Volumes/spacetop/derivatives/dartmouth/fmriprep/fmriprep/'
# htmlsave_dir = '/Users/h/Desktop/'
# beta_dir = '/Volumes/spacetop_projects_social/analysis/fmri/spm/multivariate/s02_isolatenifti/'
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep'
htmlsave_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/figure/qc'
beta_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/spm/multivariate/s02_isolatenifti'
canlab_mask = '/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii'

column_list = ['ses-01_run-01','ses-01_run-02','ses-01_run-03','ses-01_run-04','ses-01_run-05','ses-01_run-06',
        'ses-03_run-01','ses-03_run-02','ses-03_run-03','ses-03_run-04','ses-03_run-05','ses-03_run-06',
        'ses-04_run-01','ses-04_run-02','ses-04_run-03','ses-04_run-04','ses-04_run-05','ses-04_run-06']
# %% load image and mask
processed = glob.glob(os.path.join(fmriprep_dir, '*.html'))
sub_list = sorted([os.path.basename(os.path.splitext(x)[0]) for x in processed ])
ses_list = ['ses-01', 'ses-03', 'ses-04']
run_list = [1,2,3,4,5,6]
task = 'pain'
task_list = ['vicarious', 'cognitive']
total_list = list(itertools.product(task_list, sub_list, ses_list, run_list))

for i, (task, sub, ses, run) in enumerate(total_list):
    # create or load existing pandas ________________________________________________________________
    # TODO: create a function for this
    csv_fmriprep_fmriprepmask = os.path.join(htmlsave_dir,f'task-{task}_nifti-fmriprep_mask-fmriprep.csv')
    if not csv_fmriprep_fmriprepmask:
        fmriprep_fmriprepmask = pd.DataFrame(index = list(sub_list), columns = column_list)
    else:
        fmriprep_fmriprepmask = pd.read_csv(csv_fmriprep_fmriprepmask)

    csv_fmriprep_nomask = os.path.join(htmlsave_dir,f'task-{task}_nifti-fmriprep_mask-fmriprep.csv')
    if not csv_fmriprep_nomask:
        fmriprep_nomask = pd.DataFrame(index = list(sub_list), columns = column_list)
    else:
        fmriprep_nomask = pd.read_csv(csv_fmriprep_nomask)

    csv_beta_nomask = os.path.join(htmlsave_dir,f'task-{task}_nifti-beta_mask-nomask.csv')
    if not csv_beta_nomask:
        beta_nomask = pd.DataFrame(index = list(sub_list), columns = column_list)
    else:
        beta_nomask = pd.read_csv(csv_beta_nomask)

    csv_beta_canlab = os.path.join(htmlsave_dir,f'task-{task}_nifti-beta_mask-canlab.csv')
    if not csv_beta_canlab:
        beta_canlab = pd.DataFrame(index = list(sub_list), columns = column_list)
    else:
        beta_canlab = pd.read_csv(csv_beta_canlab)

    # fmriprep_nomask = pd.DataFrame(index = list(sub_list), columns = column_list)
    # fmriprep_fmriprepmask = pd.DataFrame(index = list(sub_list), columns = column_list)
    # fmriprep_canlab = pd.DataFrame(index = list(sub_list), columns = column_list)
    # beta_nomask     = pd.DataFrame(index = list(sub_list), columns = column_list)
    # beta_canlab     = pd.DataFrame(index = list(sub_list), columns = column_list)
    image_filename = f"{sub}_{ses}_task-social_acq-mb8_run-{run}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"
    image_fullname = os.path.join(fmriprep_dir, sub, ses, 'func', image_filename)
    mask_filename = f"{sub}_{ses}_task-social_acq-mb8_run-{run}_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz"
    fmriprep_mask = os.path.join(fmriprep_dir, sub, ses, 'func',  mask_filename)
    image_path = Path(image_fullname)
    mean_filename = os.path.join(htmlsave_dir, f'{sub}_{ses}_run-{run:02d}-{task}_ev-stim_mean.nii.gz')
    if image_path.is_file():
        beta_list = glob.glob(os.path.join(beta_dir,sub, f'{sub}_{ses}_run-{run:02d}-{task}_ev-stim*.nii' )) 
        if not mean_filename and beta_list:
            A = nl.image.mean_img(beta_list) 
            A.to_filename(os.path.join(htmlsave_dir, f'{sub}_{ses}_run-{run:02d}-{task}_ev-stim_mean.nii.gz'))
            print(A.get_fdata().shape) # (73, 86, 73)
            print(np.mean(A.get_fdata())) # -0.021295747148034283
            beta_nomask.loc[sub, f"{ses}_run-{run:02d}"] = np.mean(A.get_fdata()) #-0.021295747148034283
            # calculate values only within gray matter mask ______________________________________________________
            masker = NiftiMasker(mask_img = nl.image.binarize_img(nl.image.load_img(canlab_mask)), 
                                target_shape = A.shape, target_affine = A.affine)
            masker.fit(A)
            report = masker.generate_report()
            report.save_as_html(os.path.join(htmlsave_dir, f'{sub}_{ses}_run-{run:02d}-{task}_ev-stim_mean_masker.html'))
            A_data = masker.fit_transform(A)
            beta_canlab.loc[sub, f"{ses}_run-{run:02d}"] = np.mean(A_data)
            # plot gray matter mask and data alignment
            nl.plotting.plot_roi(masker.mask_img_, A)

fmriprep_fmriprepmask.to_csv(csv_fmriprep_fmriprepmask)
beta_nomask.to_csv(csv_beta_nomask)
beta_canlab.to_csv(beta_canlab)
# %%
# FIX:
# /dartfs-hpc/rc/home/1/f0042x1/.conda/envs/spacetop_env/lib/python3.7/site-packages/nilearn/plotting/displays.py:667: 
# RuntimeWarning: More than 20 figures have been opened. 
# Figures created through the pyplot interface (`matplotlib.pyplot.figure`) are retained until explicitly closed and may consume too much memory. 
# (To control this warning, see the rcParam `figure.max_open_warning`).
#   facecolor=facecolor)