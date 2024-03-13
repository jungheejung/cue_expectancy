"""
Model Pain single trials as a function of
expectation rating, outcome rating, and stim intensity
"""
# %%
from sklearn.model_selection import GroupKFold, cross_val_score, KFold
from sklearn.cross_decomposition import PLSRegression
from sklearn.utils import shuffle
from sklearn.metrics import make_scorer, mean_squared_error
import numpy as np
import os, glob, re, json
from os.path import join
import numpy as np
import pandas as pd
from nilearn import image, masking, maskers, plotting
from nilearn.image import resample_to_img, math_img, new_img_like
from scipy.stats import zscore
from datetime import datetime
import nibabel as nib
import matplotlib.pyplot as plt
import seaborn as sns
import joblib
import pathlib, h5py

"""
fit it first. step wise regression
effect. weights. change
residuals. 
lowest possible estimate. 
depends on the statement.
"""


# %%
def extract_metadata(filenames):
    pattern = re.compile(
        r"sub-(?P<sub>\d+)_"
        r"ses-(?P<ses>\d+)_"
        r"run-(?P<run>\d+)_"
        r"runtype-(?P<runtype>\w+)_"
        r"event-(?P<event>\w+)_"
        r"trial-(?P<trial>\d+)_"
        r"cuetype-(?P<cuetype>\w+)_"
        r"stimintensity-(?P<stimintensity>\w+)"
    )
    metadata_list = []
    for filename in filenames:
        match = pattern.search(filename)
        if match:
            metadata = match.groupdict()
            metadata_list.append(metadata)
    return pd.DataFrame(metadata_list)


# %% ###################################################################################################
# 0. load data
print("0.load data")
singletrial_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy"
# singletrial_dir = (
#    "/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy/"
# )
# Assuming X is your [n_samples x n_features] matrix with predictors
# and Y is your [n_samples x 1] vector with the outcome variable
# groups is an array that indicates the subject each sample belongs to

# %% ###################################################################################################
# 1. oad single trial data and append
print("1. load_singletrial data")
task = "pain"
flist = []
h5py_fname = f"/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step10_nilearn/PLS/brainnumpy_task-{task}.hdf5"
# sub_list = ["sub-0002", "sub-0069", "sub-0078", "sub-0120"]
# for sub in sub_list:
#    flist.extend(sorted(glob.glob(join(singletrial_dir, sub, "*_stimintensity-*.npy"))))
if os.path.exists(h5py_fname):
    with h5py.File(h5py_fname, "r") as f:
        array_2d = f["brainnumpy"][:]
else:
    flist = sorted(
        glob.glob(
            join(singletrial_dir, "sub-*", f"*runtype-{task}*_stimintensity-*.npy"),
            recursive=True,
        )
    )
    loaded_arrays = []
    # Loop over the list of files and load each array
    for file_path in flist:
        try:
            array = np.load(file_path)
            print(f"{os.path.basename(file_path)} {array.shape} ")
            loaded_arrays.append(array)
        except Exception as e:
            print(f"An error occurred while loading {file_path}: {e}")

    # stack all loaded_arrays, convert list to 2d numpy array
    array_2d = np.stack(loaded_arrays, axis=0)
    # save data with json
    import h5py

    metadata = {
        "Author": "Heejung Jung",
        "Date_Created": datetime.now().strftime("%Y-%m-%d"),
        "Description": "Dataset with single trials, concatenated into numpy array ([ subject x voxel ])",
        "Version": 1.0,
        "filelist": flist,
    }
    with h5py.File(h5py_fname, "w") as f:
        dataset = f.create_dataset("brainnumpy", data=array_2d)
        dataset.attrs["Metadata"] = json.dumps(metadata)


# %% ###################################################################################################
# apply mask
print("2. apply mask to numpy array")
imgfname = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/sub-0060/sub-0060_ses-01_run-05_runtype-vicarious_event-stimulus_trial-011_cuetype-low_stimintensity-low.nii.gz"
ref_img = image.load_img(imgfname)
mask = image.load_img(
    "/dartfs-hpc/rc/lab/C/CANlab/modules/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii"
)
mask_img = masking.compute_epi_mask(
    mask, target_affine=ref_img.affine, target_shape=ref_img.shape
)

