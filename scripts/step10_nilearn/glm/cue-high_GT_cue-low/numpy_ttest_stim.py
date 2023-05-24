# %%
import numpy as np
import glob
import os
import pathlib
import re

import scipy
import nilearn
from scipy import stats
from nilearn.image import resample_to_img, math_img
from nilearn import image
from nilearn import plotting
import argparse
from nilearn.image import new_img_like
import matplotlib.pyplot as plt

def extract_ses_and_run(flist):
    # Initialize empty sets to store unique values of 'ses' and 'run'
    unique_ses = set()
    unique_run = set()

    # Loop through each file path and extract 'ses-##' and 'run-##' using regular expressions
    for path in flist:
        # Extract 'ses-##' using regular expression
        ses_match = re.search(r'ses-(\d+)', path)
        if ses_match:
            unique_ses.add(ses_match.group(0))

        # Extract 'run-##' using regular expression
        run_match = re.search(r'run-(\d+)', path)
        if run_match:
            unique_run.add(run_match.group(0))

    # Print the unique values of 'ses' and 'run'
    print(f"Unique ses values: {sorted(unique_ses)}")
    print(f"Unique run values: {sorted(unique_run)}")
    return list(sorted(unique_ses)), list(sorted(unique_run))

# beta_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy'
beta_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy'
task = 'pain'
sub_list = sorted(next(os.walk(beta_dir))[1])
 

# %%
import glob
import os
import numpy as np
from itertools import product

avgallL = []
avgallH = []
subavgL = []
subavgH = []
suballL = []
suballH = []
for sub in sub_list:
    print(f"_____________{sub}_____________")
    flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*.npy"))
    if flist != []:
        unique_ses, unique_run = extract_ses_and_run(flist)
        avgallL = []; avgallH = []
        for ses, run in product(unique_ses, unique_run):
            stimL_flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_{ses}_{run}*{task}*event-stimulus_*_stimintensity-low*.npy"))
            stimH_flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_{ses}_{run}*{task}*event-stimulus_*_stimintensity-high*.npy"))
            runstackL = [];runstackH = []
            if stimL_flist != [] or stimL_flist != []:
                runstackL = [np.load(stimL_fpath).ravel() for stimL_fpath in stimL_flist]
                runstackH = [np.load(stimH_fpath).ravel() for stimH_fpath in stimH_flist]
                
                avgrunL = np.mean(np.vstack(runstackL), axis=0)
                avgallL.append(avgrunL)
                
                avgrunH = np.mean(np.vstack(runstackH), axis=0)
                avgallH.append(avgrunH)
            else:
                continue
        subavgL = np.mean(np.vstack(avgallL), axis=0)
        suballL.append(subavgL)
        print(f"{sub} {len(suballL)}")
        subavgH = np.mean(np.vstack(avgallH), axis=0)
        suballH.append(subavgH)
    else: 
        continue
# %%
suballLv = np.vstack(suballL)
suballHv = np.vstack(suballH)
np.save(os.path.join(beta_dir, f"sub-avg_ses-avg_run-avg_event-stimulus_stimintensity-low.npy"), suballLv)
np.save(os.path.join(beta_dir, f"sub-avg_ses-avg_run-avg_event-stimulus_stimintensity-high.npy"), suballHv)
# %%
# contrast = scipy.stats.ttest_ind(suballHv, suballLv,
#                                      axis = 0, nan_policy = 'propagate',alternative='two-sided' )
# imgfname = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/sub-0060/sub-0060_ses-01_run-05_runtype-vicarious_event-stimulus_trial-011_cuetype-low_stimintensity-low.nii.gz'
# ref_img = image.load_img(imgfname)
# statmap = contrast.statistic.reshape(ref_img.shape)
# pval = contrast.pvalue.reshape(ref_img.shape)
# indices = np.where(pval < 0.01)
# selected_t_values = statmap[indices]
# # %% canlab mask
# mask = image.load_img('/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii')
# mask_img = nilearn.masking.compute_epi_mask(mask, target_affine = ref_img.affine, target_shape = ref_img.shape)
# stat_img = image.smooth_img(new_img_like(ref_img, statmap), fwhm = 6)
# maskedstatmap = nilearn.masking.apply_mask( stat_img, mask_img)
# masked_stat_img = image.math_img('img1 * img2', img1=stat_img, img2=mask_img)

# plotting.plot_stat_map(masked_stat_img, threshold = 4, display_mode = 'mosaic')
# # image.smooth_img(image.load_img(stimL_flist), fwhm = 6))
# # %%
# # just plot the high stim
# # suballHv
# high_img = new_img_like(ref_img, np.mean(suballHv, axis = 0))
# masked_high_img = image.math_img('img1 * img2', img1=high_img, img2=mask_img)
# plotting.plot_stat_map(masked_stat_img, threshold = 3, display_mode = 'mosaic')



