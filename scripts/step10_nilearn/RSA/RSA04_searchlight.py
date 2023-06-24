#!/usr/bin/env python
# coding: utf-8
"""
TODO: add more documentation
Stack fMRI single trials, creates RDM and applies model RDM per fMRI array using a searchlight

Raises:
    ValueError: [description]

Returns:
    [type]: [description]
"""
import os, glob, re
from os.path import join
import argparse
import numpy as np
import matplotlib.pyplot as plt
from nilearn.image import new_img_like
from pathlib import Path
import nilearn
import pandas as pd
import nibabel as nib
import seaborn as sns
from nilearn import plotting
from nilearn import image
from nilearn import masking
import matplotlib.colors
from rsatoolbox.inference import eval_fixed
from rsatoolbox.model import ModelFixed
from rsatoolbox.rdm import RDMs
from rsatoolbox.util.searchlight import get_volume_searchlight, get_searchlight_RDMs, evaluate_models_searchlight
import rsatoolbox
from scipy.spatial.distance import pdist, squareform


# functions __________________________________________________________________
def upper_tri(RDM):
    """upper_tri returns the upper triangular index of an RDM

    Args:
        RDM 2Darray: squareform RDM

    Returns:
        1D array: upper triangular vector of the RDM
    """
    # returns the upper triangle
    m = RDM.shape[0]
    r, c = np.triu_indices(m, 1)
    return RDM[r, c]


def RDMcolormapObject(direction=1):
    """
    Returns a matplotlib color map object for RSA and brain plotting
    """
    if direction == 0:
        cs = ['yellow', 'red', 'gray', 'turquoise', 'blue']
    elif direction == 1:
        cs = ['blue', 'turquoise', 'gray', 'red', 'yellow']
    else:
        raise ValueError('Direction needs to be 0 or 1')
    cmap = matplotlib.colors.LinearSegmentedColormap.from_list("", cs)
    return cmap

