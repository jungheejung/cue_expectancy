"""
Using single trials, find neural correlates of a specific behavioral parameter.
For example, what are the neural correlates of Prediction error?
We can use the behaviorally extract PE values per trial and correlate with single trials

- Load Data from Numpy Directory
- Filter Rows Based on JSON Selection
- Extract Corresponding Rows from Numpy Array
- Concatenate with Metadata Extracted from Filenames
- Apply Brain Mask to Numpy Data
- Intersect Brain Data with Behavioral Data
"""

import os
import re
import json
import numpy as np
from pathlib import Path
import pandas as pd
import argparse
from nilearn import image, plotting, surface, maskers, masking
from nilearn.image import new_img_like
from nilearn.datasets import fetch_surf_fsaverage
from sklearn.linear_model import LinearRegression

def extract_metadata(filename):
    """
    Extract metadata from the filename using regex.

    Parameters:
    filename (str): The filename to extract metadata from.

    Returns:
    dict: Extracted metadata as a dictionary, or None if not matched.
    """
    # Regular expression pattern to match the filename structure
    pattern = (r"(?P<sub>sub-\d+)_"
               r"(?P<ses>ses-\d+)_"
               r"(?P<run>run-\d+)_"
               r"runtype-(?P<runtype>[a-zA-Z]+)_"
               r"event-(?P<event>[a-zA-Z]+)_"
               r"trial-(?P<trial>\d+)_"
               r"cuetype-(?P<cuetype>[a-zA-Z]+)"
               r"(?:_stimintensity-(?P<stimintensity>[a-zA-Z]+))?")  # Optional stimintensity

    match = re.search(pattern, filename)
    
    if match:
        metadata = match.groupdict()
        metadata['trial_int'] = int(metadata['trial'])
        metadata['trial_index'] = int(metadata['trial']) + 1
        return metadata
    else:
        return None

def load_bad_data_metadata(bad_data_file):
    """
    Load and reformat the bad data metadata.

    Parameters:
    bad_data_file (str): Path to the JSON file containing bad data metadata.

    Returns:
    dict: Padded dictionary with reformatted bad data metadata.
    """
    with open(bad_data_file, "r") as json_file:
        bad_dict = json.load(json_file)

    padded_dict = {}
    for subject, runs in bad_dict.items():
        padded_runs = []
        for run in runs:
            parts = run.split('_')
            if len(parts) < 2:
                print(f"Unexpected format in run: {run}")
                continue
            sub_parts = parts[1].split('-')
            if len(sub_parts) < 2:
                print(f"Unexpected format in run: {run}")
                continue
            padded_run = f"{parts[0]}_{sub_parts[0]}-{sub_parts[1].zfill(2)}"
            padded_runs.append(padded_run)
        padded_dict[subject] = padded_runs
    return padded_dict

def get_unique_sub_ids(directory):
    """
    Extracts and returns a sorted list of unique 'sub-0000' IDs from filenames in a given directory.

    Parameters:
    directory (str): The path to the directory containing the files.

    Returns:
    list: A sorted list of unique 'sub-0000' IDs.
    """
    unique_sub_ids = set()
    pattern = r"(sub-\d{4})"
    
    # Loop through all files in the directory
    for filename in os.listdir(directory):
        # Only process files that match the pattern
        match = re.search(pattern, filename)
        if match:
            unique_sub_ids.add(match.group(1))

    # Convert the set to a sorted list
    unique_sub_ids_list = sorted(unique_sub_ids)
    return unique_sub_ids_list

def filter_filenames(filenames, bad_dict):
    """
    Filter filenames based on bad data metadata and specific conditions.

    Parameters:
    filenames (list): List of filenames to filter.
    bad_dict (dict): Dictionary containing bad data metadata.

    Returns:
    list: List of filtered filenames.
    """
    filtered_filenames = []
    for f in filenames:
        match = re.search(r'(sub-\d+).*(ses-\d+).*(_run-\d+)', f)
        if match:
            sub, ses, run = match.groups()
            ses_run = f"{ses}{run}"
            if sub in bad_dict and ses_run not in bad_dict[sub]:
                filtered_filenames.append(f)
            elif sub not in bad_dict:
                filtered_filenames.append(f)
    return filtered_filenames

# %% argparse __________________________________________________________________
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int,
                    help="specify slurm array id")
parser.add_argument("-t", "--tasktype",
                    choices=['pain','vicarious','cognitive','all'], help="specify runtype name (e.g. pain, cognitive, variance)")