# apply masker onto numpy array (shape of #subjects x voxels)
# 1) convert to 4d
original_shape = mask_img.shape  # This should be the spatial shape of the brain volume
array_4d = array_2d.reshape(original_shape + (-1,))

# 2) apply masker
affine = mask_img.affine  # Assuming your data shares the same space as the mask
func_4d = nib.Nifti1Image(array_4d, affine)

# Apply the mask using NiftiMasker
nifti_masker = maskers.NiftiMasker(
    mask_img=mask_img,
    smoothing_fwhm=6,
    target_affine=ref_img.affine,
    target_shape=ref_img.shape,
)

masked_func = nifti_masker.fit_transform(func_4d)
braindf = masked_func
# save masked data
masked_h5py_fname = f"/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step10_nilearn/PLS/masked_brainnumpy_task-{task}.hdf5"
with h5py.File(masked_h5py_fname, "w") as f:
    masked_metadata = {
        "Author": "Heejung Jung",
        "Date_Created": datetime.now().strftime("%Y-%m-%d"),
        "Description": f"Dataset with single trials, concatenated into numpy array, after masking it with CANlabbrainmask ([ subject x voxel], {masked_func.shape})",
        "Version": 1.0,
        "filelist": flist,
    }
    dataset = f.create_dataset("masked_brainnumpy", data=masked_func)
    dataset.attrs["Metadata"] = json.dumps(masked_metadata)


# load data
with h5py.File(h5py_fname, "r") as hdf:
    # List all groups
    print("Keys: %s" % hdf.keys())
    a_group_key = list(hdf.keys())[0]
    data = hdf[a_group_key]
    # data = list(hdf[a_group_key])# Get the data
    metadata_json = data.attrs["Metadata"]
    metadata = json.loads(metadata_json)
with h5py.File(h5py_fname, "r") as hdf:
    # List all groups
    print("Keys: %s" % hdf.keys())
    a_group_key = list(hdf.keys())[0]
    # data = hdf[a_group_key]
    data = list(hdf[a_group_key])  # Get the data
    # metadata_json = data.attrs["Metadata"]
    # metadata = json.loads(metadata_json)
    # metadata_json = hdf.attrs["Metadata"]
    # metadata = json.loads(metadata_json)
braindf = np.stack(data)
# %%
Y = braindf  # masked_func.shape (6227, 98053)
# %% ###################################################################################################
# 3. find behavioral data
# for each subject, load behavioral file for given ses and run
print("3. for given brain data, find behavioral data")
pattern = re.compile(r"sub-(\d+).*ses-(\d+).*run-(\d+)")
unique_combinations = set()  # Extract unique combinations using a set to store them
flist = metadata["filelist"]
for file in flist:
    match = pattern.search(file)
    if match:
        # Extract sub, ses, and run numbers and add to the set as a tuple
        unique_combinations.add(
            (int(match.group(1)), int(match.group(2)), int(match.group(3)))
        )
unique_combinations_list = sorted(list(unique_combinations))

print(unique_combinations_list)
# %% ###################################################################################################
# 4. using identified metadata, load behavioral file
print("4. load behavioral file")
beh_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh/beh03_bids"  # "/Volumes/spacetop_projects_cue/data/beh/beh03_bids"
beh_dfs = []
for sub, ses, run in sorted(unique_combinations_list):
    beh_pattern = join(
        beh_dir,
        f"sub-{sub:04d}",
        f"ses-{ses:02d}",
        f"sub-{sub:04d}_ses-{ses:02d}_task-cue_*run-{run:02d}_runtype-*_events.tsv",
    )
    beh_files = glob.glob(beh_pattern)
    if beh_files:
        beh_fname = beh_files[0]
        bdf = pd.read_csv(
            beh_fname, sep="\t"
        )  # Make sure to use the correct separator, e.g., '\t' for TSV files
        beh_dfs.append(bdf)

stacked_df = pd.concat(beh_dfs, ignore_index=True)

# basenames = [os.path.basename(fpath) for fpath in flist]
# matching_rows = stacked_df[stacked_df['singletrial_fname'].isin(basenames)]


