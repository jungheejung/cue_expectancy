# %%
import numpy as np
import glob
import os
import pathlib
import re
import statsmodels 
import pandas as pd
from statsmodels.stats import multitest
import scipy
import nilearn
from scipy import stats
from nilearn.image import resample_to_img, math_img
from nilearn import image
from nilearn import plotting
import argparse
from nilearn.image import new_img_like
import matplotlib.pyplot as plt
from itertools import product
from os.path import join

# %%
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

# %%
main_dir = '/Volumes/spacetop_projects_cue'
beta_dir = join(main_dir, 'analysis/fmri/nilearn/deriv05_singletrialnpy')
beh_dir = join(main_dir, 'data', 'beh', 'beh02_preproc')
# %%
sub_list = sorted(next(os.walk(beta_dir))[1])
 
sub_list.remove( 'sub-0071')
# [x]01 stack npy single trial data
# [x]02 load single trial
# [x]03 stack
# [x]04 extract metadata append in separate pandas
# load behavioral data
# grab the intersection of metadata and behavioral data
###############
# mask
sub = 'sub-0073'
# %%
# create mask from canlab mask. Use sample single trial as target shape/affine
imgfname = join(main_dir, 'analysis/fmri/nilearn/singletrial/sub-0060/sub-0060_ses-01_run-05_runtype-vicarious_event-stimulus_trial-011_cuetype-low_stimintensity-low.nii.gz')
ref_img = image.load_img(imgfname)

mask = image.load_img('/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii')
mask_img = nilearn.masking.compute_epi_mask(mask, target_affine = ref_img.affine, target_shape = ref_img.shape)

nifti_masker = nilearn.maskers.NiftiMasker(mask_img= mask_img,
                                           smoothing_fwhm=6,
                            target_affine = ref_img.affine, target_shape = ref_img.shape, 
                    memory="nilearn_cache", memory_level=1)
################
# %%
task = 'pain'
total_stack = []
# sub_list = ['sub-0072']

