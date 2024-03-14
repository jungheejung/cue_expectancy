from sklearn.model_selection import GroupKFold, cross_val_score, KFold
from sklearn.cross_decomposition import PLSRegression
from sklearn.metrics import make_scorer, mean_squared_error
import numpy as np
import os, glob, re, json
from os.path import join
import numpy as np
import pandas as pd
from nilearn import image, masking, maskers, plotting
from nilearn.image import resample_to_img, math_img, new_img_like
from datetime import datetime
import nibabel as nib
import matplotlib.pyplot as plt
import seaborn as sns
import joblib
import h5py

import os
import re
import json
import glob
from datetime import datetime
from os.path import join
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import nibabel as nib
import joblib
import h5py

from sklearn.model_selection import GroupKFold, cross_val_score, KFold
from sklearn.cross_decomposition import PLSRegression
from sklearn.metrics import make_scorer, mean_squared_error

from nilearn import image, masking, plotting
from nilearn.maskers import NiftiLabelsMasker, NiftiMapsMasker
from nilearn.image import resample_to_img, math_img, new_img_like

import neuromaps
from neuromaps import datasets as neuromaps_datasets
from neuromaps.datasets import fetch_annotation, fetch_fslr
from neuromaps.parcellate import Parcellater
from neuromaps.images import dlabel_to_gifti
from neuromaps.transforms import fsaverage_to_fslr

from netneurotools import datasets as nnt_data

from surfplot import Plot

from sklearn.metrics import confusion_matrix
import seaborn as sns
import matplotlib.pyplot as plt

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

def plot_scores(X_train_r, Y_train_r,
                X_test_r, Y_test_r):

    # 1) On diagonal plot X vs Y scores on each components
    plt.figure(figsize=(12, 8))
    plt.subplot(221)
    plt.scatter(X_train_r[:, 0], Y_train_r[:, 0], label="train",
                marker="o", c="b", s=25)
    plt.scatter(X_test_r[:, 0], Y_test_r[:, 0], label="test",
                marker="o", c="r", s=25)
    plt.xlabel("X comp. 1")
    plt.ylabel("Y comp. 1")
    plt.title('Comp. 1: X vs Y (test corr = %.2f)' %
              np.corrcoef(X_test_r[:, 0], Y_test_r[:, 0])[0, 1])
    plt.xticks(())
    plt.yticks(())
    plt.legend(loc="best")

    plt.subplot(224)
    plt.scatter(X_train_r[:, 1], Y_train_r[:, 1], label="train",
                marker="o", c="b", s=25)
    plt.scatter(X_test_r[:, 1], Y_test_r[:, 1], label="test",
                marker="o", c="r", s=25)
    plt.xlabel("X comp. 2")
    plt.ylabel("Y comp. 2")
    plt.title('Comp. 2: X vs Y (test corr = %.2f)' %
              np.corrcoef(X_test_r[:, 1], Y_test_r[:, 1])[0, 1])
    plt.xticks(())
    plt.yticks(())
    plt.legend(loc="best")

    # 2) Off diagonal plot components 1 vs 2 for X and Y
    plt.subplot(222)
    plt.scatter(X_train_r[:, 0], X_train_r[:, 1], label="train",
                marker="*", c="b", s=50)
    plt.scatter(X_test_r[:, 0], X_test_r[:, 1], label="test",
                marker="*", c="r", s=50)
    plt.xlabel("X comp. 1")
    plt.ylabel("X comp. 2")
    plt.title('X comp. 1 vs X comp. 2 (test corr = %.2f)'
              % np.corrcoef(X_test_r[:, 0], X_test_r[:, 1])[0, 1])
    plt.legend(loc="best")
    plt.xticks(())
    plt.yticks(())

    plt.subplot(223)
    plt.scatter(Y_train_r[:, 0], Y_train_r[:, 1], label="train",
                marker="*", c="b", s=50)
    plt.scatter(Y_test_r[:, 0], Y_test_r[:, 1], label="test",
                marker="*", c="r", s=50)
    plt.xlabel("Y comp. 1")
    plt.ylabel("Y comp. 2")
    plt.title('Y comp. 1 vs Y comp. 2 , (test corr = %.2f)'
              % np.corrcoef(Y_test_r[:, 0], Y_test_r[:, 1])[0, 1])
    plt.legend(loc="best")
    plt.xticks(())
    plt.yticks(())
    plt.show()

    from nilearn import image, plotting
