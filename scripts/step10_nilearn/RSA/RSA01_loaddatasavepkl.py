#!/usr/bin/env python
"""
Converts fMRI data into RDM objects, saved in pkl, 
Saved per sub/ses/run.
Loads behavioral and fMRI data

Returns:
    [type]: [description]
"""
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
import argparse
import matplotlib.cm

cmap = matplotlib.cm.get_cmap("Reds")


# sys.path.append(
#    '/Users/h/anaconda3/envs/spacetop_datalad/lib/python3.9/site-packages')


def load_expect(data_dir, sub, ses):
    """
    Extracts metadata from behavioral files. 
    Later used for harmonizing singletrials fMRI data
    Args:
        data_dir (str): where behavioral data lives
        sub (str): BIDS subject key
        ses (str): BIDS session key

    Returns:
        seswise_expect (pd.DataFrame): returns a pandas dataframe
    """
    tasklist = ["pain", "vicarious", "cognitive"]
    seswise_expect = pd.DataFrame()
    for task in tasklist:
        runwise_df = pd.DataFrame()
        flist = glob.glob(
            os.path.join(data_dir, sub, ses, f"{sub}_{ses}_*{task}_beh.csv")
        )
        for f in flist:
            df = pd.read_csv(f)
            df["trial"] = df.index
            df["trial_order"] = df.groupby("param_cond_type", as_index=False)[
                "param_cond_type"
            ].cumcount()
            runwise_df = pd.concat([runwise_df, df])
        # convert run number
        runwise_df["run_order"] = (
            runwise_df["param_run_num"].gt(np.mean(runwise_df["param_run_num"]), 0) * 1
        )
        seswise_02expect = runwise_df.pivot_table(
            index=["param_cue_type", "param_stimulus_type"],
            columns=["trial_order", "run_order"],
            values=["event02_expect_angle"],
        )  # , aggfunc='first')
        seswise_02expect.columns = [
            col[0] + "_" + str(col[1]) for col in seswise_02expect.columns.values
        ]
        seswise_02expect = seswise_02expect.reset_index()
        seswise_02expect["condition"] = (
            task
            + "_"
            + seswise_02expect["param_cue_type"].astype(str)
            + "_"
            + seswise_02expect["param_stimulus_type"]
        )

        # reorder values
        seswise_02expect["stim_order"] = seswise_02expect["param_stimulus_type"].map(
            {"high_cue": 0, "low_cue": 1, "high_stim": 0, "med_stim": 1, "low_stim": 2}
        )
        seswise_02expect["cue_order"] = seswise_02expect["param_cue_type"].map(
            {"high_cue": 0, "low_cue": 1, "high_stim": 0, "med_stim": 1, "low_stim": 2}
        )
        ses_expect = seswise_02expect.sort_values(["cue_order", "stim_order"])
        seswise_expect = pd.concat([seswise_expect, ses_expect])
    return seswise_expect.reset_index(drop=True)


def load_outcome(data_dir, sub, ses):
    """
    Loads data to be used in BIDS. This is a function that takes as input a directory of behavioral data and a subject and session.

    Args:
        data_dir (str): where behavioral data lives
        sub (str): BIDS subject key
        ses (str): BIDS session key

    Returns:
        seswise_outcome (pd.DataFrame): [description]
    """
    tasklist = ["pain", "vicarious", "cognitive"]
    seswise_outcome = pd.DataFrame()
    for task in tasklist:
        runwise_df = pd.DataFrame()
        flist = glob.glob(
            os.path.join(data_dir, sub, ses, f"{sub}_{ses}_*{task}_beh.csv")
        )
        # This function reads the trials and trial_order columns from the list of csv files and returns a dataframe with the trial and trial_order columns.
        for f in flist:
            df = pd.read_csv(f)
            df["trial"] = df.index
            df["trial_order"] = df.groupby("param_cond_type", as_index=False)[
                "param_cond_type"
            ].cumcount()
            runwise_df = pd.concat([runwise_df, df])
        # convert run number
        runwise_df["run_order"] = (
            runwise_df["param_run_num"].gt(np.mean(runwise_df["param_run_num"]), 0) * 1
        )
        seswise_04outcome = runwise_df.pivot_table(
            index=["param_cue_type", "param_stimulus_type"],
            columns=["trial_order", "run_order"],
            values=["event04_actual_angle"],
        )
        seswise_04outcome.columns = [
            col[0] + "_" + str(col[1]) for col in seswise_04outcome.columns.values
        ]
        seswise_04outcome = seswise_04outcome.reset_index()
        seswise_04outcome["condition"] = (
            task
            + "_"
            + seswise_04outcome["param_cue_type"].astype(str)
            + "_"
            + seswise_04outcome["param_stimulus_type"]
        )

        # reorder values
        seswise_04outcome["stim_order"] = seswise_04outcome["param_stimulus_type"].map(
            {"high_cue": 0, "low_cue": 1, "high_stim": 0, "med_stim": 1, "low_stim": 2}
        )
        seswise_04outcome["cue_order"] = seswise_04outcome["param_cue_type"].map(
            {"high_cue": 0, "low_cue": 1, "high_stim": 0, "med_stim": 1, "low_stim": 2}
        )
        ses_outcome = seswise_04outcome.sort_values(["cue_order", "stim_order"])
        seswise_outcome = pd.concat([seswise_outcome, ses_outcome])
    return seswise_outcome.reset_index(drop=True)


