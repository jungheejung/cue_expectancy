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




import re
import json
import numpy as np
from pathlib import Path
import pandas as pd
from nilearn import image, plotting
from nilearn.image import new_img_like
import numpy.ma as ma
# Example function to extract metadata
def extract_metadata(filename):
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
    

# parameters ___________________________________________________________________
numpy_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv04_covariate/numpy_data'
canlab_dir = '/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore'

main_dir = '/Volumes/spacetop_projects_cue'
numpy_dir = Path(main_dir) / 'analysis' /'fmri'/'nilearn'/'deriv04_covariate'/'numpy_data'
fmri_event= 'stimulus'

canlab_dir = '/Users/h/Documents/MATLAB/CanlabCore'
beh_regressor = 'PE_mdl2'

# 1. Load Data from Numpy Directory ____________________________________________


# Load JSON file
sub = 'sub-0073'
json_fname = Path(numpy_dir) / f'{sub}_task-pain.json'
npy_fname = Path(numpy_dir) / f'{sub}_task-pain.npy'
with open(json_fname, 'r') as f:
    flist = json.load(f)

filenames = flist['filenames']
data_array = np.load(npy_fname)


# %% -------------------------------------------------------------------
#                        load bad_dict and reformat 
# ----------------------------------------------------------------------
# This json file keeps track of all the runs and subjects we need to exclude
# we need to reformat becase the dictionary values are aligned with the fmriprep output filenames
# in other words, we need to zeropad some elements so that they are harmonized with the nilearn single trials
print("load bad data metadata")
print("Load bad data metadata")
badruns_json_fname = '/Users/h/Documents/projects_local/cue_expectancy/scripts/bad_runs.json'
with open(badruns_json_fname, "r") as json_file:
    bad_dict = json.load(json_file)

padded_dict = {}
for subject, runs in bad_dict.items():
    padded_runs = []
    for run in runs:
        # Split run by '_'
        parts = run.split('_')
        if len(parts) < 2:
            print(f"Unexpected format in run: {run}")
            continue
        
        # Further split the second part by '-'
        sub_parts = parts[1].split('-')
        if len(sub_parts) < 2:
            print(f"Unexpected format in run: {run}")
            continue
        
        # Pad the second part and reassemble
        padded_run = f"{parts[0]}_{sub_parts[0]}-{sub_parts[1].zfill(2)}"
        padded_runs.append(padded_run)
    
    padded_dict[subject] = padded_runs

print("Padded dictionary:", padded_dict)


# %% 2. Filter Rows Based on JSON Selection _______________________________________
# filter filenames that contain a specific condition, e.g. event-stimulus,
# find indices of those filtered filenames and apply that index to the numpy data
filtered_filenames = []
# cross check with bad_runs.json
for f in filenames:
    # if 'event-stimulus' in f:
        # Extract the sub, ses, and run using regex
    match = re.search(r'(sub-\d+).*(ses-\d+).*(_run-\d+)', f)
    if match:
        sub, ses, run = match.groups()
        ses_run = f"{ses}{run}"
        if sub in bad_dict and ses_run not in bad_dict[sub]:
            filtered_filenames.append(f)
        elif sub not in bad_dict:
            filtered_filenames.append(f)

print(filtered_filenames)

# extract indices from filtered files
filtered_indices = [filenames.index(f) for f in filtered_filenames]


# 3. Extract Corresponding Rows from Numpy Array _______________________________
filtered_data_array = data_array[:, :, :, filtered_indices]

# 4. Concatenate with Metadata Extracted from Filenames ________________________
metadata_list = [extract_metadata(f) for f in filenames]
metadata_df = pd.DataFrame(metadata_list)
# filtered_metadata_indices = [i for i, meta in enumerate(metadata_list) if meta['sub'] == '0002' and meta['event'] == 'stimulus']
metadata_filtered = metadata_df[(metadata_df['sub'] == sub) & (metadata_df['event'] == 'stimulus')]
filtered_metadata_indices = metadata_filtered.index.tolist()
print(metadata_filtered.head())
print(filtered_metadata_indices)
# Filter the NumPy array based on these indices
braindata_filtered = data_array[:,:,:,filtered_metadata_indices]
print(f"Filtered data: original {data_array.shape} -> filtered {braindata_filtered.shape}")

# 5. Apply Brain Mask to Numpy Data ____________________________________________
imgfname = Path(main_dir) / 'analysis' / 'fmri'/ 'nilearn'/ 'singletrial_rampupplateau'/ 'sub-0060'/f'sub-0060_ses-01_run-01_runtype-pain_event-{fmri_event}_trial-005_cuetype-high_stimintensity-high.nii.gz'
ref_img = image.load_img(imgfname)

mask = image.load_img(join(canlab_dir, 'CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii'))
mask_img = nilearn.masking.compute_epi_mask(mask, target_affine = ref_img.affine, target_shape = ref_img.shape)