from surfplot import Plot
from neuromaps.transforms import fsaverage_to_fslr
import glob

def plot_brain_surfaces(image, cbar_label='INSERT LABEL', cmap='viridis', color_range=None):
    """
    Plot brain surfaces with the given data.

    Parameters:
    - TST: Tuple of (left hemisphere data, right hemisphere data) to be plotted.
    - cbar_label: Label for the color bar.
    - cmap: Colormap for the data.
    - color_range: Optional. Tuple of (min, max) values for the color range. If not provided, the range is auto-detected.
    """
    surfaces_fslr = fetch_fslr()
    lh_fslr, rh_fslr = surfaces_fslr['inflated']
    
    p = Plot(surf_lh=lh_fslr,
             surf_rh=rh_fslr, 
             size=(5000, 1000), 
             zoom=1.2, layout='row', 
             views=['lateral', 'medial', 'ventral', 'posterior'], 
             mirror_views=True, brightness=.7)
    p.add_layer({'left': image[0], 
            'right': image[1]}, 
            cmap=cmap, cbar=True,
            color_range=color_range,
            cbar_label=cbar_label
            ) # YlOrRd_r

    cbar_kws = dict(outer_labels_only=True, pad=.02, n_ticks=2, decimals=3)
    fig = p.build(cbar_kws=cbar_kws)
    return(fig)
    # fig.show()

# Example usage:
# TST = (left_hemisphere_data, right_hemisphere_data)
# plot_brain_surfaces(TST, cbar_label='gradient', cmap='viridis', color_range=(0, .15))

from nilearn import image, plotting
from surfplot import Plot
from neuromaps.transforms import fsaverage_to_fslr
import glob

def plot_brain_surfaces_lateralonly(image, cbar_label='INSERT LABEL', cmap='viridis', color_range=None):
    """
    Plot brain surfaces with the given data.

    Parameters:
    - TST: Tuple of (left hemisphere data, right hemisphere data) to be plotted.
    - cbar_label: Label for the color bar.
    - cmap: Colormap for the data.
    - color_range: Optional. Tuple of (min, max) values for the color range. If not provided, the range is auto-detected.
    """
    surfaces_fslr = fetch_fslr()
    lh_fslr, rh_fslr = surfaces_fslr['inflated']
    
    p = Plot(surf_lh=lh_fslr,
             surf_rh=rh_fslr, 
             size=(5000, 1000), 
             zoom=1.2, layout='row', 
             views=['lateral'], 
             mirror_views=True, brightness=.7)
    p.add_layer({'left': image[0], 
            'right': image[1]}, 
            cmap=cmap, cbar=True,
            color_range=color_range,
            cbar_label=cbar_label
            ) # YlOrRd_r

    cbar_kws = dict(outer_labels_only=True, pad=.02, n_ticks=2, decimals=3)
    fig = p.build(cbar_kws=cbar_kws)
    return(fig)
    # fig.show()

# Example usage:
# TST = (left_hemisphere_data, right_hemisphere_data)
# plot_brain_surfaces(TST, cbar_label='gradient', cmap='viridis', color_range=(0, .15))

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.colors import to_rgba
# Define the colors at specific points
colors = [
    (-1.8, "#120041"),  # Start with blue at -1.9
    (-1.2, "#2500fa"),
    (-0.6, "#84c6fd"),  # Start with blue at -1.9
    (0, "white"),    # Transition to white at 0
    (0.4, "#d50044"),
    (0.8, "#ff0000"),    # Start transitioning to red just after 0 towards 1.2
    (1.2, "#ffd400")  # End with yellow at 1.2
]

colors_with_opacity = [
    (-1.8, to_rgba("#3661ab", alpha=1.0)),  # Fully opaque
    (-0.9, to_rgba("#63a4ff", alpha=0.8)),  # Fully opaque
    # (-0.1, to_rgba("#008bff", alpha=0.6)),  # Fully opaque
    (0, to_rgba("white", alpha=1.0)),       # Fully opaque
    # (0.1, to_rgba("#d50044", alpha=0.6)),   # 30% opacity
    (0.6, to_rgba("#ffa300", alpha=0.8)),   # 60% opacity
    (1.2, to_rgba("#ff0000", alpha=1.0))    # Fully opaque
]