basenames = [os.path.basename(fpath).replace(".npy", "") for fpath in flist]
# Remove the '.nii.gz' extension from 'singletrial_fname' in the DataFrame
stacked_df["singletrial_fname_no_ext"] = stacked_df["singletrial_fname"].str.replace(
    ".nii.gz", "", regex=False
)
# Now, find the rows in the DataFrame where singletrial_fname_no_ext matches the basenames without extension
intersection_beh = stacked_df[stacked_df["singletrial_fname_no_ext"].isin(basenames)]

# %% ###################################################################################################
# 5. ensure nifti file and behaviora data merge
print("5. merge brain and behavioral data")
import os
import pandas as pd

# Assuming 'df' is your existing DataFrame with a 'singletrial_fname' column
# And 'flist' is your list of file paths
# Remove the '.npy' extension and sort the list
sorted_basenames = sorted(os.path.basename(f).replace(".npy", "") for f in flist)
# Create a DataFrame from sorted basenames
basenames_df = pd.DataFrame(sorted_basenames, columns=["basename"])
# Remove the '.nii.gz' extension from 'singletrial_fname' and sort the DataFrame
stacked_df["basename"] = stacked_df["singletrial_fname"].str.replace(
    ".nii.gz", "", regex=False
)
sorted_df = stacked_df.sort_values(by="basename").reset_index(drop=True)

# Merge the two DataFrames based on the basename to ensure the order is the same
merged_df = pd.merge(basenames_df, sorted_df, on="basename", how="left")
print(merged_df)

# %% ###################################################################################################
# /sub-0038/ses-01/sub-0038_ses-01_task-cue_run-01_runtype-pain_events.tsv'
# construct subjectwise metadata
# merge filelist and metadata
# Lastly, if there is no metadata, drop data from Y
# load behavioral data for each corresponding participant
merged_df["stim_con"] = merged_df["stimtype"].replace(
    {"high_stim": 1, "med_stim": 0, "low_stim": -1}
)

# %% zscore matrix ###################################################################################################
print("6. zscore matrix")
import pandas as pd
from scipy.stats import zscore

# Assuming 'matrix' is your data matrix and 'df' is your DataFrame with 'sub', 'ses', 'run' columns
# First, ensure that the matrix and df have the same length
assert len(braindf) == len(
    merged_df
), "The matrix and dataframe must have the same number of rows"
# Create a new column in 'merged_df' that uniquely identifies each session
merged_df["session_id"] = (
    merged_df[["sub", "ses", "run"]].astype(str).agg("_".join, axis=1)
)

# Prepare an array to hold the z-scored brain data
zscored_braindf = np.empty_like(braindf)
# Assuming 'run_id' is a column in 'merged_df' that uniquely identifies each run
# and 'braindf' is a pandas DataFrame with the same index as 'merged_df'
# Create an array to hold the column means for each run
column_means_per_run = np.zeros_like(braindf)
session_ids = merged_df["session_id"].unique()

# Calculate the column means for each run and fill NaN values
for session_id in session_ids:
    indices = np.where(merged_df["session_id"] == session_id)[
        0
    ]  # Get the indices for the current run
    column_means = np.nanmean(
        braindf[indices], axis=0
    )  # Calculate the mean of each column for the current run, ignoring NaNs
    # If a whole column is NaNs, fill it with zeros or a global mean if preferred
    column_means = np.nan_to_num(
        column_means, nan=0.0
    )  # or replace 0.0 with a global mean
    # Assign the means to the corresponding places in the column means array
    column_means_per_run[indices] = column_means
# Where braindf is NaN, fill in the values from column_means_per_run
braindf_filled = np.where(np.isnan(braindf), column_means_per_run, braindf)

# Group by 'run_id' and apply the mean of each run to fill NaN values in 'braindf'
# braindf_filled = braindf.groupby(merged_df['session_id']).transform(lambda x: x.fillna(x.mean()))

# Loop through each group and apply z-score normalization to the corresponding rows in 'braindf'
for session_id, group_indices in merged_df.groupby("session_id").groups.items():
    zscored_braindf[group_indices] = zscore(
        braindf_filled[group_indices], axis=0, ddof=1
    )
###########################################################################
# z score input data
# Prepare an array to hold the z-scored brain data
zscored_merged_df = np.empty_like(merged_df)
column_means_per_run = np.zeros_like(merged_df)
sub_ids = merged_df["sub"].unique()