parser.add_argument("--fmri-event", 
                    choices=['cue','stimulus'], help="which fmri epoch event are you selecting?")
parser.add_argument("--beh-regressor", type=str, 
                    help="specify regressor that you'll correlate")
parser.add_argument("--beh-savename", type=str, 
                    help="specify covariate name for saving files")
parser.add_argument("--maindir", type=str, 
                    help="directory where the main directory of this repo is")
parser.add_argument("--savedir", type=str, 
                    help="directory where the beta maps will live")
parser.add_argument("--canlabcore", type=str, 
                    help="directory where the canlab core module is - need brain mask from canlab core")
args = parser.parse_args()
# args.slurm_id = args.args.slurm_id 
task = args.tasktype 



# %% 1. Load Data from Numpy Directory ____________________________________________
numpy_dir = Path(args.maindir) / 'analysis'/'fmri'/'nilearn'/'deriv04_covariate'
sub_list = get_unique_sub_ids(numpy_dir)
print(f"type of slurmid argument: {args.slurm_id}")
sub = sub_list[int(args.slurm_id)]

json_fname = Path(numpy_dir) / f'{sub}_task-pain.json'
npy_fname = Path(numpy_dir) / f'{sub}_task-pain.npy'
with open(json_fname, 'r') as f:
    flist = json.load(f)
filenames = flist['filenames']
data_array = np.load(npy_fname)


# %% load bad_dict and reformat ______________________________________________________________________________
# This json file keeps track of all the runs and subjects we need to exclude
# we need to reformat becase the dictionary values are aligned with the fmriprep output filenames
# in other words, we need to zeropad some elements so that they are harmonized with the nilearn single trials
print("load bad data metadata")
badruns_json_fname = Path(args.maindir) / 'scripts'/ 'bad_runs.json'
bad_dict = load_bad_data_metadata(badruns_json_fname)


# %% 2. Filter Rows Based on JSON Selection and extract corresponding data array _______________________________________
# filter filenames that contain a specific condition, e.g. event-stimulus,
# find indices of those filtered filenames and apply that index to the numpy data
filtered_filenames = filter_filenames(filenames, bad_dict)
filtered_indices = [filenames.index(f) for f in filtered_filenames]
filtered_data_array = data_array[:, :, :, filtered_indices]


# %% 3. Concatenate with Metadata Extracted from Filenames ________________________
metadata_list = [extract_metadata(f) for f in filenames]
metadata_df = pd.DataFrame(metadata_list)
metadata_filtered = metadata_df[(metadata_df['sub'] == sub) & (metadata_df['event'] == args.fmri_event)]
filtered_metadata_indices = metadata_filtered.index.tolist()
print(metadata_filtered.head())
print(filtered_metadata_indices)


# %% 4. Filter the NumPy array based on these indices
braindata_filtered = data_array[:,:,:,filtered_metadata_indices]
print(f"Filtered data: original {data_array.shape} -> filtered {braindata_filtered.shape}")


# %% 5. Apply Brain Mask to Numpy Data ____________________________________________
imgfname = Path(args.maindir) / 'analysis' / 'fmri'/ 'nilearn'/ 'singletrial_rampupplateau'/ 'sub-0060'/f'sub-0060_ses-01_run-01_runtype-pain_event-{args.fmri_event}_trial-005_cuetype-high_stimintensity-high.nii.gz'
ref_img = image.load_img(imgfname)

mask = image.load_img(os.path.joinjoin(args.canlabcore, 'CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii'))
mask_img = masking.compute_epi_mask(mask, target_affine = ref_img.affine, target_shape = ref_img.shape)
nifti_masker = maskers.NiftiMasker(mask_img= mask_img,
                                           smoothing_fwhm=6,
                            target_affine = ref_img.affine, target_shape = ref_img.shape, 
                    memory="nilearn_cache", memory_level=1)


# %% 6. Intersect Brain Data with Behavioral Data _________________________________
# TODO filepath
beh_fname = Path(args.maindir) / 'data/RL/July2024_Heejung_fMRI_paper' / 'table_pain.csv'
behdf = pd.read_csv(beh_fname)
behdf['trial'] = behdf.groupby(['src_subject_id', 'ses', 'param_run_num']).cumcount()
behdf.rename(columns={'src_subject_id': 'sub', 'param_run_num': 'run', 'param_cue_type': 'cuetype', 'param_stimulus_type': 'stimintensity'}, inplace=True)
behdf['sub'] = behdf['sub'].apply(lambda x: f"sub-{int(x):04d}")
behdf['run'] =  behdf['run'].apply(lambda x: f"run-{int(x):02d}")
# TODO: drop rows where args.beh_regressor is NA
beh_subset = behdf[(behdf['sub'] == sub)] #& (behdf['ses'] == ses) & (behdf['run'] == run)]
metadata_filtered = metadata_filtered.reset_index(drop=True)
beh_subset = beh_subset.reset_index(drop=True)