def load_fmri(singletrial_dir, sub, ses, run, atlas):
    """Load single trial average beta estimates within session

    Args:
        singletrial_dir (str): directory containing single trial beta estimates
        sub (str): BIDS subject id
        ses (str): BIDS session id
        run (str): BIDS run id
        atlas (str): flag to use atlas or not

    Returns:
        np.array: numpy array of shape num_samples num_labels
    """

    from nilearn import datasets
    from nilearn.maskers import NiftiLabelsMasker

    dataset = datasets.fetch_atlas_schaefer_2018()
    atlas_filename = dataset.maps
    labels = np.insert(dataset.labels, 0, "Background")
    masker = NiftiLabelsMasker(
        labels_img=atlas_filename, standardize=True, memory="nilearn_cache", verbose=5
    )
    # Returns an array of the data in the atlas dataset.
    if atlas == True:
        arr = np.empty((0, len(dataset["labels"])), int)
    elif atlas == False:
        get_shape = glob.glob(
            os.path.join(
                singletrial_dir,
                sub,
                f"{sub}_{ses}_run-01_runtype-*_event-stimulus_trial-*_cuetype-high_stimintensity-high.nii.gz",
            )
        )
        get_shape_data = (
            image.mean_img(image.concat_imgs(get_shape)).get_fdata().ravel()
        )
        arr = np.empty((0, get_shape_data.shape[0]), int)

    # Stimulus trials for the given runtype.
    for runtype in ["pain", "cognitive", "vicarious"]:
        stim_H_cue_H = sorted(
            glob.glob(
                os.path.join(
                    singletrial_dir,
                    sub,
                    f"{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-high.nii.gz",
                )
            )
        )
        stim_M_cue_H = sorted(
            glob.glob(
                os.path.join(
                    singletrial_dir,
                    sub,
                    f"{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-med.nii.gz",
                )
            )
        )
        stim_L_cue_H = sorted(
            glob.glob(
                os.path.join(
                    singletrial_dir,
                    sub,
                    f"{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-high_stimintensity-low.nii.gz",
                )
            )
        )
        stim_H_cue_L = sorted(
            glob.glob(
                os.path.join(
                    singletrial_dir,
                    sub,
                    f"{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-high.nii.gz",
                )
            )
        )
        stim_M_cue_L = sorted(
            glob.glob(
                os.path.join(
                    singletrial_dir,
                    sub,
                    f"{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-med.nii.gz",
                )
            )
        )
        stim_L_cue_L = sorted(
            glob.glob(
                os.path.join(
                    singletrial_dir,
                    sub,
                    f"{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-*_cuetype-low_stimintensity-low.nii.gz",
                )
            )
        )
        stim_flist = []
        [
            stim_flist.extend(l)
            for l in (
                stim_H_cue_H,
                stim_M_cue_H,
                stim_L_cue_H,
                stim_H_cue_L,
                stim_M_cue_L,
                stim_L_cue_L,
            )
        ]

        # The atlas atlas is true or False.
        if atlas == True:
            stim_H_cue_H_mean = image.mean_img(image.concat_imgs(stim_H_cue_H))
            stim_M_cue_H_mean = image.mean_img(image.concat_imgs(stim_M_cue_H))
            stim_L_cue_H_mean = image.mean_img(image.concat_imgs(stim_L_cue_H))
            stim_H_cue_L_mean = image.mean_img(image.concat_imgs(stim_H_cue_L))
            stim_M_cue_L_mean = image.mean_img(image.concat_imgs(stim_M_cue_L))
            stim_L_cue_L_mean = image.mean_img(image.concat_imgs(stim_L_cue_L))
            runwise_array = masker.fit_transform(
                image.concat_imgs(
                    [
                        stim_H_cue_H_mean,
                        stim_M_cue_H_mean,
                        stim_L_cue_H_mean,
                        stim_H_cue_L_mean,
                        stim_M_cue_L_mean,
                        stim_L_cue_L_mean,
                    ]
                )
            )  # (trials, parcels)
            arr = np.concatenate((arr, runwise_array), axis=0)

        elif atlas == False:
            stim_H_cue_H_mean = (
                image.mean_img(image.concat_imgs(stim_H_cue_H)).get_fdata().ravel()
            )
            stim_M_cue_H_mean = (
                image.mean_img(image.concat_imgs(stim_M_cue_H)).get_fdata().ravel()
            )
            stim_L_cue_H_mean = (
                image.mean_img(image.concat_imgs(stim_L_cue_H)).get_fdata().ravel()
            )
            stim_H_cue_L_mean = (
                image.mean_img(image.concat_imgs(stim_H_cue_L)).get_fdata().ravel()
            )
            stim_M_cue_L_mean = (
                image.mean_img(image.concat_imgs(stim_M_cue_L)).get_fdata().ravel()
            )
            stim_L_cue_L_mean = (
                image.mean_img(image.concat_imgs(stim_L_cue_L)).get_fdata().ravel()
            )
            runwise_array = np.vstack(
                (
                    stim_H_cue_H_mean,
                    stim_M_cue_H_mean,
                    stim_L_cue_H_mean,
                    stim_H_cue_L_mean,
                    stim_M_cue_L_mean,
                    stim_L_cue_L_mean,
                )
            )
            arr = np.concatenate((arr, runwise_array), axis=0)
        mask = ~np.isnan(image.load_img(image.concat_imgs(stim_H_cue_H)).get_fdata())
    return (mask, arr, stim_flist)


