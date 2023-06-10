# %%
import numpy as np
import os, glob, re
import json
import pathlib
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
import numpy.ma as ma
from pathlib import Path

# %% DEP
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
# %% -------------------------------------------------------------------
#                               argparse
# ----------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--slurm_id", type=int,
                    help="specify slurm array id")
parser.add_argument("-t", "--tasktype",
                    choices=['pain','vicarious','cognitive','all'], help="specify runtype name (e.g. pain, cognitive, variance)")
parser.add_argument("--fmri-event", 
                    choices=['cue','stimulus'], help="which fmri epoch event are you selecting?")
parser.add_argument("--beh-regressor", type=str, 
                    help="specify regressor that you'll correlate")
parser.add_argument("--beh-savename", type=str, 
                    help="specify covariate name for saving files")
parser.add_argument("--savedir", type=str, 
                    help="directory where the correlation maps will live")
args = parser.parse_args()
slurm_id = args.slurm_id 
task = args.tasktype #pain
fmri_event = args.fmri_event
beh_regressor = args.beh_regressor # event02_expect_angle
beh_savename = args.beh_savename #expectrating
save_dir = args.savedir

# %% -------------------------------------------------------------------
#                               parameters 
# ----------------------------------------------------------------------
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social

# main_dir = '/Volumes/spacetop_projects_cue'
beta_dir = join(main_dir, 'analysis', 'fmri', 'nilearn', 'deriv05_singletrialnpy')
beh_dir = join(main_dir, 'data', 'beh', 'beh02_preproc')
canlab_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'
# /Users/h/Documents/MATLAB/CanlabCore
sub_list = sorted(next(os.walk(beta_dir))[1])
sub = sub_list[slurm_id]

# %% -------------------------------------------------------------------
#                        load bad_dict and reformat 
# ----------------------------------------------------------------------
# This json file keeps track of all the runs and subjects we need to exclude
# we need to reformat becase the dictionary values are aligned with the fmriprep output filenames
# in other words, we need to zeropad some elements so that they are harmonized with the nilearn single trials
print("load bad data metadata")

with open(join(main_dir, 'scripts/step00_qc/qc03_fmriprep_visualize/bad_runs.json'), "r") as json_file:
    bad_dict = json.load(json_file)
padded_dict = {}
for subject, runs in bad_dict.items():
    padded_runs = [f"{run.split('_')[0]}_{run.split('_')[1].split('-')[0] + '-' + run.split('_')[1].split('-')[1].zfill(2)}" for run in runs]
    padded_dict[subject] = padded_runs


# %% -------------------------------------------------------------------
#                        create brain mask
# ----------------------------------------------------------------------
# Here, we create a brain mask based on brainmask_canlab.nii; 
# We also use sample single trial as target shape and target affine
sub = 'sub-0073'
imgfname = join(main_dir, 'analysis', 'fmri', 'nilearn', 'singletrial', 'sub-0060', f'sub-0060_ses-01_run-05_runtype-vicarious_event-{fmri_event}_trial-011_cuetype-low_stimintensity-low.nii.gz')
ref_img = image.load_img(imgfname)

mask = image.load_img(join(canlab_dir, 'CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii'))
mask_img = nilearn.masking.compute_epi_mask(mask, target_affine = ref_img.affine, target_shape = ref_img.shape)

nifti_masker = nilearn.maskers.NiftiMasker(mask_img= mask_img,
                                           smoothing_fwhm=6,
                            target_affine = ref_img.affine, target_shape = ref_img.shape, 
                    memory="nilearn_cache", memory_level=1)