# # Calculate the column means for each run and fill NaN values
# for sub_id in sub_ids:
#     indices = np.where(merged_df["sub"] == sub_id)[0]  # Get the indices for the current run
#     selected_rows = merged_df.iloc[indices]
#     mean_values = selected_rows[['expectrating', 'outcomerating']].mean(axis=1, skipna=True)
#     # column_means = np.nanmean(merged_df.iloc[indices, ['expectrating', 'outcomerating']], axis=0)  # Calculate the mean of each column for the current run, ignoring NaNs
#     column_means = np.nan_to_num(mean_values, nan=0.0)  # or replace 0.0 with a global mean
#     column_means_per_run[indices] = column_means
# # Where braindf is NaN, fill in the values from column_means_per_run
# merged_df_filled = np.where(np.isnan(merged_df), column_means_per_run, braindf)
import numpy as np
import pandas as pd

# Assuming merged_df is your DataFrame and 'sub' is the column with subject IDs
# Replace NaN values with the mean for each subject in 'expectrating' and 'outcomerating'
for sub_id in merged_df["sub"].unique():
    # Select rows for the current subject
    subject_rows = merged_df[merged_df["sub"] == sub_id]

    # Calculate the mean for 'expectrating' and 'outcomerating', skipping NaNs
    subject_mean_expect = subject_rows["expectrating"].mean(skipna=True)
    subject_mean_outcome = subject_rows["outcomerating"].mean(skipna=True)

    # Fill NaN values with the corresponding means for this subject
    merged_df.loc[merged_df["sub"] == sub_id, "expectrating"] = merged_df.loc[
        merged_df["sub"] == sub_id, "expectrating"
    ].fillna(subject_mean_expect)
    merged_df.loc[merged_df["sub"] == sub_id, "outcomerating"] = merged_df.loc[
        merged_df["sub"] == sub_id, "outcomerating"
    ].fillna(subject_mean_outcome)

# Now merged_df should have NaN values filled with each subject's mean for 'expectrating' and 'outcomerating'

# Group by 'run_id' and apply the mean of each run to fill NaN values in 'braindf'
# braindf_filled = braindf.groupby(merged_df['session_id']).transform(lambda x: x.fillna(x.mean()))

# Loop through each group and apply z-score normalization to the corresponding rows in 'braindf'
from scipy.stats import zscore

# Initialize zscored_merged_df with the same structure as merged_df
zscored_merged_df = merged_df.copy()

# Apply zscore to 'expectrating' and 'outcomerating' within each group
for sub_id, group_indices in merged_df.groupby("sub").groups.items():
    zscored_merged_df.loc[group_indices, "expectrating"] = zscore(
        merged_df.loc[group_indices, "expectrating"], axis=0, ddof=1
    )
    zscored_merged_df.loc[group_indices, "outcomerating"] = zscore(
        merged_df.loc[group_indices, "outcomerating"], axis=0, ddof=1
    )
zscored_merged_df.groupby("sub", as_index=False)["outcomerating"].mean()
zscored_merged_df.groupby("sub", as_index=False)["outcomerating"].mean()
# stanity check
# Plot z-score normalized braindf heatmap
plt.figure(figsize=(10, 8))
sns.heatmap(zscored_braindf, cmap="viridis", cbar=True)
plt.title("Z-score Normalized braindf Heatmap")
plt.xlabel("Features")
plt.ylabel("Observations")

plt.savefig(
    "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/step10_nilearn/PLS/heatmap.png",
    dpi=72,
)  # Adjust dpi for resolution requirements


# %%

columns_of_interest = [
    "stim_con",
    "expectrating",
    "outcomerating",
]
Xinterim = zscored_merged_df[columns_of_interest]

# Create a dictionary mapping indices to column names - we'll later use this to save individual comonent maps
X_dict = {i + 1: col for i, col in enumerate(columns_of_interest)}

# Xinterim = merged_df[
#     ["outcomerating", "stim_con", "expectrating"]
# ]  # stacked_dataframe#df #np.random.randn(89, 49000)  # Replace with your actual data
# X_dict = {1: 'outcomerating',
#           2: 'stim_con',
#           3: 'expectrating'}
Yinterim = braindf  # zscored_braindf  # np.random.randn(89, 1)      # Replace with your actual data
# identify groups
from collections import Counter