for sub in sub_list:
    print(f"_____________{sub}_____________")
    subwise_stack = []
    flist = sorted(glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*.npy")))

        # unique_ses, unique_run = extract_ses_and_run(flist)
        # avgallL = []; avgallH = []
        
        # for ses, run in product(unique_ses, unique_run): #sub-0123_ses-01_run-01_runtype-pain_event-stimulus_trial-000_cuetype-high_stimintensity-low.npy
            # print(f"_____________{ses} {run} _____________")
            # 02 load single trial ____________________________________________________
            # flist = glob.glob(join(beta_dir, sub, f"{sub}_{ses}_{run}*{task}*event-stimulus_*.npy"))
            # runstack = [np.load(fpath).ravel() for fpath in sorted(flist)]
   
    # 03 stack single trial ____________________________________________________
    # subwise = np.vstack(subwise_stack)

    # 04 extract metadata from filenames ____________________________________________________
    keyword_names = ["sub", "ses", "run", "runtype", "event", "trial", "cuetype", "stimintensity"] # Define the desired keyword names
    dfs = [
        pd.DataFrame([dict(zip(keyword_names, re.findall(r'-(.*?)(?:_|$)', os.path.splitext(os.path.basename(nii_fname))[0])))])
        for nii_fname in flist
    ]
    metadf = pd.concat(dfs, ignore_index=True)

    # Strip leading zeros from specific columns
    for column in ['sub', 'ses', 'run', 'trial']:
        metadf[column] = metadf[column].apply(lambda x: x.strip('0') if x != '000' else '0')

    # 05 load behavioral data ____________________________________________________
    beh_flist = sorted(glob.glob(join(main_dir, 'data', 'beh', 'beh02_preproc', sub, '**', f"{sub}_*{task}_beh.csv"), recursive=True))
    dfs = [pd.read_csv(beh_fname) for beh_fname in beh_flist]
    behdf = pd.concat(dfs, axis=0)
    behdf['trial'] = behdf.groupby('param_run_num').cumcount()
    behdf['sub'] = behdf['src_subject_id']
    behdf['ses'] = behdf['session_id']
    behdf['run'] = behdf['param_run_num']
    # from flist extract metadata
    # 06 grab intersection of metadata and behavioral data ____________________________________________________
    metadf = metadf.reset_index(drop=True)
    behdf = behdf.reset_index(drop=True)
    keys = ['sub', 'ses', 'run', 'trial']
    metadf[keys] = metadf[keys].astype(int)
    behdf[keys] = behdf[keys].astype(int)
    intersection = pd.merge(behdf, metadf, on=keys, how='inner')#, right_index=True)
    flist = []
    for index, row in intersection.iterrows():
        # print(f"{row['sub']} {row['ses']} {row['run']} {row['trial']}")
        fname = sorted(glob.glob(join(beta_dir, sub, f"sub-{row['sub']:04d}_ses-{row['ses']:02d}_run-{row['run']:02d}_runtype-{row['runtype']}_event-{row['event']}_trial-{row['trial']:03d}_*.npy")))
        flist.append(fname)
    flatlist=[]
    for sublist in flist:
        for element in sublist:
            flatlist.append(element)
    if flist != []:
        subwise_stack = [np.load(fpath).ravel() for fpath in sorted(flatlist)]
    subwise  = np.vstack(subwise_stack)
    #     sorted(glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*.npy")))
    # if flist != []:
    #     subwise_stack = [np.load(fpath).ravel() for fpath in flist]

    # 07 apply mask ________________________________________________________________________________________________________
    x,y,z=ref_img.shape
    singlemasked = []
    for index in range(subwise.shape[0]):

        singlemasked.append(
            nifti_masker.fit_transform(
        new_img_like(ref_img, subwise[index].reshape(x,y,z)))
        )

    fmri_masked_single = np.vstack(singlemasked)

    # list of groups
    for group_name, group_indices in intersection.groupby('run').groups.items():
        # fmri_masked_single[group_indices, :]
        group_indeces = [24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35]
        beh_subset = intersection.iloc[group_indeces]
        fmri_subset = fmri_masked_single[group_indices, :]
        correlation_coefficients = np.corrcoef(fmri_subset, beh_subset.event02_expect_angle.T, rowvar = False)

        # correlation_coefficients = np.corrcoef(fmri_masked_single[group_indices, :], intersection.event02_expect_angle.T, rowvar = False)
# load data
# z transform
# average z transform per run
# ttest for all participants
    # 08 calculate correlation between behavioral and numpy array ________________________________________________________________________________________________________
    ########################################################
    # correlation_coefficients = np.corrcoef(fmri_masked_single, intersection.event02_expect_angle.T, rowvar = False)
    # fisherz_run = np.arctanh(run_data[0, cortical_vertices])
    # ttest = st.ttest_1samp(np.arctanh(correlation_coefficients), 0.0)

    # tvalues, pvalues = scipy.stats.ttest_rel(fmri_masked_stimhighp, fmri_masked_stimlowp, axis = 0, nan_policy = 'propagate',alternative='two-sided' )
    # reject, qvalues, _, _ = multitest.multipletests(pvalues, method='fdr_bh')

    # result_mapp = np.zeros(fmri_masked_stimhighp.shape[1])
    # result_mapp[qvalues < .05] = tvalues[qvalues < .05]
    # con_tmapp = nifti_masker.inverse_transform(result_mapp)

    # result_map_001p = np.zeros(fmri_masked_stimhighp.shape[1])
    # result_map_001p[qvalues < .001] = tvalues[qvalues < .001]
    # con_tmap_001p = nifti_masker.inverse_transform(result_map_001p)

    # plotting.plot_stat_map(con_tmapp,  display_mode = 'mosaic', title = 'task-pain q < .05', cut_coords = 8)
    # plotting.plot_stat_map(con_tmap_001p,  display_mode = 'mosaic', title = 'task-pain  q < .001', cut_coords = 8)
    # # correlation_coefficients = np.corrcoef(fmri_masked_single.T, intersection.event02_expect_angle, rowvar=False)
    # correlation_values = correlation_coefficients[:-1, -1]
    ##########################################################


        # end product:

            # cueH_flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_{ses}_{run}*{task}*event-stimulus_*_cuetype-high*.npy"))
            # runstackL = [];runstackH = []
            # # avgrunL = []; avgrunH = []
            # if cueL_flist != [] or cueH_flist != []:
            #     runstackL = [np.load(cueL_fpath).ravel() for cueL_fpath in cueL_flist]
            #     runstackH = [np.load(cueH_fpath).ravel() for cueH_fpath in cueH_flist]
            # cueL_flist
            # cueH_flist
                
# ######################

import numpy as np
from scipy.stats import fisher_zscore

# Assume you have the (n*t) x v data matrix stored in 'data_matrix'
# where n is the number of subjects, t is the number of trials, and v is the number of voxels

n, t, v = data_matrix.shape[0] // t, t, data_matrix.shape[1]

# Reshape the data matrix to have dimensions (n, t, v)
reshaped_data = np.reshape(data_matrix, (n, t, v))

# Calculate correlation coefficients per participant
correlation_coefficients = np.zeros((n, v))
for i in range(n):
    correlation_coefficients[i] = np.corrcoef(reshaped_data[i].T)

# Perform Fisher's z-transformation
fisher_z = np.arctanh(correlation_coefficients)

# Perform t-test to determine significant correlations
t_values = fisher_zscore(fisher_z, axis=0)
p_values = 2 * (1 - stats.t.cdf(np.abs(t_values), df=n-2))

# Extract significant correlations (e.g., with p-value threshold)
significant_correlations = t_values[p_values < 0.05]

# Print significant correlations (example)
print(f"Significant correlations: {significant_correlations}")

# %%