nifti_masker = nilearn.maskers.NiftiMasker(mask_img= mask_img,
                                           smoothing_fwhm=6,
                            target_affine = ref_img.affine, target_shape = ref_img.shape, 
                    memory="nilearn_cache", memory_level=1)


# 6. Intersect Brain Data with Behavioral Data _________________________________
# load behavioral data
# TODO filepath
beh_fname = '/Users/h/Documents/projects_local/cue_expectancy/data/RL/July2024_Heejung_fMRI_paper/table_pain.csv'
behdf = pd.read_csv(beh_fname)
# reformat behdf to match metadata
behdf['trial'] = behdf.groupby(['src_subject_id', 'ses', 'param_run_num']).cumcount()
new_columns = {'src_subject_id': 'sub', 
               'param_run_num': 'run',
               }
behdf = behdf.rename(columns=new_columns)
behdf['sub'] = behdf['sub'].apply(lambda x: f"sub-{int(x):04d}")
behdf['run'] =  behdf['run'].apply(lambda x: f"run-{int(x):02d}")
behdf.rename(columns={'param_cue_type': 'cuetype', 'param_stimulus_type': 'stimintensity'}, inplace=True)
beh_subset = behdf[(behdf['sub'] == sub)] #& (behdf['ses'] == ses) & (behdf['run'] == run)]
# intersect brain data and beh data
metadata_filtered = metadata_filtered.reset_index(drop=True)
behdf = behdf.reset_index(drop=True)
keys = ['sub', 'ses', 'run', 'trial_index'] #, 'cuetype', 'stimintensity']
# metadata_filtered[keys] = metadata_filtered[keys].astype(int)
# behdf[keys] = behdf[keys].astype(int)
intersection = pd.merge(behdf, metadata_filtered, on=keys) #, how='inner')
intersection['beh_demean'] = intersection[beh_regressor].sub(intersection[beh_regressor].mean())
# flist = []
# TODO
intersection.to_csv(join(save_dir,beh_savename, task, f"{sub}_task-{task}_beh-{beh_savename}_intersection.csv"))


# # %% 05 using intersection, grab nifti/npy _____________________________
intersection_indices = intersection.index.tolist()
subwise = braindata_filtered[:, :, :, intersection_indices]
# brain_y = subwise.reshape(-1, subwise.shape[-1])

print(f"Filtered data: original {braindata_filtered.shape} -> filtered {subwise.shape}")

# %% 06 apply mask _____________________________________________________
# extract shape information from filtered brain data
x, y, z, n_timepoints = subwise.shape

# Flatten the 4D brain data along the spatial dimensions
brain_y_flat = subwise.reshape(-1, n_timepoints)  # Shape: (x*y*z, n_timepoints)

# Mask the entire 4D data
masked_y = nifti_masker.fit_transform(new_img_like(ref_img, subwise))


# %% 07 calculate correlation with behavioral value ____________________

from sklearn.linear_model import LinearRegression
import numpy as np

# Assuming brain_data has shape (73, 86, 73, 69)
# Flatten the spatial dimensions: (73, 86, 73, 69) -> (num_voxels, 69)

# Initialize the model
model = LinearRegression()

# Fit the model to the behavioral data
# brain_data_flat.T has shape (69, num_voxels), so we transpose it for sklearn
beh_X = intersection['beh_demean'].values.reshape(-1, 1)
model.fit(beh_X, masked_y)

# Get the beta coefficients
beta_coefficients = model.coef_
beta_img = nifti_masker.inverse_transform(beta_coefficients.T)#beta_map)
plotting.plot_stat_map(beta_img) #, display_mode='lyrz', threshold=2.0, title="NIfTI Image")

# plot surface
from nilearn.datasets import fetch_surf_fsaverage
from nilearn import surface, plotting
fsaverage = fetch_surf_fsaverage()

# Project the 3D NIfTI image onto the fsaverage surface
texture = surface.vol_to_surf(beta_img, fsaverage.pial_left)

# Plot the surface
plotting.plot_surf_stat_map(fsaverage.infl_left, texture, hemi='left', title='Surface Plot', colorbar=True)



# TODO prototype


# runwise_correlations = []
# for run, run_indices in intersection.groupby(['ses', 'run']).groups.items():
#     print(run, run_indices)
#     beh_subset = intersection['beh_demean'].iloc[run_indices]
#     fmri_subset = fmri_masked_single[run_indices, :]
#     # if there's a nan in the beh_regressor, mask it
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
# plot = plotting.plot_stat_map(resampled_image,  display_mode = 'mosaic', title = f'task-{task} corr w/ {fmri_event} and {beh_savename}', cut_coords = 8)
# plot.savefig(join(save_dir ,beh_savename, task, f'{sub}_task-{task}_corr_x-{fmri_event}_y-{beh_savename}.png'))
# resampled_image.to_filename(join(save_dir, beh_savename, task, f'{sub}_task-{task}_corr_x-{fmri_event}_y-{beh_savename}.nii.gz'))
