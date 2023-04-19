# load data and save as pkl
# %%
import math
from scipy.spatial.distance import pdist, squareform
from matplotlib.colors import LinearSegmentedColormap
from rsatoolbox.inference import eval_fixed
from rsatoolbox.model import ModelFixed
import rsatoolbox.rdm as rsr
import rsatoolbox.data as rsd
import rsatoolbox
import os
import sys
import glob
import re
from nilearn import image
from nilearn import plotting
import numpy as np
import pandas as pd
import h5py
import pathlib
from scipy import io
import matplotlib.pyplot as plt
import matplotlib.cm
cmap = matplotlib.cm.get_cmap('Reds')

%matplotlib inline

sys.path.append(
    '/Users/h/anaconda3/envs/spacetop_datalad/lib/python3.9/site-packages')


def load_expect(data_dir, sub, ses):
    tasklist = ['pain', 'vicarious', 'cognitive']
    seswise_expect = pd.DataFrame()
    for task in tasklist:
        runwise_df = pd.DataFrame()
        flist = glob.glob(os.path.join(data_dir, sub, ses,
                          f"{sub}_{ses}_*{task}_beh.csv"))
        for f in flist:
            df = pd.read_csv(f)
            df['trial'] = df.index
            df['trial_order'] = df.groupby('param_cond_type', as_index=False)[
                                           'param_cond_type'].cumcount()
            runwise_df = pd.concat([runwise_df, df])
        # convert run number
        runwise_df['run_order'] = runwise_df['param_run_num'].gt(
            np.mean(runwise_df['param_run_num']), 0)*1
        seswise_02expect = runwise_df.pivot_table(index=['param_cue_type', 'param_stimulus_type'], columns=['trial_order', 'run_order'],
                            values=['event02_expect_angle'])  # , aggfunc='first')
        seswise_02expect.columns = [
            col[0]+'_'+str(col[1]) for col in seswise_02expect.columns.values]
        seswise_02expect = seswise_02expect.reset_index()
        seswise_02expect["condition"] = task + '_' + seswise_02expect['param_cue_type'].astype(
            str) + '_' + seswise_02expect["param_stimulus_type"]

        # reorder values
        seswise_02expect['stim_order'] = seswise_02expect['param_stimulus_type'].map(
            {'high_cue': 0, 'low_cue': 1, 'high_stim': 0, 'med_stim': 1, 'low_stim': 2})
        seswise_02expect['cue_order'] = seswise_02expect['param_cue_type'].map(
            {'high_cue': 0, 'low_cue': 1, 'high_stim': 0, 'med_stim': 1, 'low_stim': 2})
        ses_expect = seswise_02expect.sort_values(['cue_order', 'stim_order'])
        seswise_expect = pd.concat([seswise_expect, ses_expect])
    return (seswise_expect.reset_index(drop=True))


def load_outcome(data_dir, sub, ses):
    tasklist = ['pain', 'vicarious', 'cognitive']
    seswise_outcome = pd.DataFrame()
    for task in tasklist:
        runwise_df = pd.DataFrame()
        flist = glob.glob(os.path.join(data_dir, sub, ses,
                          f"{sub}_{ses}_*{task}_beh.csv"))
        for f in flist:
            df = pd.read_csv(f)
            df['trial'] = df.index
            df['trial_order'] = df.groupby('param_cond_type', as_index=False)[
                                           'param_cond_type'].cumcount()
            runwise_df = pd.concat([runwise_df, df])
        # convert run number
        runwise_df['run_order'] = runwise_df['param_run_num'].gt(
            np.mean(runwise_df['param_run_num']), 0)*1
        seswise_04outcome = runwise_df.pivot_table(index=['param_cue_type', 'param_stimulus_type'], columns=['trial_order', 'run_order'],
                            values=['event04_actual_angle'])  # , aggfunc='first')
        seswise_04outcome.columns = [
            col[0]+'_'+str(col[1]) for col in seswise_04outcome.columns.values]
        seswise_04outcome = seswise_04outcome.reset_index()
        seswise_04outcome["condition"] = task + '_' + seswise_04outcome['param_cue_type'].astype(
            str) + '_' + seswise_04outcome["param_stimulus_type"]

        # reorder values
        seswise_04outcome['stim_order'] = seswise_04outcome['param_stimulus_type'].map(
            {'high_cue': 0, 'low_cue': 1, 'high_stim': 0, 'med_stim': 1, 'low_stim': 2})
        seswise_04outcome['cue_order'] = seswise_04outcome['param_cue_type'].map(
            {'high_cue': 0, 'low_cue': 1, 'high_stim': 0, 'med_stim': 1, 'low_stim': 2})
        ses_outcome = seswise_04outcome.sort_values(
            ['cue_order', 'stim_order'])
        seswise_outcome = pd.concat([seswise_outcome, ses_outcome])
    return (seswise_outcome.reset_index(drop=True))


