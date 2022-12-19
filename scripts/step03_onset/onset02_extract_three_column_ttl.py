#!/usr/bin/env python
# encoding: utf-8
# %% libraries ________________________________________________________________________
import pandas as pd
import os, glob, datetime
from os.path import join
import pdb
from pathlib import Path
import itertools
from datetime import datetime
import traceback
import logging

"""onset02_extract_three_column_ttl.py
This file integrates the behavioral onsets, in conjunction with the TTL onsets, 
extracted from biopac acquisition files

1. identify the intersection of biopac and behavioral data
2. within onset01_FSL, save additional 3 column text files
3. within onset02_SPM, insert TTL information and save as .tsv file

Users:
    change every directory in chunk - parameter
"""
# __author__ = "Heejung Jung"
# __version__ = "1.0.1"
# __email__ = "heejung.jung@colorado.edu"
# __status__ = "Production"


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
    new_df["onset"] = df[onset_col]

    if isinstance(dur_col, str):
        new_df["dur"] = df[dur_col]
    else:
        new_df["dur"] = dur_col
    if isinstance(mod_col, str):
        if dict_map:
            new_df["mod"] = df[mod_col].map(dict_map["dict_map"])
        else:
            new_df["mod"] = df[mod_col]
    else:
        new_df["mod"] = mod_col
    new_df.to_csv(fname, header=None, index=None, sep="\t", mode="w")

def sublist(source_dir:str, remove_int:list,  sub_zeropad:int) -> list:
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
    folder_list = [ f.name for f in os.scandir(join(source_dir)) if f.is_dir() and  'sub-' in f.name ]
    #biopac_list = next(os.walk(join(source_dir)))[2]
    remove_list = [f"sub-{x:0{sub_zeropad}d}" for x in remove_int]
    # include_int = list(np.arange(slurm_id * stride + 1, (slurm_id + 1) * stride, 1))
    # include_list = [f"sub-{x:0{sub_zeropad}d}" for x in include_int]
    sub_list = [x for x in folder_list if x not in remove_list]
    # sub_list = [x for x in sub_list if x in include_list]
    return sorted(sub_list)

# TODO:
# parameters
# * biopac_ttl_dir
# * cue main_dir
samplingrate = 2000

# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[
    1
]  # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
print("\nscript directory is: {0}".format(current_dir))
print("\ntop directory is: {0}".format(main_dir))

# beh_dir = join(main_dir, "data", "d02_preproc-beh")
# fsl_dir = join(main_dir, "data", "d03_onset", "onset01_FSL")
# spm_dir = join(main_dir, "data", "d03_onset", "onset02_SPM")
beh_dir = join(main_dir, 'data', 'beh', 'beh02_preproc')
fsl_dir = join(main_dir, 'data', 'fmri01_onset', 'onset01_FSL')
spm_dir = join(main_dir, 'data', 'fmri01_onset', 'onset02_SPM')
# biopac directory is outside of social influence repository. Set accordingly
biopac_ttl_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop_data/physio/physio04_ttl/task-cue"
log_dir = join(main_dir, "scripts", "logcenter")
# %%  identify subjects with biopac data, remove unwanted subjects
# biopac_list = next(os.walk(biopac_ttl_dir))[1]
# remove_int = [1, 2, 3, 4, 5]
# remove_list = [f"sub-{x:04d}" for x in remove_int]
# sub_list = [x for x in biopac_list if x != remove_list]


sub_list = sublist(source_dir= biopac_ttl_dir, remove_int = [1, 2, 3, 4, 5], sub_zeropad = 4)
ses_list = [1, 3, 4]
sub_ses = list(itertools.product(sorted(sub_list), ses_list))

date = datetime.now().strftime("%m-%d-%Y")

txt_filename = os.path.join(
    log_dir, f"step03-onset_desc-behavioralttlcombine_flaglist_{date}.txt"
)

formatter = logging.Formatter("%(levelname)s - %(message)s")
handler = logging.FileHandler(txt_filename)
handler.setFormatter(formatter)
handler.setLevel(logging.DEBUG)
# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setFormatter(formatter)
ch.setLevel(logging.INFO)
logging.getLogger().addHandler(handler)
logging.getLogger().addHandler(ch)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# textfile = open(join(log_dir, f"flag_{date}.txt"), "w")
# textfile.write(
#     "this file contains anomalies from biopac-extracted TTL data and behavioral data\n"
# )
# textfile.write("it raises a flag if biopac data doesn't match behavioral data\n")

