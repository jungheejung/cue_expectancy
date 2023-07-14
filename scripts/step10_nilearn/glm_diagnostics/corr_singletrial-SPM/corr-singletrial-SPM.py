#!/usr/bin/env python3
"""
Validating correlation between singletrials from nilearn and SPM contrast maps

1. correlation within subject
-  1-1. calculate average single trial map
-  1-2. correlation with SPM group map
 2. intersubject correlation
-  2-1. stack single trials (high)
-  2-2. stack single trials (low)
"""

# %%----------------------------------------------------------------------
#                                   libraries
# ----------------------------------------------------------------------

import os, glob, re, gzip, shutil, json
from os.path import join
import pathlib
import numpy as np
import statsmodels 
from statsmodels.stats import multitest
import scipy
import nilearn
from scipy import stats
from nilearn import image, plotting
import argparse
from nilearn.image import new_img_like, resample_to_img, math_img
import matplotlib.pyplot as plt
from scipy.spatial.distance import squareform
__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
main_dir = '/Volumes/spacetop_projects_cue'

# %% function
def compute_summary_statistic(iscs, summary_statistic='mean', axis=None):

    """Computes summary statistics for ISCs

    Computes either the 'mean' or 'median' across a set of ISCs. In the
    case of the mean, ISC values are first Fisher Z transformed (arctanh),
    averaged, then inverse Fisher Z transformed (tanh).

    The implementation is based on the work in [SilverDunlap1987]_.

    .. [SilverDunlap1987] "Averaging corrlelation coefficients: should
       Fisher's z transformation be used?", N. C. Silver, W. P. Dunlap, 1987,
       Journal of Applied Psychology, 72, 146-148.
       https://doi.org/10.1037/0021-9010.72.1.146

    Parameters
    ----------
    iscs : list or ndarray
        ISC values

    summary_statistic : str, default: 'mean'
        Summary statistic, 'mean' or 'median'

    axis : None or int or tuple of ints, optional
        Axis or axes along which the means are computed. The default is to
        compute the mean of the flattened array.

    Returns
    -------
    statistic : float or ndarray
        Summary statistic of ISC values

    """

    if summary_statistic not in ('mean', 'median'):
        raise ValueError("Summary statistic must be 'mean' or 'median'")

    # Compute summary statistic
    if summary_statistic == 'mean':
        statistic = np.tanh(np.nanmean(np.arctanh(iscs), axis=axis))
    elif summary_statistic == 'median':
        statistic = np.nanmedian(iscs, axis=axis)

    return statistic

# %%----------------------------------------------------------------------
#                       1. correlation within subject
# ----------------------------------------------------------------------
# 1-1. calculate average single trial map
# 1-2. correlation with SPM group map

# ======= NOTE: 1-1. calculate average single trial map PAIN
# load stacked numpy and apply mask
imgfname = join(main_dir, 'analysis/fmri/nilearn/singletrial/sub-0060/sub-0060_ses-01_run-05_runtype-vicarious_event-stimulus_trial-011_cuetype-low_stimintensity-low.nii.gz')
ref_img = image.load_img(imgfname)

mask = image.load_img('/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii')
mask_img = nilearn.masking.compute_epi_mask(mask, target_affine=ref_img.affine, target_shape=ref_img.shape)

nifti_masker = nilearn.maskers.NiftiMasker(mask_img=mask_img, smoothing_fwhm=6,
                                            target_affine=ref_img.affine, target_shape=ref_img.shape, 
                                            memory_level=1)
# load group data
beta_dir = join(main_dir, 'analysis/fmri/nilearn/deriv05_singletrialnpy')
suballLv = np.load(join(beta_dir, f"sub-avg_ses-avg_run-avg_task-pain_event-stimulus_cuetype-low.npy"))
suballHv = np.load(join(beta_dir, f"sub-avg_ses-avg_run-avg_task-pain_event-stimulus_cuetype-high.npy"))

with open(join(beta_dir, f"sub-avg_ses-avg_run-avg_task-pain_event-stimulus_cuetype-high.json"), 'r') as file:
    suballHjson = json.load(file)
