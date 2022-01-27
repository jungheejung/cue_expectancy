# TODO:
# 1. [x] load preprocessed bold nifti 
# 2. [x] create nifti masker
# 3. [x] calculate mean intensity (mean image and mean value of the mean image)
# [x] itertools and for loop over subject, session, run
# run only if nifti exists. 


# nilearn.image.mean_img
# mean of the values of the image

# TODO: CHECK: 
# does this mean value match with the canlab value
# does this mean value match with the mriqc value for the non preprocessed images?

# combinations:
# - postfmriprep: no mask 
# - postfmriprep: mask with fmriprep mask - WHY: to compare with mriqc value
# - postfmriprep: mask with canlab gray matter mask - WHY: to compare with values from plot diagnostic
# - beta: no mask 
# - beta: mask with canlab gray matter mask

# %% load libraries ________________________________________________________________________________________________
import os, glob, itertools
from pathlib import Path
import nilearn as nl
import nilearn.image as image
from nilearn.input_data import NiftiMasker
import numpy as np
import pandas as pd

# /Volumes/spacetop/derivatives/dartmouth/fmriprep/fmriprep/sub-0060/ses-01/func/sub-0060_ses-01_task-social_acq-mb8_run-3_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz 
# %% parameters ________________________________________________________________________________________________
# sub_list = [60]
# ses_list = [1,3,4]

# fmriprep_dir = '/Volumes/spacetop/derivatives/dartmouth/fmriprep/fmriprep/'
# htmlsave_dir = '/Users/h/Desktop/'
# beta_dir = '/Volumes/spacetop_projects_social/analysis/fmri/spm/multivariate/s02_isolatenifti/'

fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep'
htmlsave_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/figure/qc'
beta_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/analysis/fmri/spm/multivariate/s02_isolatenifti'
column_list = ['ses-01_run-01','ses-01_run-02','ses-01_run-03','ses-01_run-04','ses-01_run-05','ses-01_run-06',
        'ses-03_run-01','ses-03_run-02','ses-03_run-03','ses-03_run-04','ses-03_run-05','ses-03_run-06',
        'ses-04_run-01','ses-04_run-02','ses-04_run-03','ses-04_run-04','ses-04_run-05','ses-04_run-06']
# %% load image and mask
processed = glob.glob(os.path.join(fmriprep_dir, '*.html'))
sub_list = sorted([os.path.basename(os.path.splitext(x)[0]) for x in processed ])
ses_list = ['ses-01', 'ses-03', 'ses-04']
run_list = [1,2,3,4,5,6]
total_list = list(itertools.product(sub_list, ses_list, run_list))

fmriprep_nomask = pd.DataFrame(index = list(sub_list), columns = column_list)
fmriprep_fmriprepmask = pd.DataFrame(index = list(sub_list), columns = column_list)
fmriprep_canlab = pd.DataFrame(index = list(sub_list), columns = column_list)
beta_nomask     = pd.DataFrame(index = list(sub_list), columns = column_list)
beta_canlab     = pd.DataFrame(index = list(sub_list), columns = column_list)
# %%
for i, (sub, ses, run) in enumerate(total_list):
# sub-0060_ses-01_task-social_acq-mb8_run-6_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
    image_filename = f"{sub}_{ses}_task-social_acq-mb8_run-{run}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"
    image_fullname = os.path.join(fmriprep_dir, sub, ses, 'func', image_filename)
    mask_filename = f"{sub}_{ses}_task-social_acq-mb8_run-{run}_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz"
    fmriprep_mask = os.path.join(fmriprep_dir, sub, ses, 'func',  mask_filename)
    canlab_mask = '/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/gray_matter_mask.nii'
    image_path = Path(image_fullname)

    if image_path.is_file():
        masker = NiftiMasker(mask_img = fmriprep_mask)
        masker.fit(image_fullname)
        report = masker.generate_report()
        report.save_as_html(os.path.join(htmlsave_dir, f'{sub}_{ses}_run-{run:02d}_masker.html'))

        trended_data = masker.fit_transform(image_fullname)
        print(trended_data.shape) # (872, 114013) 
        np.mean(trended_data) #2953.5489229758823
        fmriprep_nomask.loc[sub, f"{ses}_run-{run:02d}"] = np.mean(trended_data)

        # %% 3. calculate average beta image for pain for each run ________________________________________________________________________________________________
        # (same for vicarious pain, fatigue). just a simple average across beta images. 
        # load all betas
        # calculate mean image
        # if masker used: -0.068046235
        # if masker not used: -0.021295747148034283
        # method A:

        beta_list = glob.glob(os.path.join(beta_dir,sub, f'{sub}_{ses}_run-{run:02d}-pain_ev-stim*.nii' )) 
        if beta_list:
            # develop: check what one beta image looks like _______________________________________________________________
            # nl.plotting.plot_img(beta_list[0])
            # calculate mean image and save
            A = nl.image.mean_img(beta_list) 
            A.to_filename(os.path.join(htmlsave_dir, f'{sub}_{ses}_run-{run:02d}-pain_ev-stim_mean.nii.gz'))
            print(A.get_fdata().shape) # (73, 86, 73)
            print(np.mean(A.get_fdata())) # -0.021295747148034283
            beta_nomask.loc[sub, f"{ses}_run-{run:02d}"] = np.mean(A.get_fdata()) #-0.021295747148034283
            # calculate values only within gray matter mask ______________________________________________________
            masker = NiftiMasker(mask_img = nl.image.binarize_img(nl.image.load_img(canlab_mask)), 
                                target_shape = A.shape, target_affine = A.affine)
            masker.fit(A)
            report = masker.generate_report()
            report
            report.save_as_html(os.path.join(htmlsave_dir, f'{sub}_{ses}_run-{run:02d}-pain_ev-stim_mean_masker.html'))
            A_data = masker.fit_transform(A)
            beta_canlab.loc[sub, f"{ses}_run-{run:02d}"] = np.mean(A_data)
            # plot gray matter mask and data alignment
            nl.plotting.plot_roi(masker.mask_img_, A)
            # B = nilearn.image.new_img_like(ref_niimg = beta_list[0],
            #                            data = A_data)

            # nilearn.plotting.plot_img(A)
            # runwise = []

        # method B: can ignore - confirmed that above method A and B produce identical results
            # for beta_image in beta_list:
            #     masker.fit(beta_image)
            #     report = masker.generate_report()
            #     report.save_as_html(os.path.join(htmlsave_dir, f'{sub}_{ses}_run-{run}_beta-isolatenifti_masker.html'))
            #     beta_data = masker.fit_transform(beta_image)
            #     append each beta image, save to numpy array, calculate mean beta image and save as nii.gz
            #     beta_data = nilearn.image.get_data(beta_image)
            #     runwise.append(beta_data)
            # avg_beta = np.mean(runwise, axis = 0) #shape: (73, 86, 73)
            # # np.mean(avg_beta) # -0.021295747135100313
            
            # B = nilearn.image.new_img_like(ref_niimg = beta_list[0], data = avg_beta)
            # B.to_filename(os.path.join(htmlsave_dir, ''))
            # beta_df.loc['sub-0060', f"{ses}_run-{run:02d}"] = np.mean(runwise)

