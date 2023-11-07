"""
Model Pain single trials as a function of
expectation rating, outcome rating, and stim intensity
"""
# %%
from sklearn.model_selection import GroupKFold, cross_val_score, KFold
from sklearn.cross_decomposition import PLSRegression
from sklearn.metrics import make_scorer, mean_squared_error
import numpy as np
import os, glob, re
from os.path import join
import numpy as np
import pandas as pd
from nilearn import image, masking, maskers, plotting
from nilearn.image import resample_to_img, math_img, new_img_like
import joblib


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


# Setup argument parser
parser = argparse.ArgumentParser()
parser.add_argument("--task_id", type=int, help="SLURM array task ID")
args = parser.parse_args()
# %% ###################################################################################################
# load data
singletrial_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy/sub-0002"
singletrial_dir = (
    "/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy/"
)
# Assuming X is your [n_samples x n_features] matrix with predictors
# and Y is your [n_samples x 1] vector with the outcome variable
# groups is an array that indicates the subject each sample belongs to

# %% ###################################################################################################
# load single trial data and append
flist = []
sub_list = ["sub-0002", "sub-0069", "sub-0078", "sub-0120"]
for sub in sub_list:
    flist.extend(sorted(glob.glob(join(singletrial_dir, sub, "*_stimintensity-*.npy"))))
loaded_arrays = []
# Loop over the list of files and load each array
for file_path in flist:
    try:
        array = np.load(file_path)
        loaded_arrays.append(array)
    except Exception as e:
        # Handle the exception if something goes wrong (file not found, etc.)
        print(f"An error occurred while loading {file_path}: {e}")

# loaded_arrays now contains all the loaded numpy arrays
array_2d = np.stack(loaded_arrays, axis=0)
# %% ###################################################################################################
# apply mask
imgfname = "/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/sub-0060/sub-0060_ses-01_run-05_runtype-vicarious_event-stimulus_trial-011_cuetype-low_stimintensity-low.nii.gz"
ref_img = image.load_img(imgfname)
mask = image.load_img(
    "/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii"
)
mask_img = masking.compute_epi_mask(
    mask, target_affine=ref_img.affine, target_shape=ref_img.shape
)

nifti_masker = maskers.NiftiMasker(
    mask_img=mask_img,
    smoothing_fwhm=6,
    target_affine=ref_img.affine,
    target_shape=ref_img.shape,
)
x, y, z = ref_img.shape
maskeddf = []

for index in range(array_2d.shape[0]):
    # apply masker onto numpy array (shape of #subjects x voxels)
    maskeddf.append(
        nifti_masker.fit_transform(
            new_img_like(ref_img, array_2d[index].reshape(x, y, z))
        )
    )
dfstack = np.stack(maskeddf, axis=0)
braindf = dfstack.squeeze()

# %%
Y = braindf  # (72, 98053)
# %% ###################################################################################################
# find behavioral data
# for each subject, load behavioral file for given ses and run
pattern = re.compile(r"sub-(\d+).*ses-(\d+).*run-(\d+)")
unique_combinations = set()  # Extract unique combinations using a set to store them
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
# using identified metadata, load behavioral file

beh_dir = "/Volumes/spacetop_projects_cue/data/beh/beh03_bids"
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
# ensure nifti file and behaviora data merge
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

# stanity check
# Plot z-score normalized braindf heatmap
# plt.figure(figsize=(10, 8))
# sns.heatmap(zscored_braindf, cmap='viridis', cbar=True)
# plt.title('Z-score Normalized braindf Heatmap')
# plt.xlabel('Features')
# plt.ylabel('Observations')
# plt.show()

# %%
Xinterim = merged_df[
    ["stim_con", "expectrating", "outcomerating"]
]  # stacked_dataframe#df #np.random.randn(89, 49000)  # Replace with your actual data
Yinterim = (
    zscored_braindf  # np.random.randn(89, 1)      # Replace with your actual data
)
# identify groups
from collections import Counter

subject_ids = [int(re.search(r"sub-(\d+)", fname).group(1)) for fname in flist]
subject_counts = Counter(subject_ids)  # Count the occurrences of each subject
factorized_ids, unique_ids = pd.factorize(subject_ids)
groupsinterim = (
    factorized_ids + 1
)  # np.array([1, 1, 2, 2, 3, 3, 4, 4, ...])  # Replace with your actual subject identifiers
# %% ##########
# remove nan values from X and Y
nan_rows = Xinterim.isnull().any(axis=1)
X = Xinterim[~nan_rows]
Y = Yinterim[~nan_rows]
mergedf = merged_df[~nan_rows]
groups = groupsinterim[~nan_rows]
clean_indices = nan_rows[~nan_rows].index
import numpy as np

# Assuming 'arr' is your NumPy array
# Calculate the mean of each row excluding NaN values
arr = Y
row_means = np.nanmean(arr, axis=1)
inds = np.where(np.isnan(arr))  # Find the indices where NaN values are present


for i in range(len(inds[0])):  # Replace NaNs with the mean of the corresponding row
    arr[inds[0][i], inds[1][i]] = row_means[inds[0][i]]

# Assuming 'X', 'Y', and 'groups' are loaded or defined earlier in the script
n_splits_outer = 3
n_splits_inner = 5
# %% ###################################################################################################
# Outer loop with GroupKFold for splitting subjects
outer_cv = GroupKFold(n_splits=3)

# Inner loop with KFold for splitting samples
inner_cv = KFold(n_splits=5)

