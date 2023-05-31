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
sub = 'sub-0015'
flist = glob.glob(os.path.join(fmriprep_dir, sub, '**', 'func', f"{sub}*task-social*MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"), recursive = True)

# %%
full_img = image.concat_imgs(sorted(flist))
# %%
arr = full_img.get_fdata()
reshaped_arr = arr.reshape((458294, 5232))
corr_matrix = np.corrcoef(reshaped_arr, rowvar=False)

# %% Plot the correlation matrix as a density heatmap
sns.heatmap(corr_matrix, cmap='viridis', annot=True, fmt='.2f', square=True)

plt.title('Correlation Matrix')
plt.xlabel('Features')
plt.ylabel('Features')

plt.show()
# load fieldmap data 
# load bad data