with open(join(beta_dir, f"sub-avg_ses-avg_run-avg_task-pain_event-stimulus_cuetype-low.json"), 'r') as file:
    suballLjson = json.load(file)
# identify intersection of high and low cue arrays 
non_intersection = list(set(suballHjson['sub']).symmetric_difference(set(suballLjson['sub'])))
intersection = sorted(list(set(suballHjson['sub']).intersection(set(suballLjson['sub']))))

# %% apply mask to each average numpy (shape: subjects x voxels)     
x,y,z=ref_img.shape
Hp = []
Lp = []
for index in range(suballHv.shape[0]):

    Hp.append(
        nifti_masker.fit_transform(
    new_img_like(ref_img, suballHv[index].reshape(x,y,z)))
    )
    Lp.append(
        nifti_masker.fit_transform(
    new_img_like(ref_img, suballLv[index].reshape(x,y,z)))
    )

fmri_masked_stimhighp = np.vstack(Hp)
fmri_masked_stimlowp = np.vstack(Lp)

tvalues, pvalues = scipy.stats.ttest_rel(fmri_masked_stimhighp, fmri_masked_stimlowp, axis=0, nan_policy='propagate',alternative='two-sided' )
reject, qvalues, _, _ = multitest.multipletests(pvalues, method='fdr_bh')