# Remove rows with NA in the behavioral regressor
behdf = behdf.dropna(subset=[args.beh_regressor])

keys = ['sub', 'ses', 'run', 'trial_index'] 
intersection = pd.merge(beh_subset, metadata_filtered, on=keys) #, how='inner')
intersection.to_csv(Path(args.savedir, args.beh_savename, task, f"{sub}_task-{task}_beh-{args.beh_savename}_intersection.csv"))

intersection_indices = intersection.index.tolist()
subwise = braindata_filtered[:, :, :, intersection_indices]
print(f"Filtered data: original {braindata_filtered.shape} -> filtered {subwise.shape}")


# %% 7. apply mask to 4D _____________________________________________________
# extract shape information from filtered brain data
x, y, z, n_timepoints = subwise.shape
masked_y = nifti_masker.fit_transform(new_img_like(ref_img, subwise))


# %% 8. Perform linear regression behavioral value ____________________
model = LinearRegression()  # Initialize the model
intersection['ses_run'] = intersection['ses'] + "_" + intersection['run']
# intersection['ses_run_dummies'] = pd.get_dummies(intersection['ses_run'], drop_first=True)
ses_run_dummies = pd.get_dummies(intersection['ses_run'], drop_first=True)

intersection['beh_demean'] = intersection[args.beh_regressor].sub(intersection[args.beh_regressor].mean())
# intersection['beh_demean'] = intersection[beh_regressor].sub(intersection[beh_regressor].mean())
beh_X = pd.concat([intersection['beh_demean'], ses_run_dummies], axis=1)

# beh_X = intersection[['beh_demean', 'ses_run_dummies']].values.reshape(-1, 1)
model.fit(beh_X, masked_y)

# Get the beta coefficients and transform it into 3d brain volume
beta_coefficients = model.coef_[0]
beta_img = nifti_masker.inverse_transform(beta_coefficients.T)
plot = plotting.plot_stat_map(beta_img,  display_mode = 'mosaic', title = f'task-{task} corr w/ {args.fmri_event} and {args.beh_savename}', cut_coords = 8)
plot.savefig(os.path.join(args.savedir ,args.beh_savename, task, f'{sub}_task-{task}_beta_x-{args.beh_savename}_y-{args.fmri_event}.png'))
beta_img.to_filename(os.path.join(args.savedir, args.beh_savename, task, f'{sub}_task-{task}_beta_x-{args.beh_savename}_y-{args.fmri_event}.nii.gz'))

# plot surface
fsaverage = fetch_surf_fsaverage()
texture = surface.vol_to_surf(beta_img, fsaverage.pial_left)
plotting.plot_surf_stat_map(fsaverage.infl_left, texture, hemi='left', title='Surface Plot', colorbar=True)
plot.savefig(os.path.join(args.savedir ,args.beh_savename, task, f'{sub}_task-{task}_beta_x-{args.beh_savename}_y-{args.fmri_event}_surf.png'))



# TODO prototype


# runwise_correlations = []
# for run, run_indices in intersection.groupby(['ses', 'run']).groups.items():
#     print(run, run_indices)
#     beh_subset = intersection['beh_demean'].iloc[run_indices]
#     fmri_subset = fmri_masked_single[run_indices, :]
#     # if there's a nan in the args.beh_regressor, mask it
#     b=ma.masked_invalid(beh_subset)
#     msk = (~b.mask)
#     model = LinearRegression()
#     model.fit(behregressor, brain_data)

#     # Extract the coefficients
#     beta_coefficients = model.coef_

#     # correlations = np.apply_along_axis(lambda col: np.corrcoef(col, beh_subset[msk].squeeze())[0, 1], axis=0, arr=fmri_subset[msk])
#     # fisherz_run = np.arctanh(correlations)
#     # runwise_correlations.append(fisherz_run)
# avg_run = np.mean(np.vstack(runwise_correlations), axis = 0)
# corr_subjectnifti = nifti_masker.inverse_transform(avg_run)
# print(corr_subjectnifti.shape)
# print(corr_subjectnifti)


# # %% Save the resampled image using the reference affine
# resampled_image = image.resample_to_img(corr_subjectnifti, ref_img)