subject_ids = [int(re.search(r"sub-(\d+)", fname).group(1)) for fname in flist]
subject_counts = Counter(subject_ids)  # Count the occurrences of each subject
factorized_ids, unique_ids = pd.factorize(subject_ids)
groupsinterim = (
    factorized_ids + 1
)  # np.array([1, 1, 2, 2, 3, 3, 4, 4, ...])  # Replace with your actual subject identifiers
np.savetxt(join(save_dir, "subjectid.tsv"), factorized_ids, delimiter="\t", fmt="%s")
# %% ##########
# 7. remove nan values from X and Y
print("7. remove nan values from X and Y")
nan_rows = Xinterim.isnull().any(axis=1)
X = Xinterim[~nan_rows]
Y = Yinterim[~nan_rows]
merged_df[~nan_rows]
groups = groupsinterim[~nan_rows]
clean_indices = nan_rows[~nan_rows].index

row_means = np.nanmean(Y, axis=1)
inds = np.where(np.isnan(Y))  # Find the indices where NaN values are present
for i in range(len(inds[0])):  # Replace NaNs with the mean of the corresponding row
    Y[inds[0][i], inds[1][i]] = row_means[inds[0][i]]

# swap X and Y
# brain = Y
# reg = X

# Y = reg
# X = brain

# %% ###################################################################################################
print("8. start PLS")
k = 10
outer_cv = GroupKFold(n_splits=k)
pls_model = PLSRegression(n_components=3)

outer_scores = []
weights_per_fold = []
coefficients = []

# McKell suggestionmediation style
# minimum effect estimate and maximum estimate.
# if i fit thodse last
# prediction rate ->
# hyperparamter, # of cluster. subset of subjects.
# generalization. CV works well for data that is small
# estimate is less precise.
# CV. what my generalization
i = 0
mses = []
maes = []
r2s = []
coef_dets = []
y_test_combined = []
y_pred_combined = []
X_train_combined = []
X_test_combined = []
n_permutations = 1000
permuted_scores = np.zeros(n_permutations)
for i, (train_val_idx, test_idx) in enumerate(outer_cv.split(X, Y, groups)):
    print(f"________________________________ fold {i} ________________________________")
    X_train, X_test = X.iloc[train_val_idx].to_numpy(), X.iloc[test_idx].to_numpy()
    Y_train, Y_test = Y[train_val_idx], Y[test_idx]
    groups_train_val = groups[train_val_idx]
    print(
        f"train participants: {np.unique(groups[train_val_idx])},test participants: {np.unique(groups[test_idx])}, "
    )
    # Fit the model
    from sklearn.cross_decomposition import PLSRegression
    from sklearn.metrics import (
        mean_squared_error,
        r2_score,
        mean_absolute_error,
        explained_variance_score,
    )

    pls_model.fit(X_train, Y_train)
    coefficients.append(pls_model.coef_)
    # Evaluate on the inner validation set
    # ----------------------------------------
    # Calculate metrics
    Y_pred = pls_model.predict(X_test)
    mse = mean_squared_error(Y_test, Y_pred)
    mae = mean_absolute_error(Y_test, Y_pred)
    r2 = r2_score(
        Y_test, Y_pred
    )  # multioutput='uniform_average' # Average R^2 for multivariate
    explained_variance = explained_variance_score(Y_test, Y_pred)
    # ---------------------------------------
    # Print metrics
    print(f"Mean Squared Error: {mse}")
    print(f"Mean Absolute Error: {mae}")
    print(f"R-squared: {r2}")
    print(f"Explained Variance Score: {explained_variance}")
    mses.append(mse)
    maes.append(mae)
    r2s.append(r2)
    # mse = mean_squared_error(Y_test, Y_pred)
    # mses.append(mse)
    coef_det = pls_model.score(X_test, Y_test)
    coef_dets.append(coef_det)
    # ----------------------------------------
    # Permutation testing within this fold

    # Assuming the nifti_masker has been fitted previously
    y_weights = pls_model.y_weights_
    weights = pls_model.x_weights_
    weights_per_fold.append(weights)

    # Store the true and predicted values
    y_test_combined.extend(Y_test)
    y_pred_combined.extend(Y_pred)
    break
    # X_train_combined.extend(X_train)
    # X_test_combined.extend(X_test)
    # ---------------------------------------------------
    x_weights_first_component = pls_model.x_weights_[:, 0]
    y_weights_first_component = pls_model.y_weights_[:, 0]

    x_weights_second_component = pls_model.x_weights_[:, 1]
    y_weights_second_component = pls_model.y_weights_[:, 1]

    x_weights_third_component = pls_model.x_weights_[:, 2]
    y_weights_third_component = pls_model.y_weights_[:, 2]

    first_img = nifti_masker.inverse_transform(y_weights_first_component)
    second_img = nifti_masker.inverse_transform(y_weights_second_component)
    third_img = nifti_masker.inverse_transform(y_weights_third_component)
    save_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/pls/nonest_task-pain_X-outcome-stim-expect_Y-brain"  # NoNested_task-pain_X-stim-expect-outcome_Y-brain"
    pathlib.Path(save_dir).mkdir(parents=True, exist_ok=True)
    first_img.to_filename(
        join(
            save_dir,
            f"pls-predweights_fold-{i}_component-01_desc-stimuluscontrast.nii.gz",
        )
    )
    second_img.to_filename(
        join(
            save_dir, f"pls-predweights_fold-{i}_component-02_desc-expectrating.nii.gz"
        )
    )
    third_img.to_filename(
        join(
            save_dir, f"pls-predweights_fold-{i}_component-03_desc-outcomerating.nii.gz"
        )
    )
    i += 1
    break