# %%
flag = []
for i, (sub, ses_ind) in enumerate(sub_ses):
    try:
        print(sub, ses_ind)
        ses = f"ses-{ses_ind:02d}"
        logger.info(f"\n\n__________________{sub} {ses} __________________")
        biopac_flist = glob.glob(join(biopac_ttl_dir, sub, ses, "*medocttl*.csv"))
    except:
        logger.error(f"\tno ttl file exists")
        # with open(join(log_dir, "flag_{date}.txt"), "a") as logfile:
        #     traceback.print_exc(file=logfile)
        continue

    # beh_list = glob.glob(join(beh_dir, sub, ses,'*_beh.csv'))
    Path(join(fsl_dir, sub, ses)).mkdir(parents=True, exist_ok=True)
    Path(join(spm_dir, sub, ses)).mkdir(parents=True, exist_ok=True)

    for ind, bio_fpath in enumerate(biopac_flist):
        # example: sub-0029_ses-04_task-social_run-01_physio-ttl.csv
        # based on biopac run info, find corresponding behavioral file
        bio_fname = os.path.basename(bio_fpath)
        run = bio_fname.split("_")[3]
        biopac_df = pd.read_csv(bio_fpath)
        biopac_df[["ttl_1", "ttl_2", "ttl_3", "ttl_4"]] = biopac_df[["ttl_1", "ttl_2", "ttl_3", "ttl_4"]]/samplingrate

        # load behavioral data
        beh_fpath = glob.glob(
            join(beh_dir, sub, ses, f"{sub}_{ses}_task-social_{run}-*_beh.csv")
        )
        try:
            beh_fname = os.path.basename(beh_fpath[0])
        except:
            logger.error(f"\tno match between behavioral and ttl file")
            continue
        run_type = beh_fname.split("_")[3]
        label = "_".join(beh_fname.split("_")[0:4])
        # IF loop 1) CHECK that run type is "pain"
        if "pain" in run_type:
            df = pd.read_csv(beh_fpath[0])

            # dictionary:
            dict_cue = {"low_cue": -1, "high_cue": 1}
            dict_stim = {"low_stim": -1, "med_stim": 0, "high_stim": 1}
            dict_stim_q = {"low_stim": 1, "med_stim": -2, "high_stim": 1}
            dict_col = {
                "ttl_1": "TTL1",
                "ttl_2": "TTL2",
                "ttl_3": "TTL3",
                "ttl_4": "TTL4",
                "early": "event03_stim_earlyphase_0-4500ms",  # duration of 4.5s
                "late": "event03_stim_latephase_4500-9000ms",  # duration of 4.5s
                "post": "event03_stim_poststim_9000-135000ms",  # duration of 4.5s
                "plateau": "event03_stim_ttl-plateau",  # calculate duration
                "plateau_dur": "event03_stim_ttl-plateau-dur",
            }
            trigger = df["param_trigger_onset"][0]

            # 1. directories ________________________________________________________________________

            # I. create dataframe for datalad
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

            # save angle, RT in a separate tab
            # ANGLE: 1) demean , 2) for NA value, assign value of 0. this works for the parametric modulator
            # RT: if RT or angle is empty with a NA value, fill in duration as 4s ("time to rate")
            datalad[
                ["event02_expect_angle_demean", "event04_actual_angle_demean"]
            ] = datalad[["event02_expect_angle", "event04_actual_angle"]].transform(
                lambda df: df - df.mean()
            )
            datalad[["event02_expect_angle_demean", "event04_actual_angle_demean"]] = (
                datalad[["event02_expect_angle", "event04_actual_angle"]]
                .fillna(0)
                .copy()
            )
            datalad[["event02_expect_RT", "event04_actual_RT"]] = (
                datalad[["event02_expect_RT", "event04_actual_RT"]].fillna(4).copy()
            )

            # merge biopac and behavioral info
            mri_ttl = pd.concat(
                [datalad, biopac_df[["ttl_1", "ttl_2", "ttl_3", "ttl_4"]]],
                axis=1,
                join="inner",
            )
            # TODO: check if missing TTL matches _______________________________________________________________
            # df['event03_stimulus_P_trigger'] if successful: 'Command Recieved: TRIGGER_AND_Response: RESULT_OK'
            # if biopac_df
            # ________________________________________________________________________________________________
            mri_ttl["early"] = mri_ttl["ttl_1"]
            mri_ttl["late"] = mri_ttl["ttl_1"] + 4.5
            mri_ttl["post"] = mri_ttl["ttl_1"] + 9
            mri_ttl["plateau"] = mri_ttl["ttl_2"]
            mri_ttl["plateau_dur"] = mri_ttl["ttl_3"] - mri_ttl["ttl_2"]
            # merge biopac data
            mri_ttl.rename(dict_col, axis="columns", inplace=True)
            mri_ttl_fname = join(spm_dir, sub, ses, label + "_events_ttl.tsv")
            mri_ttl.to_csv(mri_ttl_fname, index=None, sep="\t")

            # II. create EV ________________________________________________________________________
            # column 1: onset, column 2: duration, column 3: value of the input during period (parametric modulator)

            # onset
            # 1. CUE ______________________
            # 1-1. CUE onset only
            # 1-2. CUE modulated with cue type
            # 1-3. CUE modulated with cue type
            _build_evfile(
                df=mri_ttl,
                onset_col="event01_cue_onset",
                dur_col=1,
                mod_col=1,
                fname=join(fsl_dir, sub, ses, label + "_ev01-cue_pmod-onsetonly.txt"),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event01_cue_onset",
                dur_col=1,
                mod_col="param_cue_type",
                fname=join(fsl_dir, sub, ses, label + "_ev01-cue_pmod-cue.txt"),
                dict_map=dict_cue,
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event01_cue_onset",
                dur_col=1,
                mod_col="event02_expect_angle_demean",
                fname=join(
                    fsl_dir, sub, ses, label + "_ev01-cue_pmod-expectdemean.txt"
                ),
            )

            # 2. RATING EXPECT ______________________ DUR: RT
            # 2-1. RATING onset only
            _build_evfile(
                df=mri_ttl,
                onset_col="event02_expect_displayonset",
                dur_col="event02_expect_RT",
                mod_col=1,
                fname=join(
                    fsl_dir, sub, ses, label + "_ev02-expect_pmod-onsetonly.txt"
                ),
            )

            # # 3. STIM :: expected time (2s after onset - 7s after onset) ___________________________________________________________________________
            # STIM_onsetonly, STIM_pmod-cue, STIM_pmod-actual, STIM_pmod-expect, STIM-pmod-level
            # 3-1-1. stim x 5s x onset time only
            # 3-1-2. stim x 5s x cue type
            # 3-1-3. stim x 5s x actual rating
            # 3-1-4. stim x 5s x expect rating
            # 3-1-5. stim x 5s x stimulus intensity level

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stimulus_displayonset",
                dur_col=5,
                mod_col=1,
                fname=join(
                    fsl_dir, sub, ses, label + "_ev03-stim_type-ptb_pmod-onsetonly.txt"
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stimulus_displayonset",
                dur_col=5,
                mod_col="param_cue_type",
                fname=join(
                    fsl_dir, sub, ses, label + "_ev03-stim_type-ptb_pmod-cue.txt"
                ),
                dict_map=dict_cue,
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stimulus_displayonset",
                dur_col=5,
                mod_col="event04_actual_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ptb_pmod-actualdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stimulus_displayonset",
                dur_col=5,
                mod_col="event02_expect_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ptb_pmod-expectdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stimulus_displayonset",
                dur_col=4.5,
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ptb_pmod-stimintensity.txt",
                ),
                mod_col="param_stimulus_type",
                dict_map=dict_stim,
            )

            # 3-2-1. stim x TTL early x onset time only
            # 3-2-2. stim x TTL early x cue type
            # 3-2-3. stim x TTL early x actual rating
            # 3-2-4. stim x TTL early x expect rating
            # 3-2-5. stim x TTL early x onset time only

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_earlyphase_0-4500ms",
                dur_col=4.5,
                mod_col=1,
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlearly_pmod-onsetonly.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_earlyphase_0-4500ms",
                dur_col=4.5,
                mod_col="param_cue_type",
                fname=join(
                    fsl_dir, sub, ses, label + "_ev03-stim_type-ttlearly_pmod-cue.txt"
                ),
                dict_map=dict_cue,
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_earlyphase_0-4500ms",
                dur_col=4.5,
                mod_col="event04_actual_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlearly_pmod-actualdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_earlyphase_0-4500ms",
                dur_col=4.5,
                mod_col="event02_expect_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlearly_pmod-expectdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_earlyphase_0-4500ms",
                dur_col=4.5,
                mod_col="param_stimulus_type",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlearly_pmod-stimintensity.txt",
                ),
                dict_map=dict_stim,
            )

            # 3-3-1. stim x TTL late x onset time only
            # 3-3-2. stim x TTL late x cue type
            # 3-3-3. stim x TTL late x actual rating
            # 3-3-4. stim x TTL late x expect rating
            # 3-3-5. stim x TTL late x onset time only
            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_latephase_4500-9000ms",
                dur_col=4.5,
                mod_col=1,
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttllate_pmod-onsetonly.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_latephase_4500-9000ms",
                dur_col=4.5,
                mod_col="param_cue_type",
                fname=join(
                    fsl_dir, sub, ses, label + "_ev03-stim_type-ttllate_pmod-cue.txt"
                ),
                dict_map=dict_cue,
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_latephase_4500-9000ms",
                dur_col=4.5,
                mod_col="event04_actual_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttllate_pmod-actualdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_latephase_4500-9000ms",
                dur_col=4.5,
                mod_col="event02_expect_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttllate_pmod-expectdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_latephase_4500-9000ms",
                dur_col=4.5,
                mod_col="param_stimulus_type",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttllate_pmod-stimintensity.txt",
                ),
                dict_map=dict_stim,
            )

            # 3-4-1. stim x TTL post x onset time only
            # 3-4-2. stim x TTL post x cue type
            # 3-4-3. stim x TTL post x actual rating
            # 3-4-4. stim x TTL post x expect rating
            # 3-4-5. stim x TTL post x onset time only
            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_poststim_9000-135000ms",
                dur_col=4.5,
                mod_col=1,
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlpost_pmod-onsetonly.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_poststim_9000-135000ms",
                dur_col=4.5,
                mod_col="param_cue_type",
                fname=join(
                    fsl_dir, sub, ses, label + "_ev03-stim_type-ttlpost_pmod-cue.txt"
                ),
                dict_map=dict_cue,
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_poststim_9000-135000ms",
                dur_col=4.5,
                mod_col="event04_actual_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlpost_pmod-actualdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_poststim_9000-135000ms",
                dur_col=4.5,
                mod_col="event02_expect_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlpost_pmod-expectdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_poststim_9000-135000ms",
                dur_col=4.5,
                mod_col="param_stimulus_type",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlpost_pmod-stimintensity.txt",
                ),
                dict_map=dict_stim,
            )

            # 3-5-1. stim x TTL plateau x onset time only
            # 3-5-2. stim x TTL plateau x cue type
            # 3-5-3. stim x TTL plateau x actual rating
            # 3-5-4. stim x TTL plateau x expect rating
            # 3-5-5. stim x TTL plateau x onset time only

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_ttl-plateau",
                dur_col="event03_stim_ttl-plateau-dur",
                mod_col=1,
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlplateau_pmod-onsetonly.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_ttl-plateau",
                dur_col="event03_stim_ttl-plateau-dur",
                mod_col="param_cue_type",
                fname=join(
                    fsl_dir, sub, ses, label + "_ev03-stim_type-ttlplateau_pmod-cue.txt"
                ),
                dict_map=dict_cue,
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_ttl-plateau",
                dur_col="event03_stim_ttl-plateau-dur",
                mod_col="event04_actual_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlplateau_pmod-actualdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_ttl-plateau",
                dur_col="event03_stim_ttl-plateau-dur",
                mod_col="event02_expect_angle_demean",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlplateau_pmod-expectdemean.txt",
                ),
            )

            _build_evfile(
                df=mri_ttl,
                onset_col="event03_stim_ttl-plateau",
                dur_col="event03_stim_ttl-plateau-dur",
                mod_col="param_stimulus_type",
                fname=join(
                    fsl_dir,
                    sub,
                    ses,
                    label + "_ev03-stim_type-ttlplateau_pmod-stimintensity.txt",
                ),
                dict_map=dict_stim,
            )

            # 4. RATING ACTUAL __________________________________________________________________
            # 4-1. RATING onset only
            _build_evfile(
                df=mri_ttl,
                onset_col="event04_actual_displayonset",
                dur_col="event04_actual_RT",
                mod_col=1,
                fname=join(
                    fsl_dir, sub, ses, label + "_ev04-actual_pmod-onsetonly.txt"
                ),
            )