# Normalize the points to the [0, 1] interval
norm_points = np.linspace(-1.9, 1.2, len(colors_with_opacity))
norm_colors = [c[1] for c in colors_with_opacity]
norm_points = (norm_points - norm_points.min()) / (norm_points.max() - norm_points.min())

# Create a custom colormap
cmap = LinearSegmentedColormap.from_list("custom_gradient", list(zip(norm_points, norm_colors)))

# Create a gradient image
gradient = np.linspace(0, 1, 256)
gradient = np.vstack((gradient, gradient))

# Plot the gradient
fig, ax = plt.subplots(figsize=(6, 2))
ax.imshow(gradient, aspect='auto', cmap=cmap)
ax.set_axis_off()

plt.show()

# load data _______________________
current_dir = os.getcwd()
current_dir
main_dir = Path(current_dir).parents[2] 
print(main_dir)
# /Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv02_parcel-schaefer400/singletrial_rampupplateau_task-pvc_atlas-schaefer2018.npy'
braindf = np.load(join(main_dir, 'analysis/fmri/nilearn/deriv02_parcel-schaefer400', 'singletrial_rampupplateau_task-pvc_atlas-schaefer2018.npy'))
print(f"the shape of the parcel data {braindf.shape}")
df_singletrial = pd.read_csv(join(main_dir, 'analysis/fmri/nilearn/deriv02_parcel-schaefer400', 'singletrial_rampupplateau_task-pvc_atlas-schaefer2018.tsv'), sep='\t')

schaefer = nnt_data.fetch_schaefer2018('fslr32k')['400Parcels7Networks']
parc = Parcellater(dlabel_to_gifti(schaefer), 'fsLR')

df_beh = pd.read_csv('/Users/h/Documents/projects_local/cue_expectancy/data/beh/sub-all_task-all_events.tsv', sep='\t')

# 0-1. merge behavior and single trial data ________________________________
df_beh['singletrial_fname']
df_singletrial['index'] = df_singletrial.index
print(df_singletrial['singletrial_fname'][0])
print(df_beh['singletrial_fname'][0])

print(df_singletrial.shape)
print(df_beh.shape)


merged_df = pd.merge(df_singletrial, df_beh, on=["singletrial_fname", "sub", "ses", "run", "runtype"], how="inner")
print(merged_df.shape)
merged_df.head()

braindf[merged_df['index'].tolist()].shape

# make sure the beh+NPS data is in the parcel data


cleanbraindf = braindf[merged_df['index'].tolist()]
print(f"brain df shape: {cleanbraindf.shape}")
print(f"behavioral - brain intersection shape: {merged_df.shape}")

# behavioral contrast code
merged_df['stim_con'] = merged_df['stimulusintensity'].replace({'high_stim':1, 
                                           'med_stim':0, 
                                           'low_stim':-1})
merged_df['cue_con'] = merged_df['cue'].replace({'high_cue':1, 
                                           'low_cue':-1})   
cleanbehdf = merged_df
print(f"column names: {merged_df.columns}")
print(f"take a look at the beh + NPS dataframe: {merged_df.head()}")

# dummy var 
dummy_vars = pd.get_dummies(cleanbehdf['runtype'])
beh = pd.concat([cleanbehdf, dummy_vars], axis=1)
beh.rename(columns={'pain': 'dummy_pain', 'vicarious': 'dummy_vicarious', 'cognitive': 'dummy_cognitive'}, inplace=True)
beh['dummy_general'] = 1 # adding domain general regressor
beh['pain_expect'] = beh['dummy_pain'] * beh['expectrating']
beh['vic_expect'] = beh['dummy_vicarious'] * beh['expectrating']
beh['cog_expect'] = beh['dummy_cognitive'] * beh['expectrating']
beh['gen_expect'] = beh['dummy_general'] * beh['expectrating']


singletrial = cleanbraindf  # zscored_braindf  # np.random.randn(89, 1)      # Replace with your actual data
# identify groups
from collections import Counter