# Calculate the p-value
R2 = np.array(r2s)
mean_R2 = np.mean(R2)
p_value = np.mean(permuted_scores > R2)
print(f"Original R^2 score across folds: {R2}")
print(f"Permutation p-value: {p_value}")
# The outer_scores list now contains the MSE for each fold of the outer loop
# print("Outer loop scores:", outer_scores)
# print("Mean performance metric:", np.mean(outer_scores))

average_weights = np.mean(np.array(weights_per_fold), axis=0)
average_coefficients = np.mean(coefficients, axis=0)


####################################################
# plot each latent variables contribution onto brain data
# Assuming 'pls_model' has been fitted and 'nifti_masker' has been used to flatten the brain matrix
X_scores_test = pls_model.transform(
    X_test
)  # Get the latent variable representation of X
# Calculate Contribution to Latent Space:
# This gives the contribution of the first feature of X_test to the first latent variable's scores.
first_regressor_contribution = X_scores_test[:, 0] * pls_model.x_weights_[0, 0]
# Map to Brain Space:
# This projects the contribution of the first feature on the first latent variable back to the brain space.
# brain_contribution = np.dot(first_regressor_contribution.reshape(-1, 1), pls_model.y_loadings_[0, :].reshape(1, -1))
brain_contribution = np.dot(
    first_regressor_contribution.reshape(-1, 1),
    pls_model.y_loadings_[:, 0].reshape(1, -1),
)
group_id = groups[test_idx]
# Inverse transform to get the 3D brain image
# This step reconstructs the 3D brain image from the modified latent contribution.


brain_contribution_img = nifti_masker.inverse_transform(brain_contribution)
brain_contribution_img.to_filename(join(save_dir, "firstcomponent.nii.gz"))

subject_images = {}

# Split the 4D image into individual 3D images and group by subject
group_ids = groups[train_val_idx]
for i, subject_id in enumerate(group_ids):
    img_3d = image.index_img(brain_contribution_img, i)
    if subject_id not in subject_images:
        subject_images[subject_id] = [img_3d]
    else:
        subject_images[subject_id].append(img_3d)

subject_averages = {
    subject_id: image.mean_img(subject_imgs)
    for subject_id, subject_imgs in subject_images.items()
}
# Open an HDF5 file for writing
with h5py.File(join(save_dir, "nifti_images.hdf5"), "w") as hdf_file:
    # Iterate over the Nifti images
    for subject_id, nifti_image in subject_averages.items():
        # Get the image data as a numpy array
        image_data = nifti_image.get_fdata()

        # Create a dataset for this subject in the HDF5 file
        hdf_file.create_dataset(f"subject_{subject_id}", data=image_data)

        # Optionally, store the affine matrix if you'll need it for reconstruction
        affine = nifti_image.affine
        hdf_file.create_dataset(f"subject_{subject_id}_affine", data=affine)