# Define the PLS model
pls_model = PLSRegression(n_components=3)

# Nested CV with parameter optimization
outer_scores = []
weights_per_fold = []
coefficients = []
fold_indices = list(outer_cv.split(X, Y, groups))
train_val_idx, test_idx = fold_indices[
    args.task_id
]  # This will be different for each task

# for train_val_idx, test_idx in outer_cv.split(X, Y, groups):
print(f"train validation: {train_val_idx}, test validation: {test_idx}")
# Split the data into the current outer train/validation and test sets
X_train_val, X_test = X.iloc[train_val_idx].to_numpy(), X.iloc[test_idx].to_numpy()
Y_train_val, Y_test = Y[train_val_idx], Y[test_idx]
groups_train_val = groups[train_val_idx]
print(f"groups: {np.unique(groups_train_val)}")
# Inner CV within the train/validation set
inner_scores = []

for train_idx, val_idx in inner_cv.split(X_train_val, Y_train_val, groups_train_val):
    # Split the data into the current inner train and validation sets
    X_train, X_val = X_train_val[train_idx], X_train_val[val_idx]
    Y_train, Y_val = Y_train_val[train_idx], Y_train_val[val_idx]

    # Fit the model
    pls_model.fit(X_train, Y_train)
    coefficients.append(pls_model.coef_)
    # Evaluate on the inner validation set
    Y_val_pred = pls_model.predict(X_val)
    inner_score = mean_squared_error(Y_val, Y_val_pred)
    inner_scores.append(inner_score)

    # Store the weights of the PLS model
    # For PLSRegression in sklearn, the 'x_weights_' attribute holds the weights
    weights = pls_model.x_weights_
    weights_per_fold.append(weights)
# Average inner loop scores and train on full train/val set, then evaluate on test set
pls_model.fit(X_train_val, Y_train_val)
Y_test_pred = pls_model.predict(X_test)
outer_score = mean_squared_error(Y_test, Y_test_pred)
outer_scores.append(outer_score)

######################################
# SAVE
joblib.dump(
    {
        "train_val_idx": train_val_idx,
        "test_idx": test_idx,
        "outer_scores": outer_scores,
        "weights_per_fold": weights_per_fold,
        "coefficients": coefficients,
        "train_val_sub": mergedf.iloc[train_val_idx]["sub"].unique(),
    },
    f"results_fold_{args.task_id}.pkl",
)
# coeffeicnts : flatten and numpy
# weights_per_fold: flatten and numpy
# outer_score:

# The outer_scores list now contains the MSE for each fold of the outer loop
# print('Outer loop scores:', outer_scores)
# print('Mean performance metric:', np.mean(outer_scores))

# average_weights = np.mean(np.array(weights_per_fold), axis=0)
# average_coefficients = np.mean(coefficients, axis=0)


# first_coef = nifti_masker.inverse_transform(average_coefficients[0,:])
# second_coef = nifti_masker.inverse_transform(average_coefficients[1,:])
# third_coef = nifti_masker.inverse_transform(average_coefficients[2,:])

# first_coef
# %%
# x_weights_first_component = pls_model.x_weights_[:, 0]
# y_weights_first_component = pls_model.y_weights_[:, 0]

# x_weights_second_component = pls_model.x_weights_[:, 1]
# y_weights_second_component = pls_model.y_weights_[:, 1]

# x_weights_third_component = pls_model.x_weights_[:, 2]
# y_weights_third_component = pls_model.y_weights_[:, 2]

# third_img = nifti_masker.inverse_transform(y_weights_third_component)

# %%##################################
# job_script.py
import sys
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.cross_decomposition import PLSRegression
from sklearn.datasets import make_regression
from sklearn.model_selection import KFold

# Assume X and Y are loaded or generated here
X, Y = make_regression(n_samples=1000, n_features=10000, noise=0.1)

# Define the model pipeline
pipeline = Pipeline(
    [("scaler", StandardScaler()), ("pls", PLSRegression(n_components=2))]
)

# Define the cross-validation scheme
cv = KFold(n_splits=5)

# Use the first argument passed to the script as the fold number
fold_number = int(sys.argv[1])  # e.g., 0 for the first fold

# Generate the train/test sets for this fold
for i, (train_index, test_index) in enumerate(cv.split(X)):
    if i == fold_number:
        X_train, X_test = X[train_index], X[test_index]
        Y_train, Y_test = Y[train_index], Y[test_index]
        break

# Fit the model on this fold's training data
pipeline.fit(X_train, Y_train)

# Score the model on this fold's testing data
score = pipeline.score(X_test, Y_test)

# Output the score to a file, e.g., fold_0_score.txt
with open(f"fold_{fold_number}_score.txt", "w") as f:
    f.write(str(score))
import os
import numpy as np

# Assuming your output files are named 'fold_0_score.txt', 'fold_1_score.txt', etc.
num_folds = 5
scores = []

# Loop through the number of folds to read each output file
for fold in range(num_folds):
    filename = f"fold_{fold}_score.txt"
    if os.path.isfile(filename):
        with open(filename, "r") as file:
            score = file.read().strip()
            scores.append(float(score))

# Convert the list of scores to a NumPy array for easy statistical calculations
scores = np.array(scores)

# Calculate and print the mean and standard deviation of the scores
mean_score = np.mean(scores)
std_score = np.std(scores)

print(f"Mean CV score: {mean_score}")
print(f"Standard deviation of CV scores: {std_score}")