# subject_ids = [int(re.search(r"sub-(\d+)", fname).group(1)) for fname in flist]
subject_counts = Counter(beh['sub'])  # Count the occurrences of each subject
factorized_ids, unique_ids = pd.factorize(beh['sub'])
groupsinterim = (
    factorized_ids + 1
) 

print(f"beh: {beh.shape} ")
print(f"Y: {singletrial.shape} ")
print(f"groups: {groupsinterim.shape} ")


# Create a dataframe for keep tracking the group ids and bids id _______________
df_mapping = pd.DataFrame({
    "group_id": range(1, len(unique_ids) + 1),
    "bids_id": unique_ids
})

df_mapping.head()

## 0-3. incase we want to drop rows with NA
# but based on https://learnche.org/pid/latent-variable-modelling/principal-component-analysis/preprocessing-the-data-before-building-a-model
# for the initial analysis, include everything.

# The general rule is: add as many columns into 
#  as possible for the initial analysis. You can always prune out the columns later on if they are shown to be uninformative.

#  The course of action when removing outliers is to always mark their values as missing just for that variable in 
# , rather than removing the entire row in 
# . We do this because we can use the algorithms to calculate the latent variable model when missing data are present within a row.

# remove nan values from X, Y, groups
import pandas as pd

# Assuming df_main is your primary DataFrame
nan_rows = beh[beh[['pain_expect', 'vic_expect', 'cog_expect', 'gen_expect']].isnull().any(axis=1)]
beh_dropna = beh.dropna()

singletrial_dropna= singletrial[beh_dropna.index.to_numpy()]
groups_dropna = groupsinterim[beh_dropna.index.to_numpy()]

print(f"X: {beh.shape} after dropping -> {beh_dropna.shape}")
print(f"Y: {singletrial.shape} after dropping -> {singletrial_dropna.shape}")
print(f"groups: {groupsinterim.shape} after dropping -> {groups_dropna.shape}")

# permutation ______________
from sklearn.model_selection import GroupKFold
from sklearn.cross_decomposition import PLSRegression
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.preprocessing import StandardScaler
from sklearn.utils import shuffle
from joblib import Parallel, delayed
import numpy as np
import pandas as pd
# import cloudpickle
import warnings
# SET PARAMETERS
X = singletrial_dropna # (trials x Brain either voxels or parcels)
Y = beh_dropna[['pain_expect', 'vic_expect', 'cog_expect', 'gen_expect']] #(trials x ratings)
groups = groups_dropna

n_components = 10
n_splits = 10
n_permutations = 39
scaler = StandardScaler()
from warnings import simplefilter
# ignore all future warnings
# simplefilter(action='ignore', category=FutureWarning)
# Define parallelized functions
def fit_pls_for_subject(X_train, Y_train, subject_mask, n_components):
    X_train_subj = X_train[subject_mask, :]
    Y_train_subj = Y_train[subject_mask, :]
    # with warnings.catch_warnings():
    #     warnings.simplefilter(action='ignore', category=FutureWarning)
    pls = PLSRegression(n_components=n_components)
    pls.fit(X_train_subj, Y_train_subj)
    return pls.coef_, pls.intercept_

# def permute_and_fit(X, Y, n_permutations, n_components):
#     permute_coefs = []
#     permute_intercepts = []
#     for _ in range(n_permutations):
#         Y_permuted = shuffle(Y)
#         pls = PLSRegression(n_components=n_components)
#         pls.fit(X, Y_permuted)
#         permute_coefs.append(pls.coef_)
#         permute_intercepts.append(pls.intercept_)
#     return np.array(permute_coefs), np.array(permute_intercepts)

def permute_and_fit_single(X, Y, n_components):
    Y_permuted = shuffle(Y)
    pls = PLSRegression(n_components=n_components)
    pls.fit(X, Y_permuted)
    return pls.coef_, pls.intercept_

# Main analysis
outer_cv = GroupKFold(n_splits=n_splits)
results_df = pd.DataFrame()

model_coefs = []
model_intercept = []

permute_coef = []
permute_intercept = []
y_preds = []
bids_ids = []
# y_preds_fold = []
mse_fold = []
r2_fold = []
test_ind = []
beta_per_fold = []