def upper_tri(RDM):
    """
    upper_tri returns the upper triangular index of an RDM

    Args:
        RDM (2Darray): squareform RDM

    Returns:
        1D array: upper triangular vector of the RDM
    """
    # returns the upper triangle
    m = RDM.shape[0]
    r, c = np.triu_indices(m, 1)
    return RDM[r, c]


def get_unique_ses(sub_id, singletrial_dir):
    """
    Extracts unique values of 'ses' and 'run' from a singletrial nifti file

    Args:
        sub_id (str): BIDS subject
        singletrial_dir (str): path to directory containing the singletrial nifti files

    Returns:
        [type]: set of unique values of ses and run
    """

    flist = glob.glob(
        os.path.join(singletrial_dir, sub_id, "*stimulus*trial-000_*.nii.gz")
    )
    # Initialize empty sets to store unique values of 'ses' and 'run'
    unique_ses = set()
    unique_run = set()

    # Loop through each file path and extract 'ses-##' and 'run-##' using regular expressions
    # Extract ses run and ses.
    for path in flist:
        # Extract 'ses-##' using regular expression
        ses_match = re.search(r"ses-(\d+)", path)
        # Add a new session to the unique_ses list
        if ses_match:
            unique_ses.add(ses_match.group(0))

        # Extract 'run-##' using regular expression
        run_match = re.search(r"run-(\d+)", path)
        # Add run_match to unique_run list of run_match. group 0
        if run_match:
            unique_run.add(run_match.group(0))
    return unique_ses


# 0. argparse ________________________________________________________________________________
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int, help="specify slurm array id")
args = parser.parse_args()

# 0. parameters ________________________________________________________________________________
print(args.slurm_id)
slurm_id = args.slurm_id  # e.g. 1, 2
singletrial_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial"
sub_folders = next(os.walk(singletrial_dir))[1]
print(sub_folders)
sub_list = [i for i in sorted(sub_folders) if i.startswith("sub-")]
sub = sub_list[slurm_id]  # f'sub-{sub_list[slurm_id]:04d}'
print(f" ________ {sub} ________")

# concatenate runs ________________________________________________________________________________
beh_expect = []
beh_outcome = []
fmri_data = []
# pkl_savedir = "/Volumes/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/rsa/deriv01_rdmpkl"
pkl_savedir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/rsa/deriv01_rdmpkl"
beh_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh/beh02_preproc"
ses_list = get_unique_ses(sub_id=sub, singletrial_dir=singletrial_dir)
for ses in ses_list:
    des = {"session": ses, "subj": sub}
    # load behavioral data expectation rating
    expect_df = pd.DataFrame()
    expect_df = load_expect(data_dir=beh_dir, sub=sub, ses=ses)
    # load fMRI data
    mask, fmri_df, stim_flist = load_fmri(
        singletrial_dir=singletrial_dir, sub=sub, ses=ses, run="*", atlas=True
    )
    obs_des = {"pattern": np.array(expect_df.condition)}
    rsd_data = rsatoolbox.data.Dataset(
        measurements=fmri_df,
        descriptors=des,
        obs_descriptors=obs_des,
        channel_descriptors={
            "roi": np.array(["roi_" + str(x) for x in np.arange(fmri_df.shape[1])])
        },
    )
    fmri_data.append(rsd_data)
    pathlib.Path(os.path.join(pkl_savedir, sub)).mkdir(parents=True, exist_ok=True)
    rsd_data.save(
        filename=os.path.join(pkl_savedir, sub, f"{sub}_{ses}_rsadata.pkl"),
        file_type="pkl",
        overwrite=True,
    )
