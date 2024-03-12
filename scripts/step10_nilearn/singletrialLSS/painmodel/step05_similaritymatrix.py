# %%
import os
import glob
from nilearn import image
from nilearn import plotting
import numpy as np
import pandas as pd
# %%
# for pain, high vs. low cue 
# correlation of average maps between cue map and stimulus map

singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/'
sub_list = next(os.walk(singletrial_dir))[1]
sub_folder = sorted([i for i in sub_list if i.startswith('sub-')])
sub = 'sub-0061'
ses = '*'
run = '*'
runtype = 'pain'
event = 'stimulus'
stim_flist = glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-{event}_trial-*.nii.gz'))
stim_flist = sorted(stim_flist)

stacked_stim = image.concat_imgs(sorted(stim_flist))
sub_mean_stim = image.mean_img(stacked_stim)

# cue
cue_flist = glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-cue_trial-*.nii.gz'))
cue_flist = sorted(cue_flist)
stacked_cue = image.concat_imgs(sorted(cue_flist))
sub_mean_cue = image.mean_img(stacked_cue)
# %%
np.corrcoef(sub_mean_cue.get_data().reshape(-1), sub_mean_stim.get_data().reshape(-1))
# %%
# voxel * trial
flist = []
stim_array = image.get_data(stacked_stim)
len_cuestack = stacked_cue.shape[-1]
R_stim = stim_array.reshape(
    np.prod(list(stacked_cue.shape[0:3])), len_cuestack)

cuearray = image.get_data(stacked_cue)
len_cuestack = stacked_cue.shape[-1]
R_cue = cuearray.reshape(
    np.prod(list(stacked_cue.shape[0:3])), len_cuestack)

R_stimcue = np.hstack((R_stim, R_cue))
flist.extend(stim_flist)
flist.extend(cue_flist)
# %%
from sklearn.metrics import pairwise_distances
import matplotlib.pyplot as plt
rdm_stimcue = pairwise_distances(R_stimcue.T, metric='cosine')
plt.imshow(rdm_stimcue)
plt.xlabel("Trials", fontsize=15)
plt.ylabel("Trials", fontsize=15)
plt.title("Cosine-based RDM", fontsize=20)
cbar = plt.colorbar()
cbar.ax.set_ylabel('Cosine distance', fontsize=15)
plt.show()
# %%