def load_searchlight(singletrial_dir, sub, ses):
    """Load single trial average beta estimates within session

    Args:
        singletrial_dir (str): directory containing single trial beta estimates
        sub (str): BIDS subject id
        ses (str): BIDS session id
        run (str): BIDS run id

    Returns:
        np.array: numpy array of shape num_samples num_labels
    """
    from nilearn import datasets
    from nilearn import masking
    get_shape = glob.glob(join(
            singletrial_dir, sub, f'{sub}_{ses}_*_runtype-*_event-stimulus_trial-*_cuetype-high_stimintensity-high.nii.gz'))
    print(f"get_shape: {get_shape}")
    tmp_img = nib.load(get_shape[0])
    x, y, z = tmp_img.get_fdata().shape
    # arr = np.empty((0, get_shape_data.shape[0]), int)
    arr = np.empty((0, tmp_img.get_fdata().ravel().shape[0]), int)
    # Stimulus trials for the given runtype.
    masklist = []
    for runtype in ['pain', 'cognitive', 'vicarious']:
        run = '*'
        stim_H_cue_H = sorted(glob.glob(join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-high.nii.gz')))
        stim_M_cue_H = sorted(glob.glob(join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-med.nii.gz')))
        stim_L_cue_H = sorted(glob.glob(join( 
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-low.nii.gz')))
        stim_H_cue_L = sorted(glob.glob(join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-high.nii.gz')))
        stim_M_cue_L = sorted(glob.glob(join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-med.nii.gz')))
        stim_L_cue_L = sorted(glob.glob(join(
            singletrial_dir, sub, f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-low.nii.gz')))
        stim_flist = []
        [stim_flist.extend(l) for l in (stim_H_cue_H, stim_M_cue_H,
                           stim_L_cue_H, stim_H_cue_L, stim_M_cue_L, stim_L_cue_L)]

        stim_H_cue_H_mean = image.mean_img(
            image.concat_imgs(stim_H_cue_H)).get_fdata().ravel()
        stim_M_cue_H_mean = image.mean_img(
            image.concat_imgs(stim_M_cue_H)).get_fdata().ravel()
        stim_L_cue_H_mean = image.mean_img(
            image.concat_imgs(stim_L_cue_H)).get_fdata().ravel()
        stim_H_cue_L_mean = image.mean_img(
            image.concat_imgs(stim_H_cue_L)).get_fdata().ravel()
        stim_M_cue_L_mean = image.mean_img(
            image.concat_imgs(stim_M_cue_L)).get_fdata().ravel()
        stim_L_cue_L_mean = image.mean_img(
            image.concat_imgs(stim_L_cue_L)).get_fdata().ravel()
        runwise_array = np.vstack((stim_H_cue_H_mean, stim_M_cue_H_mean, stim_L_cue_H_mean,
                                    stim_H_cue_L_mean, stim_M_cue_L_mean, stim_L_cue_L_mean))
        arr = np.concatenate((arr, runwise_array), axis=0)
        # mask = ~np.isnan(image.load_img(image.concat_imgs([stim_H_cue_H, stim_M_cue_H, stim_L_cue_H,
                                    # stim_H_cue_L, stim_M_cue_L, stim_L_cue_L])).get_fdata())
        masklist.extend([stim_H_cue_H, stim_M_cue_H, stim_L_cue_H,
                                stim_H_cue_L, stim_M_cue_L, stim_L_cue_L])
        # image.concat_imgs([mask, stim_H_cue_H, stim_M_cue_H, stim_L_cue_H,
        #                         stim_H_cue_L, stim_M_cue_L, stim_L_cue_L])
    print(masklist)
    print(len(masklist))
    mask_img = masking.compute_brain_mask(masklist, threshold=.1)
    print(mask_img.get_fdata().shape)
    print(np.sum(~np.isnan(mask_img.get_fdata())))
    return arr, mask_img, x,y,z


def load_expect(data_dir, sub, ses ):
    tasklist = ['pain', 'vicarious', 'cognitive']
    seswise_expect = pd.DataFrame()
    for task in tasklist:
        runwise_df = pd.DataFrame()
        flist = glob.glob(join(data_dir, sub, ses, f"{sub}_{ses}_*{task}_beh.csv"))
        for f in flist: 
            df = pd.read_csv(f)
            df['trial'] = df.index
            df['trial_order'] = df.groupby('param_cond_type', as_index=False)['param_cond_type'].cumcount()
            runwise_df = pd.concat([runwise_df, df])
        # convert run number
        runwise_df['run_order'] = runwise_df['param_run_num'].gt(np.mean(runwise_df['param_run_num']), 0)*1
        seswise_02expect = runwise_df.pivot_table(index=['param_cue_type','param_stimulus_type'], columns=['trial_order', 'run_order'],
                            values=['event02_expect_angle']) #, aggfunc='first')
        seswise_02expect.columns  = [col[0]+'_'+str(col[1]) for col in seswise_02expect.columns.values]
        seswise_02expect = seswise_02expect.reset_index()
        seswise_02expect["condition"] = task + '_' + seswise_02expect['param_cue_type'].astype(str) + '_' + seswise_02expect["param_stimulus_type"]

        # reorder values
        seswise_02expect['stim_order'] = seswise_02expect['param_stimulus_type'].map({'high_cue':0, 'low_cue':1, 'high_stim':0, 'med_stim':1, 'low_stim':2})  
        seswise_02expect['cue_order'] = seswise_02expect['param_cue_type'].map({'high_cue':0, 'low_cue':1, 'high_stim':0, 'med_stim':1, 'low_stim':2})    
        ses_expect = seswise_02expect.sort_values(['cue_order','stim_order'])
        seswise_expect = pd.concat([seswise_expect, ses_expect])
    return(seswise_expect.reset_index(drop = True))


def get_unique_run(sub_id, ses, singletrial_dir):
    """
    Extracts unique values of 'ses' and 'run' from a singletrial nifti file

    Args:
        sub_id (str): BIDS subject
        singletrial_dir (str): path to directory containing the singletrial nifti files

    Returns:
        [type]: set of unique values of ses and run
    """

    flist = glob.glob(
        join(singletrial_dir, sub_id, f"*{ses}*stimulus*trial-000_*.nii.gz")
    )
    # Initialize empty sets to store unique values of 'ses' and 'run'
    # unique_ses = set()
    unique_run = set()

    # Loop through each file path and extract 'ses-##' and 'run-##' using regular expressions
    # Extract ses run and ses.
    for path in flist:
        # Extract 'ses-##' using regular expression
        # ses_match = re.search(r"ses-(\d+)", path)
        # # Add a new session to the unique_ses list
        # if ses_match:
        #     unique_ses.add(ses_match.group(0))

        # Extract 'run-##' using regular expression
        run_match = re.search(r"run-(\d+)", path)
        # Add run_match to unique_run list of run_match. group 0
        if run_match:
            unique_run.add(run_match.group(0))
    return  unique_run


parser = argparse.ArgumentParser()

parser.add_argument("--slurm-id", 
                    type=int, help="slurm id in numbers")
parser.add_argument("--ses", choices=[1, 3, 4],
                    type=int, help="specify session")
parser.add_argument("--radius", 
                    type=int, help="searchlight radius")
args = parser.parse_args()

slurm_id = args.slurm_id # 'ws', 'aa', 'ha_test', 'ha_common'
ses_num = args.ses # 'lh' or 'rh'
radius = args.radius
ses = f'ses-{ses_num:02d}'

# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2]
print(main_dir)
print(args.slurm_id)
slurm_id = args.slurm_id # e.g. 1, 2
singletrial_dir = join(main_dir, 'analysis/fmri/nilearn/singletrial')
sub_folders = next(os.walk(singletrial_dir))[1]
print(sub_folders)
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
sub = sub_list[slurm_id]#f'sub-{sub_list[slurm_id]:04d}'
fmri_event = 'stimulus'
print(f" ________ {sub} {ses} ________")
# nifti_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/'
modelRDM_dir = join(main_dir, 'analysis/fmri/nilearn/rsa/modelrdm')
nifti_dir = join(main_dir, 'analysis/fmri/nilearn/singletrial/')
# save_dir = join(main_dir, 'analysis/fmri/nilearn/rsa/deriv03_searchlight')
save_dir = join(main_dir,'analysis/fmri/nilearn/rsa/deriv03_searchlight', sub)
Path(save_dir).mkdir( parents=True, exist_ok=True )


# fMRI parameters __________________________________________________________________
# set this path to wherever you saved the folder containing the img-files
# flist = glob.glob(join(nifti_dir, sub, f"{sub}_{ses}_*event-stimulus_trial-*.nii.gz"))
arr, mask, x,y,z = load_searchlight(nifti_dir, sub, ses)

# check output __________________________________________________________________
# K = arr*mask.get_fdata().ravel()
# print(f"masked fMRI array shape: {K.shape}")
# print(f"number of non-NaN values in entire fMRI-array: {np.sum(~np.isnan(K))}")
# # apply mask to stacked fMRI data
# # test = mask.get_fdata().ravel() * arr
# print(f"----K----")
# print(f"shape: {K.shape}")
# print(f"any NaNs?: {np.sum(np.isnan(K))}")

# print(f"----mask----")
# print(f"shape: {mask.get_fdata().shape}")
# print(f"any NaNs?: {np.sum(np.isnan(mask.get_fdata()))}")
plotting.plot_stat_map(mask)
plt.savefig(join(save_dir, f"mask_{sub}_{ses}.png"))
plt.close()
imgfname = glob.glob(join(nifti_dir, sub, f'{sub}_{ses}_*_runtype-vicarious_event-{fmri_event}_*_cuetype-low_stimintensity-low.nii.gz'))
ref_img = image.load_img(imgfname[0])
nifti_masker = nilearn.maskers.NiftiMasker(mask_img= mask,
                                           
                            target_affine = ref_img.affine, target_shape = ref_img.shape, 
                    memory="nilearn_cache", memory_level=1)

singlemasked = []
for index in range(arr.shape[0]):
    singlemasked.append(
        nifti_masker.fit_transform(
    new_img_like(ref_img, arr[index].reshape(x,y,z)))
    )
fmri_masked_single = np.vstack(singlemasked)


# Step 0: convert masked array back into brain 3d
masked_arr = nifti_masker.inverse_transform(fmri_masked_single)
img = new_img_like(ref_img, masked_arr.get_fdata()[..., 0])
plotting.plot_stat_map(img)
plt.savefig(join(save_dir, f"maskedimage_{sub}_{ses}.png"))
plt.close()
# %% Step 1: Get searchlight centers and neighbors ____________________________________________
centers, neighbors = get_volume_searchlight(nifti_masker.mask_img.get_fdata(), radius=2, threshold=0.5)
# # %% Step 2: Get an RDM for each voxel¶
image_value = np.arange(masked_arr.shape[-1])
reshaped_array = np.reshape(masked_arr.get_fdata(), (-1, masked_arr.shape[3]))
data_2d = reshaped_array.T #masked_arr.reshape([masked_arr.shape[0], -1])
data_2d_nan = np.nan_to_num(data_2d)
SL_RDM = get_searchlight_RDMs(data_2d_nan, centers, neighbors, image_value, method='correlation') # Get RDMs

print(f"voxel indices: {SL_RDM.rdm_descriptors['voxel_index'].shape}")
print(f"number of nans?: {np.sum(np.isnan(SL_RDM.dissimilarities))}")
print(f"number of nan in mask? {np.sum(np.isnan(mask.get_fdata()))}")
print(f"centers shape: {centers.shape}")
print(f"searchlight RDM shape: {SL_RDM.dissimilarities.shape}")


# %% Step 3: Load animal model and evaluate
# model_grid ________________________________________________________________________________
modelRDM_dir = join(main_dir,'analysis', 'fmri', 'nilearn', 'rsa', 'modelrdm')
cue_RDM = np.load(join(modelRDM_dir, 'model-cue.npy'))
stim_RDM = np.load(join(modelRDM_dir, 'model-stim.npy'))
grid_RDM = np.load(join(modelRDM_dir, 'model-grid.npy'))
orthogonal_RDM = np.load(join(modelRDM_dir, 'model-orthogonal.npy'))
rotationgrid_RDM = np.load(join(modelRDM_dir, 'model-rotationgrid.npy'))
parallel_RDM = np.load(join(modelRDM_dir, 'model-parallel.npy'))
diagonal_RDM = np.load(join(modelRDM_dir, 'model-diagonal.npy'))

# essential
SL_RDM.dissimilarities[np.isnan(SL_RDM.dissimilarities)] = 0

X = [rsatoolbox.model.ModelWeighted('cue', upper_tri(cue_RDM)),
     rsatoolbox.model.ModelWeighted('stim', upper_tri(stim_RDM)),
     rsatoolbox.model.ModelWeighted('grid', upper_tri(grid_RDM)),
     rsatoolbox.model.ModelWeighted('orthogonal', upper_tri(orthogonal_RDM)),
     rsatoolbox.model.ModelWeighted('rotationgrid', upper_tri(rotationgrid_RDM)),
     rsatoolbox.model.ModelWeighted('parallel', upper_tri(parallel_RDM)),
     rsatoolbox.model.ModelWeighted('diagonal', upper_tri(diagonal_RDM))]
model_names = ['cue', 'stim', 'grid', 'orthogonal', 'rotationgrid',  'parallel', 'diagonal']   
eval_results = evaluate_models_searchlight(SL_RDM, X, eval_fixed, method='spearman', n_jobs=3)
# TODO: sklearn linear regression and dot fit. dot coef. fit intercept
# SL_RDM and X. zscore and rank. standardized rank regression



# %%
df = pd.DataFrame(index=range(len(X)), columns=range(len(eval_results)))
for i, e in enumerate(eval_results):
    df.iloc[:,i] = e.evaluations[0]

# %% Create an 3D array, with the size of mask, and
for model_i, model_name in enumerate(model_names):
    x, y, z = mask.shape
    RDM_brain = np.zeros([x * y * z])
    RDM_brain[list(SL_RDM.rdm_descriptors['voxel_index'])] = df.T[model_i].tolist()
    RDM_brain = RDM_brain.reshape([x, y, z])

    sns.distplot(df.T[model_i].tolist())
    plt.title(f'Distributions of correlations {model_name}', size=18)
    plt.ylabel('Occurrence', size=18)
    plt.xlabel('Spearman correlation', size=18)
    sns.despine()
    
    # Save the distribution plot
    plt.savefig(join(save_dir, f'searchlist-hist_{sub}_{ses}_model-{model_name}.png'))
    plt.close()
    
    threshold = np.percentile(df.T[model_i].tolist(), 99)
    plot_img = new_img_like(mask, RDM_brain)
    plot_img.to_filename(join(save_dir, f"searchlight_{sub}_{ses}_model-{model_name}.nii.gz"))
    cmap = RDMcolormapObject()

    coords = range(-20, 40, 5)
    fig = plt.figure(figsize=(12, 3))

    display = plotting.plot_stat_map(
        plot_img, colorbar=True, threshold=threshold,
        display_mode='mosaic', draw_cross=False, figure=fig,
        title=f'{model_name}', cmap=cmap,
        black_bg=False, annotate=False)
    
    # Save the statistical map plot
    plt.savefig(join(save_dir, f'searchlight_thres-99_{sub}_{ses}_model-{model_name}.png'))
    plt.close()

# eval_results = evaluate_models_searchlight(SL_RDM, X, eval_fixed, method='spearman', n_jobs=3)
results_1 = rsatoolbox.inference.eval_fixed(X, SL_RDM, method='corr')
rsatoolbox.vis.plot_model_comparison(results_1)