singletrial_t = nifti_masker.inverse_transform(tvalues)
# %%======= NOTE: 1-2. stack SPM contrast and T maps
con = []
con_not_in_SPM = []
subcon = []
for sub in intersection:
    print(f"{sub}")
    spm_dir = join(main_dir, 'analysis/fmri/spm/univariate/model01_6cond/1stLevel', sub)
    spm_fname = 'con_0017.nii'
    spm_fpath = join(spm_dir, spm_fname)
    spm_fpath_gz = spm_fpath + '.gz'
    if not os.path.exists(spm_fpath):
        print(f"The con for '{sub}' does not exist.")
        con_not_in_SPM.append(sub)
    else:
        with open(spm_fpath, 'rb') as f_in:
            with gzip.open(spm_fpath_gz, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        spm_img = image.load_img(spm_fpath_gz)
        con.append(nifti_masker.fit_transform(spm_img))
        subcon.append(sub)
# %%
Timg = []
T_not_in_SPM = []
subT = []
for sub in intersection:
    spm_dir = join(main_dir, 'analysis/fmri/spm/univariate/model01_6cond/1stLevel', sub)
    spmT_fname = 'spmT_0017.nii'
    spmT_fpath = join(spm_dir, spmT_fname)
    spmT_fpath_gz = spmT_fpath + '.gz'
    if not os.path.exists(spmT_fpath):
        print(f"The spmT '{sub}' does not exist.")
        T_not_in_SPM.append(sub)
        
    else:
        with open(spmT_fpath, 'rb') as f_in:
            with gzip.open(spmT_fpath_gz, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        spmT_img = image.load_img(spmT_fpath_gz)
        Timg.append(nifti_masker.fit_transform(spmT_img))
        subT.append(sub)
# %%======= NOTE: 1-3. calculate correlation and plot
constack = np.vstack(con)
spmT = np.vstack(Timg)
# correlation between T
spmT_groupavg = np.nanmean(spmT, axis=0)
np.corrcoef(spmT_groupavg, tvalues)[0,1]
# array1 = spmT_groupavg
# array2 = tvalues
# correlation_coefficient = np.nanmean((array1 - np.nanmean(array1)) * (array2 - np.nanmean(array2))) / (np.nanstd(array1) * np.nanstd(array2))

# plot two images
spm_tmapp = nifti_masker.inverse_transform(spmT_groupavg)
plotting.plot_stat_map(spm_tmapp, display_mode='mosaic', title='SPM T', cut_coords=8)

singletrial_tmap = nifti_masker.inverse_transform(tvalues)
plotting.plot_stat_map(singletrial_tmap, display_mode='mosaic', title='singletrial T', cut_coords=8)

# %%----------------------------------------------------------------------
#                       intersection of SPM and nilearn
# ----------------------------------------------------------------------
# * problem space: SPM has less participants compared to nilearn
# * TODO: first identify the intersection between SPM and nilearn
# * TODO: remove the non overlapping rows in the nilearn array: suballLv, suballHv
# * TODO: rerun SPM with the full participants and full runs. 
# * NOTE: check scripts/step04_SPM/6conditions/failed_spm.py

spmnl_non_intersection = sorted(list(set(subT).symmetric_difference(set(intersection))))
spmnl_intersection = sorted(list(set(subT).intersection(set(intersection))))

# Get the indices of the intersection in slist
intersection_indices = [intersection.index(item) for item in spmnl_intersection]

# Subset the original numpy array based on the intersection indices
subset_suballLv = suballLv[intersection_indices]
subset_suballHv = suballHv[intersection_indices]

print(subset_suballLv.shape)  # Shape: (45, 40000)

# correlation between T
x,y,z=ref_img.shape
Hp = []
Lp = []
for index in range(subset_suballLv.shape[0]):
    Hp.append(
        nifti_masker.fit_transform(
    new_img_like(ref_img, subset_suballHv[index].reshape(x,y,z)))
    )
    Lp.append(
        nifti_masker.fit_transform(
    new_img_like(ref_img, subset_suballLv[index].reshape(x,y,z)))
    )
fmri_masked_stimhighp = np.vstack(Hp)
fmri_masked_stimlowp = np.vstack(Lp)

subsettvalues, pvalues = scipy.stats.ttest_rel(fmri_masked_stimhighp, fmri_masked_stimlowp, axis=0, nan_policy='propagate',alternative='two-sided' )
# singletrial_tsubset = nifti_masker.inverse_transform(subsettvalues)
spmT_groupavg = np.nanmean(spmT, axis=0)
np.corrcoef(spmT_groupavg, subsettvalues)[0,1]



# # iscs = squareform(np.corrcoef(fmri_masked_stimhighp.T), checks=False)
# # fmri_masked_stimlowp = np.vstack(Lp)

# # %%
# # 2. intersubject correlation
# # calculate the mean per subject
# # calculate correlelogram
# # get diagonal to map out ISC
# # average map per participant?

# # %%
# high_cue = np.load( '/Users/h/Desktop/sub-avg_ses-avg_run-avg_event-stimulus_cuetype-high.npy')
# imgfname = join(main_dir, 'analysis/fmri/nilearn/singletrial/sub-0060/sub-0060_ses-01_run-05_runtype-vicarious_event-stimulus_trial-011_cuetype-low_stimintensity-low.nii.gz')
# ref_img = image.load_img(imgfname)

# mask = image.load_img('/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii')
# mask_img = nilearn.masking.compute_epi_mask(mask, target_affine=ref_img.affine, target_shape=ref_img.shape)

# nifti_masker = nilearn.maskers.NiftiMasker(mask_img=mask_img, smoothing_fwhm=6,
#                                             target_affine=ref_img.affine, target_shape=ref_img.shape, 
#                                             memory_level=1)

# # %% DEV:
# X = nifti_masker.fit_transform(high_cue)
# # %% sam code:https://github.com/snastase/isc-tutorial/tree/master
# # Swap axes for np.corrcoef
# summary_statistic = True
# # data = np.swapaxes(high_cue, 2, 0)
# # Original array shape: (n_TRs x n_voxels x n_subjects)

# # New array shape: (n_subjects x n_voxels x n_TRs)
# data = high_cue
# n_voxels = data.shape[1]
# indices = nifti_masker.mask_img.get_fdata().ravel().nonzero()
# mask = list(indices)[0].tolist()

# nifti_masker.fit_transform(high_cue)



# # Loop through voxels
# voxel_iscs = []
# for v in np.arange(data.shape[1]):
#     voxel_data = data[:, v]

#     # Correlation matrix for all pairs of subjects (triangle)
#     iscs = squareform(np.corrcoef(voxel_data), checks=False)
#     voxel_iscs.append(iscs)
# # %%
# iscs_stack = np.column_stack(voxel_iscs)
# iscs = np.full((iscs_stack.shape[0], n_voxels), np.nan)
# iscs[:, np.where(mask)[0]] = iscs_stack
# # if summary_statistic:
# #     iscs = compute_summary_statistic(iscs,