def load_fmri(singletrial_dir, sub, ses, run, atlas):
    from nilearn import datasets
    from nilearn.maskers import NiftiLabelsMasker
    dataset = datasets.fetch_atlas_schaefer_2018()
    atlas_filename = dataset.maps
    # labels = dataset.labels
    labels = np.insert(dataset.labels, 0, 'Background')
    masker = NiftiLabelsMasker(labels_img=atlas_filename, standardize=True,
                            memory='nilearn_cache', verbose=5)
    if atlas == True:
        arr = np.empty((0, len(dataset['labels'])), int)
    elif atlas == False:
        get_shape = glob.glob(os.path.join(
                singletrial_dir, sub, f'{sub}_{ses}_run-01_runtype-*_event-stimulus_trial-*_cuetype-high_stimintensity-high.nii.gz'))
        get_shape_data = image.mean_img(
            image.concat_imgs(get_shape)).get_fdata().ravel()
        arr = np.empty((0, get_shape_data.shape[0]), int)
    # task_array = np.empty((18,0), int)

    for runtype in ['pain', 'cognitive', 'vicarious']:
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
        [stim_flist.extend(l) for l in (stim_H_cue_H, stim_M_cue_H,
                           stim_L_cue_H, stim_H_cue_L, stim_M_cue_L, stim_L_cue_L)]

        # task_array = np.vstack((task_array, runwise_array))
        # arr = np.append(arr, runwise_array, axis=0)
        if atlas == True:
            stim_H_cue_H_mean = image.mean_img(image.concat_imgs(stim_H_cue_H))
            stim_M_cue_H_mean = image.mean_img(image.concat_imgs(stim_M_cue_H))
            stim_L_cue_H_mean = image.mean_img(image.concat_imgs(stim_L_cue_H))
            stim_H_cue_L_mean = image.mean_img(image.concat_imgs(stim_H_cue_L))
            stim_M_cue_L_mean = image.mean_img(image.concat_imgs(stim_M_cue_L))
            stim_L_cue_L_mean = image.mean_img(image.concat_imgs(stim_L_cue_L))
            runwise_array = masker.fit_transform(image.concat_imgs([stim_H_cue_H_mean,
                                                          stim_M_cue_H_mean,
                                                          stim_L_cue_H_mean,
                                                          stim_H_cue_L_mean,
                                                          stim_M_cue_L_mean,
                                                          stim_L_cue_L_mean
                                                           ]))  # (trials, parcels)
            arr = np.concatenate((arr, runwise_array), axis=0)
    # np.vstack((arr, runwise_array))
        elif atlas == False:
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
        mask = ~np.isnan(image.load_img(
            image.concat_imgs(stim_H_cue_H)).get_fdata())
    return (mask, arr, stim_flist)


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


def get_unique_ses(sub_id, singletrial_dir):

    flist = glob.glob(os.path.join(singletrial_dir, sub_id,
                      '*stimulus*trial-000_*.nii.gz'))
    # Initialize empty sets to store unique values of 'ses' and 'run'
    unique_ses = set()
    unique_run = set()

    # Loop through each file path and extract 'ses-##' and 'run-##' using regular expressions
    for path in flist:
        # Extract 'ses-##' using regular expression
        ses_match = re.search(r'ses-(\d+)', path)
        if ses_match:
            unique_ses.add(ses_match.group(0))

        # Extract 'run-##' using regular expression
        run_match = re.search(r'run-(\d+)', path)
        if run_match:
            unique_run.add(run_match.group(0))
    # for run in sorted(unique_run):
    #     print(run)
    return unique_ses


# load brain data
# sub_list = ["sub-0003", "sub-0004", "sub-0005", "sub-0006", "sub-0009",    "sub-0010",    "sub-0018",    "sub-0025",    "sub-0029",    "sub-0031",    "sub-0032",    "sub-0033",    "sub-0034",    "sub-0036",    "sub-0037",    "sub-0038",    "sub-0039",    "sub-0043",    "sub-0044",    "sub-0046",    "sub-0050",    "sub-0051",    "sub-0052",    "sub-0053",    "sub-0055",    "sub-0056",    "sub-0057",    "sub-0058",    "sub-0060",    "sub-0061",    "sub-0062",    "sub-0065",    "sub-0073",
    "sub-0078",    "sub-0080",    "sub-0081",    "sub-0086",    "sub-0087",    "sub-0090",    "sub-0091",    "sub-0092",    "sub-0093",    "sub-0094",    "sub-0095",    "sub-0098",    "sub-0099",    "sub-0100",    "sub-0101",    "sub-0102",    "sub-0104",    "sub-0105",    "sub-0106",    "sub-0107",    "sub-0109",    "sub-0115",    "sub-0116",    "sub-0122",    "sub-0124",    "sub-0126",    "sub-0127",    "sub-0128",    "sub-0129",    "sub-0130",    "sub-0132",    "sub-0133"]


# sub_list = [ "sub-0078",    "sub-0080",    "sub-0081",    "sub-0086",    "sub-0087",    "sub-0090"]
# sub_list = ['sub-0061']
sub_list= ["sub-0080"]
beh_expect = []
beh_outcome = []
fmri_data = []
pkl_savedir = "/Volumes/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_rdmpkl"
for sub in sub_list:
    singletrial_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/singletrial/'
    beh_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/beh/beh02_preproc/'
    ses_list = get_unique_ses(sub_id = sub, singletrial_dir=singletrial_dir)
    for ses in ses_list:
        des = {'session': ses, 'subj': sub}
        # load behavioral data expectation rating
        expect_df = pd.DataFrame()
        expect_df = load_expect(data_dir=beh_dir,
                                sub = sub, ses = ses)
        # load fMRI data
        mask, fmri_df, stim_flist=load_fmri(singletrial_dir = singletrial_dir,
                                              sub = sub, ses = ses, run = '*', atlas = True)
        obs_des={'pattern': np.array(expect_df.condition)}
        rsd_data=rsatoolbox.data.Dataset(
            measurements=fmri_df,
            descriptors=des,
            obs_descriptors=obs_des,
            channel_descriptors={'roi': np.array(['roi_' + str(x) for x in np.arange(fmri_df.shape[1])])})
        fmri_data.append(rsd_data)
        pathlib.Path(os.path.join(pkl_savedir, sub)).mkdir(parents = True, exist_ok = True)
        rsd_data.save(filename = os.path.join(pkl_savedir, sub, f"{sub}_{ses}_rsadata.pkl"), 
                      file_type = 'pkl', overwrite = True)