####################################################
# Check if scores are orthogonal
import numpy as np

U = pls_model.x_scores_  # (4779, 3)
U_normalized = U / np.linalg.norm(U, axis=0)
UTU_normalized = np.dot(U_normalized.T, U_normalized)
identity_matrix = np.eye(U.shape[1])
columns_orthonormal = np.allclose(UTU_normalized, identity_matrix, atol=1e-8)
print(
    f"The columns of the matrix U are {'orthonormal' if columns_orthonormal else 'not orthonormal'}."
)

#####################################################
# permutation:
from sklearn.utils import shuffle
import numpy as np

# Number of permutations
n_permutations = 1000
# scores = np.zeros(n_permutations)
original_score = r2_score(y_test_combined, y_pred_combined)
permuted_scores = np.zeros(n_permutations)
for i in range(n_permutations):
    y_permuted = shuffle(y_test_combined)
    pls_model.fit(X, y_permuted)
    y_permuted_pred = pls_model.predict(X)
    permuted_scores[i] = r2_score(y_permuted, y_permuted_pred)

p_value = np.mean(permuted_scores >= original_score)
print(f"Permutation p-value: {p_value}")


from sklearn.metrics import r2_score
from sklearn.utils import shuffle
import numpy as np

# Assuming you have y_true and y_pred from all folds combined
# original_score = r2_score(y_true, y_pred)
# permuted_scores = np.zeros(n_permutations)

# for i in range(n_permutations):
#     y_permuted = shuffle(y_true)
#     model.fit(X, y_permuted)
#     y_permuted_pred = model.predict(X)
#     permuted_scores[i] = r2_score(y_permuted, y_permuted_pred)

# # Calculate overall p-value
# p_value = np.mean(permuted_scores > original_score)

#####################################################
# plot
X_scores_test = pls_model.transform(X_test)

# Calculate variance explained by each component
variance_explained = np.var(X_scores, axis=0)
total_variance = np.sum(variance_explained)
variance_ratio = variance_explained / total_variance

# Cumulative variance explained
cumulative_variance = np.cumsum(variance_ratio)

# Plotting the variance explained by each PLS component
fig, ax = plt.subplots()
components = np.arange(len(variance_ratio)) + 1
ax.bar(
    components,
    variance_ratio,
    alpha=0.5,
    align="center",
    label="individual explained variance",
)
ax.step(
    components, cumulative_variance, where="mid", label="cumulative explained variance"
)

ax.set_xlabel("PLS components")
ax.set_ylabel("Explained variance ratio")
ax.set_title("Explained variance by different PLS components")
ax.legend(loc="best")
plt.tight_layout()
plt.show()
#######
# VER 2Select specific outcomes to plot (e.g., the first, middle, and last outcome)
# X_scores = pls_model.transform(X_test)  # Get the scores of the test data
# y_pred = pls_model.predict(X_test)  # Get the predicted values
# selected_outcomes = [0, y_pred.shape[1]//2, -1]

# # Now create subplots for each of the selected outcomes
# fig, axes = plt.subplots(1, len(selected_outcomes), figsize=(15, 5))

# for i, outcome_index in enumerate(selected_outcomes):
#     # Plot the ground truth vs. the first PLS component scores for a specific outcome
#     axes[i].scatter(X_scores[:, 0], Y_test[:, outcome_index], alpha=0.3, label="Ground truth")
#     # Plot the predictions vs. the first PLS component scores for a specific outcome
#     axes[i].scatter(X_scores[:, 0], y_pred[:, outcome_index], alpha=0.3, label="Predictions")
#     # Set labels and title for each subplot
#     axes[i].set(
#         xlabel=f"Scores on first PLS component",
#         ylabel=f"Outcome {outcome_index + 1}",
#         title=f"PLS Component 1 vs Outcome {outcome_index + 1}"
#     )
#     axes[i].legend()

# plt.tight_layout()
# plt.show()

