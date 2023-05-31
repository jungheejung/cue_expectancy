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
# %%
fmriprep_dir = '/Volumes/spacetop_data/derivatives/fmriprep/results/fmriprep'
sub = 'sub-0015'
flist = glob.glob(os.path.join(fmriprep_dir, sub, '**', 'func', f"{sub}*task-social*MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"), recursive = True)
full_img = image.concat_imgs(sorted(flist))
# %%
# load fieldmap data 
# load bad data