# %% -------------------------------------------------------------------
#                        main correlation
# ----------------------------------------------------------------------
#for sub in sub_list:
print(f"_____________{sub}_____________")
subwise_stack = []
# 01 glob files filter if needed using bad_json ____________________
nii_flist = sorted(glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*{fmri_event}*.npy")))
print(beta_dir)

filtered_files = [file_path for file_path in nii_flist 
                      if not any(subject in file_path and run in file_path 
                                 for subject, runs in padded_dict.items() 
                                 for run in runs)]
print(nii_flist)
print(filtered_files)
# 02 extract metadata from filenames _______________________________
keyword_names = ["sub", "ses", "run", "runtype", "event", "trial", "cuetype", "stimintensity"] # Define the desired keyword names
dfs = [
    pd.DataFrame(
        [dict(zip(keyword_names, re.findall(r'-(.*?)(?:_|$)', os.path.splitext(os.path.basename(nii_fname))[0])))]
        )
    for nii_fname in filtered_files
]
print(dfs)
metadf = pd.concat(dfs, ignore_index=True)
for column in ['sub', 'ses', 'run', 'trial']:
    metadf[column] = metadf[column].apply(lambda x: x.strip('0') if x != '000' else '0') # Strip leading zeros from specific columns

# 03 load behavioral data ___________________________________________
beh_flist = sorted(glob.glob(
    join(main_dir, 'data', 'beh', 'beh02_preproc', sub, '**', f"{sub}_*{task}_beh.csv"), recursive=True))
dfs = [pd.read_csv(beh_fname) for beh_fname in beh_flist]
behdf = pd.concat(dfs, axis=0)
behdf['trial'] = behdf.groupby('param_run_num').cumcount()
behdf['sub'] = behdf['src_subject_id']
behdf['ses'] = behdf['session_id']
behdf['run'] = behdf['param_run_num']

# 04 grab intersection of metadata and behavioral data ______________
metadf = metadf.reset_index(drop=True)
behdf = behdf.reset_index(drop=True)
keys = ['sub', 'ses', 'run', 'trial']
metadf[keys] = metadf[keys].astype(int)
behdf[keys] = behdf[keys].astype(int)
intersection = pd.merge(behdf, metadf, on=keys, how='inner')
flist = []

# 05 using intersection, grab nifti/npy _____________________________
for index, row in intersection.iterrows():
    fname = sorted(glob.glob(join(beta_dir, sub, f"sub-{row['sub']:04d}_ses-{row['ses']:02d}_run-{row['run']:02d}_runtype-{row['runtype']}_event-{row['event']}_trial-{row['trial']:03d}_*.npy")))
    flist.append(fname)
flatlist=[]
for sublist in flist:
    for element in sublist:
        flatlist.append(element)
if flist != []:
    subwise_stack = [np.load(fpath).ravel() for fpath in sorted(flatlist)]
subwise  = np.vstack(subwise_stack)

# 06 apply mask _____________________________________________________
x,y,z=ref_img.shape
singlemasked = []
for index in range(subwise.shape[0]):
    singlemasked.append(
        nifti_masker.fit_transform(
    new_img_like(ref_img, subwise[index].reshape(x,y,z)))
    )
fmri_masked_single = np.vstack(singlemasked)

# 07 calculate correlation with behavioral value ____________________
runwise_correlations = []
for run, run_indices in intersection.groupby('run').groups.items():
    beh_subset = intersection[beh_regressor].iloc[run_indices]
    fmri_subset = fmri_masked_single[run_indices, :]
    # if there's a nan in the beh_regressor, mask it
    b=ma.masked_invalid(beh_subset)
    msk = (~b.mask)
    correlations = np.apply_along_axis(lambda col: np.corrcoef(col, beh_subset[msk].squeeze())[0, 1], axis=0, arr=fmri_subset[msk])
    fisherz_run = np.arctanh(correlations)
    runwise_correlations.append(fisherz_run)
avg_run = np.mean(np.vstack(runwise_correlations), axis = 0)
corr_subjectnifti = nifti_masker.inverse_transform(avg_run)
# TODO: save plot
plot = plotting.plot_stat_map(corr_subjectnifti,  display_mode = 'mosaic', title = f'task-{task} corr w/ {fmri_event} and {beh_savename}', cut_coords = 8)
Path(save_dir).mkdir(parents = True, exist_ok = True)
new_img_like(ref_img, corr_subjectnifti).to_filename(join(save_dir, f'corr_{sub}_x-{fmri_event}_y-{beh_savename}.nii.gz'))
#     for run, run_indices in intersection.groupby('run').groups.items():
    
#         # group_indices = [24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35]
#         beh_subset = intersection.event02_expect_angle.iloc[run_indices]
#         fmri_subset = fmri_masked_single[run_indices, :]

#         import numpy as np

#         batch_size = 10  # Number of rows to process in each batch
#         n = fmri_subset.shape[0]  # Total number of rows in fmri_subset
#         correlation_coefficients = []  # List to store correlation coefficients

# ##### TEST
# import numpy as np

# # Define the array and the vector
# array = fmri_subset
# vector = beh_subset
# vector = np.reshape(beh_subset, (beh_subset.shape[0], 1))
# correlations = np.apply_along_axis(lambda col: np.corrcoef(col, vector.squeeze())[0, 1], axis=0, arr=fmri_subset)

# fmri_chunk = array[:,:1000]
# corr_coefs  =[]
# for i in range(fmri_chunk.shape[1]):
#     corr_coefs.append(np.corrcoef(fmri_chunk[:,i], vector))
# np.corrcoef(fmri_chunk.T, vector.squeeze(),  rowvar = True)
# # Split the array into chunks
# chunk_size = 1000
# chunks = [array[:, i:i+chunk_size] for i in range(0, array.shape[1], chunk_size)]

# # Calculate the correlation for each chunk
# correlations = [np.corrcoef(vector,chunk.T) for chunk in chunks]

# # Print the correlations
# for i, correlation in enumerate(correlations):
#     print(f"Chunk {i+1}: Correlation = {correlation}")

# ############
#         for i in range(0, n, batch_size):
#             fmri_batch = fmri_subset[i:i+batch_size]  # Get a batch of fmri data
#             beh_batch = beh_subset[i:i+batch_size]  # Get a batch of behavioral data
#             beh_batch = np.reshape(beh_batch, (beh_batch.shape[0], 1))
#             # # Calculate cross-products of variables
#             # cross_products = np.where(np.isnan(fmri_batch),0,fmri_batch).T.dot(np.where(np.isnan(beh_batch),0,beh_batch))
#             # # cross_products = np.dot(fmri_batch.T, beh_batch.event02_expect_angle.T)

#             # # Calculate standard deviations of variables
#             # fmri_std = np.nanstd(fmri_batch, axis=1, ddof=1)
#             # beh_std = np.nanstd(beh_batch, axis=0)

#             # # Calculate correlation coefficients
#             # corr_batch = cross_products.T / (np.outer(fmri_std, beh_std).T + np.finfo(float).eps).T
#             correlation_coefficients = np.corrcoef(fmri_batch, beh_batch, rowvar = False)
#             correlation_coefficients.append(corr_batch)

#         # Concatenate correlation coefficients from all batches
#         correlation_coefficients = np.concatenate(correlation_coefficients, axis=0)
#     fisherz_run = np.arctanh(correlation_coefficients)
#     np.save('/Users/h/Desktop/corr.npy',correlation_coefficients )
#     intersection.to_csv('/Users/h/Desktop/intersection.csv')
#     fmri_subset = np.load()
#     [24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35]

# # %%
# corr = np.load('/Users/h/Documents/projects_local/sandbox/singletrial_covariates/corr.npy')
# intersection = pd.read_csv('/Users/h/Documents/projects_local/sandbox/singletrial_covariates/intersection.csv')
# subset_beh = intersection.iloc[[24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35]]
# %%
    # # list of groups
    # for group_name, group_indices in intersection.groupby('run').groups.items():
    #     # fmri_masked_single[group_indices, :]

    #     correlation_coefficients = np.corrcoef(fmri_subset, beh_subset.event02_expect_angle.T, rowvar = False)

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
