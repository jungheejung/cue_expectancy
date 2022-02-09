#!/usr/bin/env python3
"""create a table 
each row corresponds to each regressor
contains nifti name, onset, duration ,modulation degree
CUE, STIM, wm, csf, 6DOR, 6 dummy regressor
next run...
Each index corresponds to the 
"""
# %%
import os, glob, itertools
import pandas as pd
from pathlib import Path 
import numpy as np
import re

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

def _event_sort(df, ind_first, ev, ev_name, dur, mod, regressor, cue_type, stim_type):
    # df, 0, 'event01_cue_onset', 'cue', 1, 1, True, 
    df.loc[ind_first: ind_first+len(df[ev])-1, 'onset'] = df[ev] - df['param_trigger_onset']
    df.loc[ind_first: len(df['ev']), 'ev'] = ev_name
    df.loc[ind_first: len(df['ev']), 'dur'] = dur
    df.loc[ind_first: len(df['ev']), 'mod'] = mod
    df.loc[ind_first: len(df['ev']), 'regressor'] = regressor
    df.loc[ind_first: len(df['ev']), 'num'] = list(range(len(df[ev])))
    df.loc[ind_first: len(df['ev']), 'cue_type'] = cue_type
    df.loc[ind_first: len(df['ev']), 'stim_type'] = stim_type
    return df
# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social

csv_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd02_preprocessed')
ev_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd03_EV_FSL')
ev_bids_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd04_EV_SPM')
ev_single_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd06_singletrial_SPM_01-pain-early')
dict_cue = {'low_cue':-1, 'high_cue':1}
dict_stim = {'low_stim':-1, 'med_stim':0, 'high_stim':1}
dict_stim_q = {'low_stim':1, 'med_stim':-2, 'high_stim':1}