# # Now create subplots for each of the first three PLS components
# fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# for i in range(3):
#     # Plot the ground truth vs. the component scores
#     axes[i].scatter(X_scores[:, i], Y_test, alpha=0.3, label="Ground truth")
#     # Plot the predictions vs. the component scores
#     axes[i].scatter(X_scores[:, i], Y_pred, alpha=0.3, label="Predictions")
#     # Set labels and title for each subplot
#     axes[i].set(
#         xlabel=f"Scores on PLS component {i+1}",
#         ylabel="y",
#         title=f"PLS Component {i+1} vs y"
#     )
#     axes[i].legend()

# plt.tight_layout()
# plt.show()

# ROC curve
lr_probs = model.predict_proba(X_test)
# keep probabilities for the positive outcome only
lr_probs = lr_probs[:, 1]
# calculate scores
ns_auc = roc_auc_score(testy, ns_probs)
lr_auc = roc_auc_score(testy, lr_probs)
# summarize scores
print("No Skill: ROC AUC=%.3f" % (ns_auc))
print("Logistic: ROC AUC=%.3f" % (lr_auc))
# calculate roc curves
ns_fpr, ns_tpr, _ = roc_curve(testy, ns_probs)
lr_fpr, lr_tpr, _ = roc_curve(testy, lr_probs)
# plot the roc curve for the model
plt.plot(ns_fpr, ns_tpr, linestyle="--", label="No Skill")
plt.plot(lr_fpr, lr_tpr, marker=".", label="Logistic")
# axis labels
plt.xlabel("False Positive Rate")
plt.ylabel("True Positive Rate")
# show the legend
plt.legend()
# show the plot
plt.show()

######################################
# SAVE
joblib.dump(
    {
        "train_val_idx": train_val_idx,
        "test_idx": test_idx,
        "outer_scores": outer_scores,
        "weights_per_fold": weights_per_fold,
        "coefficients": coefficients,
    },
    f"/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/pls/NoNested_task-pain_reg01-stim_reg02-expect_reg03-outcome/results_fold_.pkl",
)
## %%##################################
## job_script.py
# import sys
# from sklearn.model_selection import cross_val_score
# from sklearn.pipeline import Pipeline
# from sklearn.preprocessing import StandardScaler
# from sklearn.cross_decomposition import PLSRegression
# from sklearn.datasets import make_regression
# from sklearn.model_selection import KFold
#
## Assume X and Y are loaded or generated here
# X, Y = make_regression(n_samples=1000, n_features=10000, noise=0.1)
#
## Define the model pipeline
# pipeline = Pipeline(
#    [("scaler", StandardScaler()), ("pls", PLSRegression(n_components=2))]
# )
#
## Define the cross-validation scheme
# cv = KFold(n_splits=5)
#
## Use the first argument passed to the script as the fold number
# fold_number = int(sys.argv[1])  # e.g., 0 for the first fold
#
## Generate the train/test sets for this fold
# for i, (train_index, test_index) in enumerate(cv.split(X)):
#    if i == fold_number:
#        X_train, X_test = X[train_index], X[test_index]
#        Y_train, Y_test = Y[train_index], Y[test_index]
#        break
#
## Fit the model on this fold's training data
# pipeline.fit(X_train, Y_train)
#
## Score the model on this fold's testing data
# score = pipeline.score(X_test, Y_test)
#
## Output the score to a file, e.g., fold_0_score.txt
# with open(f"fold_{fold_number}_score.txt", "w") as f:
#    f.write(str(score))
# import os
# import numpy as np
#
## Assuming your output files are named 'fold_0_score.txt', 'fold_1_score.txt', etc.
# num_folds = 5
# scores = []
#
## Loop through the number of folds to read each output file
# for fold in range(num_folds):
#    filename = f"fold_{fold}_score.txt"
#    if os.path.isfile(filename):
#        with open(filename, "r") as file:
#            score = file.read().strip()
#            scores.append(float(score))
#
## Convert the list of scores to a NumPy array for easy statistical calculations
# scores = np.array(scores)
#
## Calculate and print the mean and standard deviation of the scores
# mean_score = np.mean(scores)
# std_score = np.std(scores)
#
# print(f"Mean CV score: {mean_score}")
# print(f"Standard deviation of CV scores: {std_score}")
#########
# t