for fold, (train_idx, test_idx) in enumerate(outer_cv.split(X, Y, groups)):
    print(f"Processing fold {fold}_________ ")
    X_train, X_test = X[train_idx], X[test_idx]
    Y_train, Y_test = Y.iloc[train_idx].to_numpy(), Y.iloc[test_idx].to_numpy()
    groups_train = groups[train_idx]
    groups_test = groups[test_idx]
    print(f"X_train shape: {X_train.shape}, Y_train shape: {Y_train.shape}")
    print(f"Number of subject masks: {len(subject_masks)}")

    # Parallel training for each subject
    print(f"model fit: per subject for fold {fold}")
    subject_masks = [groups_train == subject for subject in np.unique(groups_train)]

    print(f"Starting parallel processing for fold {fold}...")
    parallel_results = Parallel(n_jobs=-1, backend='loky')(
    delayed(fit_pls_for_subject)(X_train, Y_train, mask, n_components) for mask in subject_masks
)
    print(f"Completed parallel model fit for fold {fold}.")
    # parallel_results = Parallel(n_jobs=-1, backend='loky')(delayed(fit_pls_for_subject, backend='cloudpickle')(X_train, Y_train, mask, n_components) for mask in subject_masks)
    # parallel_results = Parallel(n_jobs=-1)(delayed(fit_pls_for_subject)(X_train, Y_train, mask, n_components) for mask in subject_masks)
    parallel_results = Parallel(n_jobs=-1, backend='multiprocessing')(
    delayed(fit_pls_for_subject)(X_train, Y_train, mask, n_components) for mask in subject_masks
    )
    coefs, intercepts = zip(*parallel_results)
    # print({len(fold_model_coefs)}, {len(fold_model_intercept)}, {len(y_preds)})

    # average the subjectwise model per fold _______________________________________________
    mean_coef = np.mean(np.stack(coefs),axis=0)
    mean_int = np.mean(intercepts, axis=0)
    print(f"coef: {mean_coef.shape} intercept: {mean_int.shape}")

    model_coefs.append(mean_coef)
    model_intercept.append(mean_int)
    # Permutation tests
    # fold_permute_coefs, fold_permute_intercepts = permute_and_fit(X_train, Y_train, n_permutations, n_components)


    print(f"permutation: for fold {fold}")

    try: 
        parallel_permutations = Parallel(n_jobs=-1)(delayed(permute_and_fit_single)(X_train, Y_train, n_components) for _ in range(n_permutations))
    except Exception as e:
    print(f"Error during parallel execution: {e}")
    fold_permute_coefs, fold_permute_intercepts = zip(*parallel_permutations)
    # Convert lists to numpy arrays for easier handling
    fold_permute_coefs = np.array(fold_permute_coefs)
    fold_permute_intercepts = np.array(fold_permute_intercepts)

    permute_intercept.append(fold_permute_intercepts)
    permute_coef.append(fold_permute_coefs)
    # permute_intercept.append(fold_permute_intercepts)
    # permute_coef.append(fold_permute_coefs)
    print(f"Completed permutations for fold {fold}.")
    print(f"Permutation coefficients shape: {fold_permute_coefs.shape}")

    # 5. get X tests and Y tests


    print(f"fold average coef, intercept shape: {mean_coef.shape}, {mean_int.shape}")


    #Y_pred = pls_subj.predict(X_test)


    print(f"calculate model performance")
    # Here, we calculate Yprd, MSE, R2 per fold. 
    Y_pred_fold = np.dot(X_test, mean_coef.T) + mean_int
    print(f"y pred shape: {Y_pred_fold.shape}")
    mse_fold.append(mean_squared_error(Y_test, Y_pred_fold))
    r2_fold.append(r2_score(Y_test, Y_pred_fold))
    y_preds.append(Y_pred_fold) # out of sample R2 (Q2 PRESS)
    test_ind.append(groups_test)
    print(f"{mse_fold}, \n{r2_fold}")

    XTX_inv = np.linalg.inv(X_test.T.dot(X_test))
    XTY = X_test.T.dot(Y_test)#Y_pred_fold)
    beta = XTX_inv.dot(XTY)
    beta_per_fold.append(beta)
    print(f"Model coefficients collected for all folds. Total shapes: {len(model_coefs)}")

    print(f"Fold {fold} completed. Mean coefficients shape: {mean_coef.shape}.")
