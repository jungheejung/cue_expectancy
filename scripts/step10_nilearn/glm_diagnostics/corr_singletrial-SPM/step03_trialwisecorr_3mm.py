# %%create an average numpy map per participant
from os.path import join
import numpy as np
import os, glob
from nilearn import maskers, image, plotting, masking
from nilearn.datasets import (load_mni152_template)
import seaborn as sns
import matplotlib.pyplot as plt
# %%
def npmean_list(list):
    arrays = []
    for file in list:
        array = np.load(file)
        arrays.append(array)
    mean_array = np.mean(arrays, axis=0)
    return mean_array
    
# %%
main_dir = '/Volumes/spacetop_projects_cue'
npy_dir = join(main_dir, 'analysis', 'fmri', 'nilearn', 'deriv05_singletrialnpy')
isc_dir = join(main_dir, 'analysis', 'fmri', 'nilearn', 'deriv07_isc')
sub_folders = next(os.walk(npy_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]

for sub in sub_list:
    task = 'vicarious'
    ses1highcueflist = glob.glob(join(npy_dir, sub, f'{sub}_ses-01_*_runtype-{task}_event-stimulus_*_cuetype-high_stimintensity-*.npy'))
    ses1lowcueflist  = glob.glob(join(npy_dir, sub, f'{sub}_ses-01_*_runtype-{task}_event-stimulus_*_cuetype-low_stimintensity-*.npy'))
    ses3highcueflist = glob.glob(join(npy_dir, sub, f'{sub}_ses-03_*_runtype-{task}_event-stimulus_*_cuetype-high_stimintensity-*.npy'))
    ses3lowcueflist  = glob.glob(join(npy_dir, sub, f'{sub}_ses-03_*_runtype-{task}_event-stimulus_*_cuetype-low_stimintensity-*.npy'))
    ses4highcueflist = glob.glob(join(npy_dir, sub, f'{sub}_ses-04_*_runtype-{task}_event-stimulus_*_cuetype-high_stimintensity-*.npy'))
    ses4lowcueflist  = glob.glob(join(npy_dir, sub, f'{sub}_ses-04_*_runtype-{task}_event-stimulus_*_cuetype-low_stimintensity-*.npy'))
    # save in runwise directory
    save_dir = join(npy_dir, 'runwise')
    if ses1highcueflist != []:
        ses1meanHcue = npmean_list(ses1highcueflist)
        np.save(join(save_dir, f'{sub}_ses-01_runtype-{task}_event-stimulus_cuetype-high.npy'), ses1meanHcue)
    if ses1lowcueflist != []:
        ses1meanLcue = npmean_list(ses1lowcueflist)
        np.save(join(save_dir, f'{sub}_ses-01_runtype-{task}_event-stimulus_cuetype-low.npy'), ses1meanLcue)
    if ses3highcueflist != []:
        ses3meanHcue = npmean_list(ses3highcueflist)
        np.save(join(save_dir, f'{sub}_ses-03_runtype-{task}_event-stimulus_cuetype-high.npy'), ses3meanHcue)
    if ses3lowcueflist != []:
        ses3meanLcue = npmean_list(ses3lowcueflist)
        np.save(join(save_dir, f'{sub}_ses-03_runtype-{task}_event-stimulus_cuetype-low.npy'), ses3meanLcue)
    if ses4highcueflist != []:
        ses4meanHcue = npmean_list(ses4highcueflist)
        np.save(join(save_dir, f'{sub}_ses-04_runtype-{task}_event-stimulus_cuetype-high.npy'), ses4meanHcue)
    if ses4lowcueflist != []:
        ses4meanLcue = npmean_list(ses4lowcueflist)
        np.save(join(save_dir, f'{sub}_ses-04_runtype-{task}_event-stimulus_cuetype-low.npy'), ses4meanLcue)
# %% correllogram
high_flist = sorted(glob.glob(join(npy_dir,'runwise', '*cuetype-high.npy'), recursive=True))

# %% apply masker
canlab_dir = '/Users/h/Documents/MATLAB/CanlabCore'
mask_fname = join(canlab_dir, 'CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii')
mask_fname_gz = mask_fname + '.gz'
brain_mask = image.load_img(mask_fname_gz)
template = load_mni152_template(resolution=3)
mask_img = image.resample_to_img(masking.compute_epi_mask(brain_mask), template) #, target_affine=ref_img.affine, target_shape=ref_img.shape)
x,y,z = mask_img.shape
nifti_masker = maskers.NiftiMasker(mask_img=mask_img) 

ref_img_fname = '/Users/h/Documents/projects_local/sandbox/sub-0009/ses-04/func/sub-0009_ses-04_task-fractional_acq-mb8_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'
ref_img = image.index_img(image.load_img(ref_img_fname),8) #image.load_img(ref_img_fname)

cueHarr = []
x,y,z=ref_img.shape
for fname in high_flist:
    data = np.load(fname)
    for index in range(data.shape[0]):
        cueHarr.append(
            nifti_masker.fit_transform(
        image.new_img_like(template, data.reshape(x,y,z)))
        )
# %%
cueH = np.vstack(cueHarr)
# %%
corrarr = np.corrcoef(cueH)
upper_triangle = np.triu(corrarr)
np.save(join(isc_dir, 'TESTupper_triangle.npy'),upper_triangle)
sns.heatmap(upper_triangle)
plt.savefig(join(isc_dir, )"plot.png")
# %% 
upper_triangle = np.load('TESTupper_triangle.npy')
sns.heatmap(upper_triangle)
# %%
plotting.plot_stat_map(nifti_masker.mask_img_)

# TODO: remove the lower triangle
# plot the boundary of runs
# %%
