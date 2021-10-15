#!/usr/bin/env python
# encoding: utf-8
# %%
from operator import index
import os, re, glob
import numpy as np
import pandas as pd
from pathlib import Path
import itertools
"""
fsl02_create_single_tcol.py
this script will isolate trials into 1) single and 2) combined .tcol outputs. 
For the social influence task, we have two events of interest: CUE and STIM
There are four event types that will be modeled in the glm: CUE, EXPECT, STIM, and ACTUAL.

benchmark
https://github.com/SNaGLab/POKER.05/blob/POKER.05_BIDS/Scripts/isolateEvents/isolateEV01_FSLrestructure.py
"""
# __author__ = "Heejung Jung"
# __version__ = "1.0.1"
# __email__ = "heejung.jung@colorado.edu"
# __status__ = "Production"

# functions ___________________________________________________________
# %%
def _clean_df(fname, trial_type):
    # loads 3 column EV files 
    # convert to pandas and append info (trial number, trial type) 
    if os.path.exists(fname):
        df = pd.read_csv(fname, sep = '\t', header = None);
        column_indices = [0, 1, 2]
        new_names = ['onset','duration', 'magnitude']
        old_names = df.columns[column_indices]
        df.rename(columns=dict(zip(old_names, new_names)), inplace=True)
        df['trial_type'] = trial_type
        df.reset_index(inplace=True)
        df = df.rename(columns = {'index':'trial_no'})
    else:
        df = None
    return df
# %% parameters ________________________________________________________________________
# local data, 3 column EV files
# threeEV_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/data/dartmouth/d03_EV_FSL' # sub-0002/ses-01
# singleEV_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/isolated_ev'
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
threeEV_dir = os.path.join(main_dir,'data', 'dartmouth', 'd03_EV_FSL') # sub-0002/ses-01
singleEV_dir = os.path.join(main_dir,'analysis','fmri','fsl','multivariate','isolate_ev')

# data/dartmouth/d03_EV_FSL/sub-0003/ses-01/sub-0003_ses-01_task-social_run-01-pain_EV01-CUE_onsetonly.txt
sub_list = next(os.walk(threeEV_dir))[1]
a = [sub_list,
[1,3,4],
[1,2,3,4,5,6]]
b = list(itertools.product(*a))
for sub, ses_num, run_num in b:
# 1) open CUE text and count number of CUE
    # sub = 'sub-{0}'.format(str(sub_num).zfill(4))
    ses = 'ses-{0}'.format(str(ses_num).zfill(2))
    run = 'run-{0}'.format(str(run_num).zfill(2))
    fname_cue    = glob.glob(os.path.join(threeEV_dir, sub, ses, '{0}_{1}_task-social_{2}-*_EV01-CUE_onsetonly.txt'.format(sub,ses,run)))
    fname_expect = glob.glob(os.path.join(threeEV_dir, sub, ses, '{0}_{1}_task-social_{2}-*_EV02-EXPECT_onsetonly.txt'.format(sub,ses,run)))
    fname_stim   = glob.glob(os.path.join(threeEV_dir, sub, ses, '{0}_{1}_task-social_{2}-*_EV03-STIM_onsetonly.txt'.format(sub,ses,run)))
    fname_actual = glob.glob(os.path.join(threeEV_dir, sub, ses, '{0}_{1}_task-social_{2}-*_EV04-ACTUAL-onsetonly.txt'.format(sub,ses,run)))
    if fname_cue: 
        print("list exists")  
            # > sub-0002_ses-01_task-social_run-01-pain_ev-cue-0001
        # TODO: extract information from file name
        info = os.path.basename(fname_cue[0]).split("_")
        sub = info[0] # sub-0002
        ses = info[1] # ses-01
        task = info[2] # task-social
        run = info[3] # run-01-pain

        # [x] TODO: open all files, load and vstack
        cue_df = _clean_df(fname_cue[0], 'cue')
        stim_df = _clean_df(fname_stim[0], 'stim')
        expect_df = _clean_df(fname_expect[0], 'expect')
        actual_df = _clean_df(fname_actual[0], 'actual')
        full_df = pd.concat([cue_df, stim_df, expect_df, actual_df])
        full_df.reset_index(drop=True, inplace=True)

        # %%
        eye = pd.DataFrame(np.eye(len(full_df)).astype(bool))
        N = len(cue_df) + len(stim_df)
        eye_sub = eye.iloc[:, :N]
        # [x] TODO: create mask
        mask_df = pd.concat([full_df, eye_sub], axis = 1)
        # [x] TODO: if NaN exists in "expect or actual, substitute with 4"
        mask_df.loc[ pd.isna(mask_df['duration']) & mask_df['trial_type'].isin(['expect', 'actual']), 'duration' ] = 4
        # [x] TODO: extract trial info and save as single and combined EVs
        for ind in range(N):
            trial_info = mask_df.loc[mask_df[ind], ['trial_type', 'trial_no']]
            ev = '-'.join([str(num) for num in ['ev', trial_info.values[0][0], str(trial_info.values[0][1] ).zfill(4)]])
            trial_fname = '_'.join([str(num) for num in [sub, ses, task, run, ev]])

            single = mask_df.loc[mask_df[ind], ['onset', 'duration', 'magnitude']]
            combine = mask_df.loc[~mask_df[ind], ['onset', 'duration', 'magnitude']]
            save_dir = os.path.join(singleEV_dir, sub, ses, run, ev)
            if not os.path.exists(save_dir):
                os.makedirs(save_dir)
            single.to_csv(os.path.join(save_dir, trial_fname + '_single.tcol'), sep ='\t', header=False, index = False)
            combine.to_csv(os.path.join(save_dir, trial_fname + '_combine.tcol'), sep ='\t', header=False, index = False)
    else:
        print("no data from current run, {0} {1} {2}".format(sub, ses, run))
        continue