# %% Ver 2: stack and order
singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/'
sub = 'sub-0061'
ses = '*'
run = '*'
runtype = 'pain'
event = 'stimulus'
stim_H_cue_H = sorted(glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-high.nii.gz')))
stim_M_cue_H = sorted(glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-med.nii.gz')))
stim_L_cue_H = sorted(glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-low.nii.gz')))
stim_H_cue_L = sorted(glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-high.nii.gz')))
stim_M_cue_L = sorted(glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-med.nii.gz')))
stim_L_cue_L = sorted(glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-low.nii.gz')))

stim_flist = []
[stim_flist.extend(l) for l in (stim_H_cue_H, stim_M_cue_H, stim_L_cue_H, stim_H_cue_L, stim_M_cue_L, stim_L_cue_L)]
stacked_stim = image.concat_imgs(stim_flist)
sub_mean_stim = image.mean_img(stacked_stim)

# cue
cue_H = sorted(glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-cue_trial-*_cuetype-high.nii.gz')))
cue_L = sorted(glob.glob(os.path.join(
    singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-cue_trial-*_cuetype-low.nii.gz')))

cue_flist = []
[cue_flist.extend(l) for l in (cue_H, cue_L)]
stacked_cue = image.concat_imgs(cue_flist)
sub_mean_cue = image.mean_img(stacked_cue)

np.corrcoef(sub_mean_cue.get_data().reshape(-1), sub_mean_stim.get_data().reshape(-1))
# %%
# voxel * trial
flist = []
stim_array = image.get_data(stacked_stim)
len_cuestack = stacked_cue.shape[-1]
R_stim = stim_array.reshape(
    np.prod(list(stacked_cue.shape[0:3])), len_cuestack)

cuearray = image.get_data(stacked_cue)
len_cuestack = stacked_cue.shape[-1]
R_cue = cuearray.reshape(
    np.prod(list(stacked_cue.shape[0:3])), len_cuestack)

R_stimcue = np.hstack((R_stim, R_cue))
flist.extend(stim_flist)
flist.extend(cue_flist)
# %%
from sklearn.metrics import pairwise_distances
import matplotlib.pyplot as plt
rdm_stimcue = pairwise_distances(R_stimcue.T, metric='cosine')
plt.imshow(rdm_stimcue)
plt.xlabel("Trials", fontsize=15)
plt.ylabel("Trials", fontsize=15)
plt.title("Cosine-based RDM", fontsize=20)
cbar = plt.colorbar()
cbar.ax.set_ylabel('Cosine distance', fontsize=15)
plt.show()
# %%


















# %% Version 3
# condition wise
RDM_stim = np.array([])
track_flist = []
for cue, stim in [('high', 'high'),
                    ('high', 'med'),
                    ('high', 'low'),
                    ('low', 'high'),
                    ('low', 'med'),
                    ('low', 'low')]:
    for sub in sub_folder:
        stim_flist = []
        ses = '*'
        run = '*'
        runtype = 'pain'
        stim_flist = sorted(glob.glob(os.path.join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-{cue}_stimintensity-{stim}.nii.gz')))
        if stim_flist:
            track_flist.extend(stim_flist)
            stacked_stim = image.concat_imgs(stim_flist)
            sub_mean_stim = image.mean_img(stacked_stim)
            stim_array = image.get_data(sub_mean_stim)
            RDM_stim = np.vstack([RDM_stim, stim_array.ravel()]) if RDM_stim.size else stim_array.ravel()
        # RDM_stim = np.concatenate((RDM_stim, stim_array.ravel()), axis = 0)

from sklearn.metrics import pairwise_distances
import matplotlib.pyplot as plt
rdm_stimcue = pairwise_distances(RDM_stim, metric='cosine')
plt.imshow(rdm_stimcue)
plt.xlabel("Trials", fontsize=15)
plt.ylabel("Trials", fontsize=15)
plt.title("cue-wise RDM", fontsize=20)
cbar = plt.colorbar()
cbar.ax.set_ylabel('Cosine distance', fontsize=15)
plt.show()


# %% Version 3-2
# condition wise - intensity
RDM_stim = np.array([])
track_flist = []
for cue, stim in [('high', 'high'),
                    ('low', 'high'),
                    ('high', 'med'),
                    ('low', 'med'),
                    ('high', 'low'),
                    ('low', 'low')]:
    for sub in sub_folder:
        stim_flist = []
        ses = '*'
        run = '*'
        runtype = 'pain'
        stim_flist = sorted(glob.glob(os.path.join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-{cue}_stimintensity-{stim}.nii.gz')))
        
        track_flist.extend(stim_flist)
        stacked_stim = image.concat_imgs(stim_flist)
        sub_mean_stim = image.mean_img(stacked_stim)
        stim_array = image.get_data(sub_mean_stim)
        RDM_stim = np.vstack([RDM_stim, stim_array.ravel()]) if RDM_stim.size else stim_array.ravel()
        # RDM_stim = np.concatenate((RDM_stim, stim_array.ravel()), axis = 0)

from sklearn.metrics import pairwise_distances
import matplotlib.pyplot as plt
rdm_stimcue = pairwise_distances(RDM_stim, metric='cosine')
plt.imshow(rdm_stimcue)
plt.xlabel("Trials", fontsize=15)
plt.ylabel("Trials", fontsize=15)
plt.title("intensity wise RDM", fontsize=20)
cbar = plt.colorbar()
cbar.ax.set_ylabel('Cosine distance', fontsize=15)
plt.show()


# %% Version 4
# subject wise
RDM_stim = np.array([])
track_flist = []

for sub in sub_folder:
    for cue, stim in [('high', 'high'),
                ('high', 'med'),
                ('high', 'low'),
                ('low', 'high'),
                ('low', 'med'),
                ('low', 'low')]:

        stim_flist = []
        ses = '*'
        run = '*'
        runtype = 'pain'
        stim_flist = sorted(glob.glob(os.path.join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-{cue}_stimintensity-{stim}.nii.gz')))
        if stim_flist:
            track_flist.extend(stim_flist)
            stacked_stim = image.concat_imgs(stim_flist)
            sub_mean_stim = image.mean_img(stacked_stim)
            stim_array = image.get_data(sub_mean_stim)
            RDM_stim = np.vstack([RDM_stim, stim_array.ravel()]) if RDM_stim.size else stim_array.ravel()
        # RDM_stim = np.concatenate((RDM_stim, stim_array.ravel()), axis = 0)

from sklearn.metrics import pairwise_distances
import matplotlib.pyplot as plt
rdm_stimcue = pairwise_distances(RDM_stim, metric='cosine')
plt.imshow(rdm_stimcue)
plt.xlabel("Trials", fontsize=15)
plt.ylabel("Trials", fontsize=15)
plt.title("subjectwise RDM", fontsize=20)
cbar = plt.colorbar()
cbar.ax.set_ylabel('Cosine distance', fontsize=15)
plt.show()