# FIX: TODO
# change column names 
dict_col = {
'onset01_cue':'event01_cue_onset',
'onset02_ratingexpect': 'event02_expect_displayonset',
'onset03_stim':'event03_stimulus_displayonset',
'onset04_ratingactual':'event04_actual_displayonset',
'pmod_cue_type':'param_cue_type',
'pmod_stim_type':'param_stimulus_type',
'pmod_expect_RT':'event02_expect_RT',
'pmod_actual_RT':'event04_actual_RT',
'pmod_expect_angle_demean':'event02_expect_angle_demean',
'pmod_actual_angle_demean':'event04_actual_angle_demean',
'onset03_stim_earlyphase_0-4500ms':'event03_stim_earlyphase_0-4500ms', # duration of 4.5s
'onset03_stim_latephase_4500-9000ms': 'event03_stim_latephase_4500-9000ms', # duration of 4.5s
'onset03_stim_poststim_9000-135000ms':'event03_stim_poststim_9000-135000ms', # duration of 4.5s
'onset03_stim_ttl-plateau':'event03_stim_ttl-plateau', # calculate duration 
'onset03_stim_ttl-plateau-dur':'event03_stim_ttl-plateau-dur'
}
# %%
sub_list = next(os.walk(csv_dir))[1]
sub_list.remove('sub-0001')
for sub in sub_list:
    beh_list = []
    beh_list = glob.glob(os.path.join(csv_dir, sub, '*','*pain*_beh.csv'))
    beh_list = glob.glob(os.path.join(main_dir, 'data', 'dartmouth', 'd06_singletrial_SPM', sub, '*', '*_ttl.tsv'))
    subject_dataframe = pd.DataFrame([])
    if beh_list: 
        for ind, fpath in enumerate(sorted(beh_list)):
            fname = os.path.basename(fpath)
            
            df = pd.DataFrame()
            df = pd.read_csv(fpath, sep = '\t')
            fname = os.path.basename(fpath)
            df.rename(columns = dict_col, inplace = True)

            sub_num = int(re.findall('\d+', [match for match in fname.split('_') if "sub" in match][0])[0])
            ses_num= int(re.findall('\d+', [match for match in fname.split('_') if "ses" in match][0])[0])
            run_num = int(re.findall('\d+', [match for match in fname.split('_') if "run" in match][0])[0])
            task_name = [match for match in fname.split('_') if "task" in match][0]

            Path(os.path.join(ev_single_dir, sub)).mkdir(parents=True, exist_ok=True)

            cue_num = len(df.event01_cue_onset)
            trial_num = len(df.event03_stimulus_displayonset) 
            nuissance = ['csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z', 'dummy']
            nuissance_num = len(nuissance)
            new = pd.DataFrame(
                index = range(cue_num + trial_num + nuissance_num + 1),
                columns=['nifti_name','sub','ses','run','task','ev','num',
                'onset','dur','mod','regressor',
                'cue_type', 'stim_type','expect_rating','actual_rating','cue_con', 'stim_lin', 'stim_quad'])

            # CUE event fill in parameters for CUE event ____________________________________________
            cue_num = len(df.event01_cue_onset)
            new.loc[0:cue_num-1, 'onset'] = df.event01_cue_onset 
            new.loc[0:cue_num-1, 'ev'] = 'cue'
            new.loc[0:cue_num-1, 'dur'] = 1
            new.loc[0:cue_num-1, 'mod'] = 1
            new.loc[0:cue_num-1, 'regressor'] = True
            new.loc[0:cue_num-1, 'num'] = list(range(cue_num))
            new.loc[0:cue_num-1, 'cue_type'] = list(df.param_cue_type)
            new.loc[0:cue_num-1, 'stim_type'] = list(df.param_stimulus_type)


            # STIM fill in parameters for STIM event _____________________________________________
            trial_num = len(df.event03_stimulus_displayonset) 
            new.loc[cue_num:cue_num+trial_num-1, 'onset'] = list(df['event03_stim_earlyphase_0-4500ms'])
            new.loc[cue_num:cue_num+trial_num-1, 'ev'] = 'stim'
            new.loc[cue_num:cue_num+trial_num-1, 'dur'] = 4.5
            new.loc[cue_num:cue_num+trial_num-1, 'mod'] = 1
            new.loc[cue_num:cue_num+trial_num-1, 'regressor'] = True
            new.loc[cue_num:cue_num+trial_num-1, 'num'] = list(range(trial_num))
            new.loc[cue_num:cue_num+trial_num-1, 'cue_type'] = list(df.param_cue_type)
            new.loc[cue_num:cue_num+trial_num-1, 'stim_type'] = list(df.param_stimulus_type)

            # expect actual rating ________________________________________________________________
            new.loc[0:cue_num+trial_num-1, 'expect_rating'] = list(pd.concat([df.event02_expect_angle_demean]*2, ignore_index=True))
            new.loc[0:cue_num+trial_num-1, 'actual_rating'] = list(pd.concat([df.event04_actual_angle_demean]*2, ignore_index=True))
            # RATING fill in parameters for STIM event ____________________________________________
            # trial_num = len(df.ISI03_onset - df.param_trigger_onset) 
            rating = pd.concat( [df.event02_expect_displayonset, df.event04_actual_displayonset]).reset_index(drop = True)
            rt = pd.concat( [df.event02_expect_RT, df.event04_actual_RT]).reset_index(drop = True)
            rate_df = pd.concat([rating, rt], axis = 1)
            rate_df.fillna(4, inplace = True)
            rate_df.rename({0:'rating', 1:'rt'}, axis = 1, inplace = True)
            rate_df.sort_values(by =[ 'rating'], ascending = True, inplace = True, ignore_index=True)
            # rating.sort_values(ascending = True, inplace = True, ignore_index=True)
            new.loc[cue_num+trial_num, 'onset'] = list(rating )
            new.loc[cue_num+trial_num, 'ev'] = 'rating'
            new.loc[cue_num+trial_num, 'dur'] = list(rt)
            new.loc[cue_num+trial_num, 'mod'] = 1
            new.loc[cue_num+trial_num, 'regressor'] = False

            matlab_rating = pd.concat([rating, rt], axis = 1)
            matlabname = f'{sub}_ses-{ses_num:02d}_run-{run_num:02d}_rating_early.csv'
            matlab_rating.to_csv(os.path.join(ev_single_dir, sub, matlabname), index = False, header = ['rating', 'rt'] ) #sub-####_ses-##_run-##_event-rating.csv

            new.loc[0:cue_num+trial_num-1,'cue_con'] = pd.concat([df['param_cue_type'].map(dict_cue)]*2, ignore_index=True)
            new.loc[0:cue_num+trial_num-1,'stim_lin'] = pd.concat([df['param_stimulus_type'].map(dict_stim)]*2, ignore_index=True)
            new.loc[0:cue_num+trial_num-1,'stim_quad'] = pd.concat([df['param_stimulus_type'].map(dict_stim_q)]*2, ignore_index=True)
            #
            new['sub'] = sub_num
            new['ses'] = ses_num
            new['run'] = run_num
            new['task'] = task_name

            # filename build string e.g. sub-0005_ses-04_run-06-pain_ev-stim-0011.nii.gz
            new['nifti_name'] = 'sub-' + new['sub'].astype(str).str.zfill(4) + \
            '_ses-' + new['ses'].astype(str).str.zfill(2) + \
            '_run-' + new['run'].astype(str).str.zfill(2) + '-' + new['task'] + \
                '_ev-' + new['ev'] + '-' + new['num'].astype(str).str.zfill(4)
            # print(f"sub-{new.sub:04d}_ses-{new['ses']:02d}_run-{new['run']:02d}*.nii.gz")

            # dummy regressors
            
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1, 'nifti_name'] = list(nuissance)
            new['sub'] = sub_num
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'ses'] = ses_num
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'run'] = run_num
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'task'] = task_name
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'regressor'] = False
            subject_dataframe = subject_dataframe.append(new)

        subject_dataframe.reset_index(inplace = True)
        subject_dataframe.to_csv(os.path.join(ev_single_dir, sub,  f'{sub}_singletrial_early.csv'), index_col=False)
    else:
        print(f"{sub} doesnt exist")   
# %%
