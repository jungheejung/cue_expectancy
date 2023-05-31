# stack mean images
# calculate covariance matrix
# identify when a fmap was applied (boundaries)
# based on dashboard, list which runs to exclude
#

# %%
import nilearn
import pandas as pd 
import matplotlib.pyplot as plt
import os, glob, sys
from nilearn import image
import numpy as np
import seaborn as sns
# %%
fmriprep_dir = '/Volumes/spacetop_data/derivatives/fmriprep/results/fmriprep'
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/derivatives/fmriprep/results/fmriprep'
save_dir  = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
sub = 'sub-0015'
flist = glob.glob(os.path.join(fmriprep_dir, sub, '**', 'func', f"{sub}*task-social*MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"), recursive = True)

# %%
full_img = image.concat_imgs(sorted(flist))
# %%
arr = full_img.get_fdata()
reshaped_arr = arr.reshape((458294, 5232))
corr_matrix = np.corrcoef(reshaped_arr, rowvar=False)

# %%
# Create the figure and subplots
# Plot the correlation matrix as a density heatmap
fig, (ax_heatmap, ax_hist) = plt.subplots(1, 2, gridspec_kw={
    # 'height_ratios': [10, 3],
    'width_ratios': [10, 3]
    })
sns.heatmap(corr_matrix, cmap='viridis', annot=False, fmt='.2f', square=True, ax=ax_heatmap)

# NOTE: identify when a run ends vs not and add that as tick_positions. Anomaly: there may be runs that are shorter than 872
# labels
names = np.array(['ses-01_run-01', 'ses-01_run-02', 'ses-01_run-03', 'ses-01_run-04', 'ses-01_run-05', 'ses-01_run-06'])
tick_positions = np.arange(0, arr.shape[-1], 872) + 872/2
ax_heatmap.set_yticks(tick_positions) 
ax_heatmap.set_yticklabels(names)

# Add a horizontal line
# TODO: add lines whenever there was a fieldmap applied
ax_heatmap.axhline(y=5, color='r', linestyle='--')
ax_heatmap.axhline(y=872, color='r', linestyle='--')
ax_heatmap.axvline(x=872, color='g', linestyle=':')


# NOTE: upper triangle correlation values
# correlation value histogram
# https://python-charts.com/distribution/histogram-seaborn/
upper_triangle = corr_matrix[np.triu_indices(corr_matrix.shape[0])]
df = {'x': upper_triangle}
sns.histplot(data = df, y = 'x', bins=30, color='blue', edgecolor='black', ax = ax_hist)
# ax_hist.set_xlabel('Values')
# ax_hist.set_ylabel('Frequency')
ax_hist.margins(y=0)
plt.savefig(os.path.join(save_dir, f'{sub}_figure_TEST.png'))
