#!/usr/bin/env python
# encoding: utf-8
# %% libraries ________________________________________________________________________
import pandas as pd
import os, re
import glob
from os.path import join
import pdb
from pathlib import Path
import itertools
import numpy as np

# from utils import _build_evfile
"""
onset01_extract_three_column.py
# get behavioral files from "d02_preproc-beh"
# subtract from trigger onset
# extract regressors:
# extract task name:
TODO: run on discovery and extract all o0nsets
"""
# __author__ = "Heejung Jung"
# __version__ = "1.0.1"
# __email__ = "heejung.jung@colorado.edu"
# __status__ = "Production"


# %% functions ____
def _build_evfile(df, onset_col, dur_col, mod_col, fname, **dict_map):
    """Creates a 3-column EV txt file for FSL, by combining behavioral and biopac data
    Args:
        df (dataframe):
                merged dataframe with behavioral biopac data
        onset_col (str):
                column name from original dataframe
        dur_col (str or float):
                if string, adds dataframe columns as list; else, add number
        mod_col (str or int):
                if str, following argument holds dictionary.
                Use dictionary to map contrast values.
                else if int, insert directly to dataframe
    Returns:
        new_df (pandas dataframe): saved within function
    """
    new_df = pd.DataFrame()
    # NumberTypes = (types.IntType, types.LongType, types.FloatType, types.ComplexType)
    new_df["onset"] = df[onset_col]
    if isinstance(dur_col, str):
        new_df["dur"] = df[dur_col]
    elif isinstance(dur_col, (int, float, complex)):
        new_df["dur"] = dur_col
    if isinstance(mod_col, str):
        if dict_map:
            new_df["mod"] = df[mod_col].map(dict_map["dict_map"])
        else:
            new_df["mod"] = df[mod_col]
    else:
        new_df["mod"] = mod_col
    new_df.to_csv(fname, header=None, index=None, sep="\t")


def sublist(source_dir: str, remove_int: list,  sub_zeropad: int) -> list:
    """
    Create a subject list based on exclusion criterion.
    Also, restricts the job to number of batches, based on slurm_ind and stride

    Parameters
    ----------
    source_dir: str
        path where the physio data lives
    remove_int: list
        list of numbers (subjuct numbers) to remove
        e.g. [1, 2, 3, 120]
    slurm_ind: int
        number to indicate index of when batch begins
        if running code via SLURM, slurm_ind is a parameter from slurm array
    stride: int
        default 10
        based on slurm_ind, we're going to run "stride" number of participants at once
    sub_zeropad: int
        number of zeropadding that you add to your subject id
        e.g. sub-0004 > sub_zeropad = 4
             sub-000128 > sub_zeropad = 6

    Returns
    -------
    sub_list: list
        a list of subject ids to operate on

    TODO: allow for user to indicate how much depth to go down
    or, just do glob with matching pattern?
    """
    folder_list = [f.name for f in os.scandir(
        join(source_dir)) if f.is_dir() and 'sub-' in f.name]
    #biopac_list = next(os.walk(join(source_dir)))[2]
    remove_list = [f"sub-{x:0{sub_zeropad}d}" for x in remove_int]
    # include_int = list(np.arange(slurm_id * stride + 1, (slurm_id + 1) * stride, 1))
    # include_list = [f"sub-{x:0{sub_zeropad}d}" for x in include_int]
    sub_list = [x for x in folder_list if x not in remove_list]
    # sub_list = [x for x in sub_list if x in include_list]
    return sorted(sub_list)


def check_run_type(beh_fname: str):
    run_type = ([match for match in os.path.basename(
        beh_fname).split('_') if "run" in match][0]).split('-')[2]
    return run_type


def extract_bids_num(filename: str, key: str) -> int:
    """
    Extracts BIDS information based on input "key" prefix.
    If filename includes an extention, code will remove it.

    Parameters
    ----------
    filename: str
        acquisition filename
    key: str
        BIDS prefix, such as 'sub', 'ses', 'task'
    """
    bids_info = [match for match in filename.split('_') if key in match][0]
    # bids_info_rmext = os.path.splitext(bids_info)[0]
    bids_info_rmext = bids_info.split(os.extsep, 1)
    bids_num = int(re.findall(r'\d+', bids_info_rmext[0])[0].lstrip('0'))
    return bids_num


# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
# discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
main_dir = Path(current_dir).parents[1]
print(main_dir)
# main_dir = '/Volumes/spacetop_projects_social'
# beh_dir = os.path.join(main_dir, 'data', 'd02_preproc-beh')
# fsl_dir = os.path.join(main_dir, 'data', 'd03_onset', 'onset01_FSL')
# spm_dir = os.path.join(main_dir, 'data', 'd03_onset', 'onset02_SPM')
beh_dir = join(main_dir, 'data', 'beh', 'beh02_preproc')
fsl_dir = join(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset01_FSL')
spm_dir = join(main_dir, 'data', 'fmri', 'fmri01_onset', 'onset02_SPM')
single_dir = join(main_dir, 'data', 'fmri', 'fmri01_onset',
                  'onset03_SPMsingletrial_24dof')
# %%
# e.g. sub_list = [2,3,4,5,6,7,8,9,10,...]
sub_folders = next(os.walk(beh_dir))[1]
sub_list = [i for i in sub_folders if i.startswith('sub-')]
items_to_remove = ['sub-0001']
for item in items_to_remove:
    if item in sub_list:
        sub_list.remove(item)
sub_list = sublist(source_dir=beh_dir, remove_int=[1], sub_zeropad=4)
ses_list = [1, 3, 4]
sub_ses = list(itertools.product(sorted(sub_list), ses_list))
for i, (sub, ses_ind) in enumerate(sub_ses):

    ses = "ses-{:02d}".format(ses_ind)
    print(f"______________ {sub} {ses}______________")
    beh_list = glob.glob(os.path.join(beh_dir, sub, ses, "*_beh.csv"))
    Path(os.path.join(fsl_dir, sub, ses)).mkdir(parents=True, exist_ok=True)
    Path(os.path.join(spm_dir, sub, ses)).mkdir(parents=True, exist_ok=True)

    # FILENAME = os.path.join(beh_dir, sub, ses, 'sub-' + 'ses-' + 'task-*' + 'run-*' )
    for ind, fpath in enumerate(beh_list):
        fname = os.path.basename(fpath)
        tasktype = fname.split("_")[2]
        # runtype = fname.split("_")[3]
        runnum = extract_bids_num(fname, 'run')
        runtype = check_run_type(fname)

        label = "_".join(fname.split("_")[0:4])

        df = pd.read_csv(fpath)

        # dictionary:
        dict_cue = {"low_cue": -1, "high_cue": 1}
        dict_stim = {"low_stim": -1, "med_stim": 0, "high_stim": 1}
        dict_stim_q = {"low_stim": 1, "med_stim": -2, "high_stim": 1}
        dict_col = {
            "event01_cue_onset": "onset01_cue",
            "event02_expect_displayonset": "onset02_ratingexpect",
            "event03_stimulus_displayonset": "onset03_stim",
            "event04_actual_displayonset": "onset04_ratingactual",
            "param_cue_type": "pmod_cue_type",
            "param_stimulus_type": "pmod_stim_type",
            "event02_expect_RT": "pmod_expect_RT",
            "event02_expect_angle": "pmod_expect_angle",
            "event04_actual_RT": "pmod_actual_RT",
            "event04_actual_angle": "pmod_actual_angle",
        }
        trigger = df["param_trigger_onset"][0]

        # A. create dataframe for datalad ________________________________________________________________________
        datalad_df = df[
            [
                "event01_cue_onset",
                "event02_expect_displayonset",
                "event03_stimulus_displayonset",
                "event04_actual_displayonset",
            ]
        ]
        # or I could do: datalad_df = df.filter(like='event')
        datalad = datalad_df - df["param_trigger_onset"][0]
        datalad = pd.concat(
            [
                datalad,
                df[
                    [
                        "param_cue_type",
                        "param_stimulus_type",
                        "event02_expect_RT",
                        "event02_expect_angle",
                        "event04_actual_RT",
                        "event04_actual_angle",
                    ]
                ],
            ],
            axis=1,
        )
        datalad["cue_con"] = datalad["param_cue_type"].map(dict_cue)
        datalad["stim_lin"] = datalad["param_stimulus_type"].map(dict_stim)
        datalad["stim_quad"] = datalad["param_stimulus_type"].map(dict_stim_q)

        # 2) save angle, RT in a separate tab
        # ANGLE: 1) demean , 2) for NA value, assign value of 0. this works for the parametric modulator
        # RT: if RT or angle is empty with a NA value, fill in duration as 4s ("time to rate")
        datalad[
            ["event02_expect_angle_demean", "event04_actual_angle_demean"]
        ] = datalad[["event02_expect_angle", "event04_actual_angle"]].transform(
            lambda df: df - df.mean()
        )
        datalad[["event02_expect_angle_demean", "event04_actual_angle_demean"]] = (
            datalad[["event02_expect_angle_demean",
                     "event04_actual_angle_demean"]]
            .fillna(0)
            .copy()
        )
        datalad[["event02_expect_RT", "event04_actual_RT"]] = (
            datalad[["event02_expect_RT", "event04_actual_RT"]].fillna(
                4).copy()
        )

        # 3) save as SPM format
        datalad.rename(dict_col, inplace=True)
        datalad_fname = os.path.join(spm_dir, sub, ses, label + "_events.tsv")
        datalad.to_csv(datalad_fname, index=None, sep="\t")

        # B. create EV ________________________________________________________________________
        # column 1: onset, column 2: duration, column 3: value of the input during period (parametric modulator)
        # onset
        # 1. CUE ___________________________________________________________________________
        # * 1-1. CUE x 1s x no pmod
        # * 1-2. CUE x 1s x pmod cue type (high vs low)
        # * 1-3. CUE x 1s x pmod expect rating (demean)
        fname_1_1 = os.path.join(
            fsl_dir, sub, ses, f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-01_evtype-cue_pmod-none.txt"
        )
        _build_evfile(
            df=datalad,
            onset_col="event01_cue_onset",
            dur_col=1,
            mod_col=1,
            fname=fname_1_1,
        )

        fname_1_2 = os.path.join(
            fsl_dir, sub, ses, f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-01_evtype-cue_pmod-cue.txt")
        # label + "_ev01-cue_pmod-cue.txt")
        _build_evfile(
            df=datalad,
            onset_col="event01_cue_onset",
            dur_col=1,
            mod_col="param_cue_type",
            fname=fname_1_2,
            dict_map=dict_cue,
        )

        fname_1_3 = os.path.join(
            fsl_dir, sub, ses, f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-01_evtype-cue_pmod-expectdemean.txt")
        # label + "_ev01-cue_pmod-expectdemean.txt"
        # )
        _build_evfile(
            df=datalad,
            onset_col="event01_cue_onset",
            dur_col=1,
            mod_col="event02_expect_angle_demean",
            fname=fname_1_3,
        )

        # 2. RATING EXPECT ___________________________________________________________________________ DUR: RT
        # * 2-1. RATING onset only
        fname_2_1 = os.path.join(
            fsl_dir, sub, ses, f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-02_evtype-expect_pmod-none.txt"
            # label + "_ev02-expect_pmod-none.txt"
        )
        _build_evfile(
            df=datalad,
            onset_col="event02_expect_displayonset",
            dur_col="event02_expect_RT",
            mod_col=1,
            fname=fname_2_1,
        )

        # 3. STIM ___________________________________________________________________________
        # * 3-1. stim x 5s x no pmod
        # * 3-2. stim x 5s x cue
        # * 3-3. stim x 5s x actual rating (demean)
        # * 3-4. stim x 5s x expect rating (demean)
        # * 3-5. stim x 5s x stimulus intensity level
        fname_3_1 = os.path.join(
            fsl_dir, sub, ses, f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-03_evtype-stimulus_pmod-none.txt"
            #  label + "_ev03-stim_pmod-none.txt"
        )
        _build_evfile(
            df=datalad,
            onset_col="event03_stimulus_displayonset",
            dur_col=5,
            mod_col=1,
            fname=fname_3_1,
        )

        fname_3_2 = os.path.join(
            fsl_dir, sub, ses, f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-03_evtype-stimulus_pmod-cue.txt")
        # label + "_ev03-stim_pmod-cue.txt")
        _build_evfile(
            df=datalad,
            onset_col="event03_stimulus_displayonset",
            dur_col=5,
            mod_col="param_cue_type",
            fname=fname_3_2,
            dict_map=dict_cue,
        )

        fname_3_3 = os.path.join(
            fsl_dir, sub, ses, f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-03_evtype-stimulus_pmod-outcomedemean.txt")
            # label + "_ev03-stim_pmod-actualdemean.txt"
        # )
        _build_evfile(
            df=datalad,
            onset_col="event03_stimulus_displayonset",
            dur_col=5,
            mod_col="event04_actual_angle_demean",
            fname=fname_3_3,
        )

        fname_3_4 = os.path.join(
            fsl_dir, sub, ses,  f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-03_evtype-stimulus_pmod-expectdemean.txt")
            # label + "_ev03-stim_pmod-expectdemean.txt"
        # )
        _build_evfile(
            df=datalad,
            onset_col="event03_stimulus_displayonset",
            dur_col=5,
            mod_col="event02_expect_angle_demean",
            fname=fname_3_4,
        )

        fname_3_5 = os.path.join(
            fsl_dir, sub, ses, f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-03_evtype-stimulus_pmod-stimintensity.txt")
            # label + "_ev03-stim_pmod-stimintensity.txt"
        # )
        _build_evfile(
            df=datalad,
            onset_col="event03_stimulus_displayonset",
            dur_col=5,
            mod_col="param_stimulus_type",
            fname=fname_3_5,
            dict_map=dict_stim,
        )

        # 4. RATING ACTUAL __________________________________________________________________
        # * 4-1. RATING onset only
        fname_4_1 = os.path.join(
            fsl_dir, sub, ses, f"{sub}_{ses}_run-{runnum:02d}_runtype-{runtype}_ev-04_evtype-outcome_pmod-none.txt")
            # label + "_ev04-actual_pmod-none.txt"
        # )
        _build_evfile(
            df=datalad,
            onset_col="event04_actual_displayonset",
            dur_col="event04_actual_RT",
            mod_col=1,
            fname=fname_4_1,
        )
