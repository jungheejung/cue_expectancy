#!/usr/bin/env python3
"""create a table 
each row corresponds to each regressor
contains nifti name, onset, duration ,modulation degree
CUE, STIM, wm, csf, 6DOR, 6 dummy regressor

This code handles 3 types of files
1) pain run that has TTL signal in it 
    - in that case, it extracts pain onset from the ttl-plateau column
2) pain run that does not have TTL signal in it
    - in that case, it adds 3.5s to the stimulus onset
3) cognitive and vicarious runs
    - the stimulus onset is the time that we enter
"""
# %%
import os, glob, itertools
from os.path import join
from tkinter import Frame
from importlib_metadata import files
import pandas as pd
from pathlib import Path 
import numpy as np

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

def _event_sort(df, new_df, ind_first, ev, ev_name, dur, mod, regressor, cue_type, stim_type):
    # df, 0, 'event01_cue_onset', 'cue', 1, 1, True, 
    # print(f"range: {ind_first} ~ {ind_first+len(df[ev])-1}")
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'onset'] = list(df[ev]) 
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'ev'] = ev_name
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'dur'] = dur
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'mod'] = mod
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'regressor'] = regressor
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'num'] = list(range(1,len(df[ev])+1))
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'cue_type'] = cue_type
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'stim_type'] = stim_type
    return new_df.copy()

def _extract_bids(fname):
    entities = dict(
    match.split('-', 1)
    for match in fname.split('_')
    if '-' in match
    )
    
    sub_num = int(entities['sub'])
    ses_num = int(entities['ses'])
    run_num = int(entities['run'].split('-')[0])
    run_type = entities['run'].split('-')[-1]
    return sub_num, ses_num, run_num, run_type
# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
beh_dir = join(main_dir, 'data', 'd02_preproc-beh')
fsl_dir = join(main_dir, 'data', 'd03_onset', 'onset01_FSL')
spm_dir = join(main_dir, 'data', 'd03_onset', 'onset02_SPM')
single_dir = join(main_dir, 'data','d03_onset','onset03_SPMsingletrial_24dof')
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social'
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep'
dict_cue = {'low_cue':-1, 'high_cue':1}
dict_stim = {'low_stim':-1, 'med_stim':0, 'high_stim':1}
dict_stim_q = {'low_stim':1, 'med_stim':-2, 'high_stim':1}

dict_col = {
    "onset01_cue": "event01_cue_onset",
    "onset02_ratingexpect": "event02_expect_displayonset",
    "onset03_stim": "event03_stimulus_displayonset",
    "onset04_ratingactual": "event04_actual_displayonset",
    "pmod_cue_type": "param_cue_type",
    "pmod_stim_type": "param_stimulus_type",
    "pmod_expect_RT": "event02_expect_RT",
    "pmod_actual_RT": "event04_actual_RT",
    "pmod_expect_angle_demean": "event02_expect_angle_demean",
    "pmod_actual_angle_demean": "event04_actual_angle_demean",
    "onset03_stim_earlyphase_0-4500ms": "event03_stim_earlyphase_0-4500ms",  # duration of 4.5s
    "onset03_stim_latephase_4500-9000ms": "event03_stim_latephase_4500-9000ms",  # duration of 4.5s
    "onset03_stim_poststim_9000-135000ms": "event03_stim_poststim_9000-135000ms",  # duration of 4.5s
    "onset03_stim_ttl-plateau": "event03_stim_ttl-plateau",  # calculate duration
    "onset03_stim_ttl-plateau-dur": "event03_stim_ttl-plateau-dur",
}
keyword = 'plateau'
# %%
sub_folders = next(os.walk(beh_dir))[1]
sub_folder = [i for i in sub_folders if i.startswith('sub-')]
remove_int = [1,2,3,4,5]
remove_list = [f"sub-{x:04d}" for x in remove_int]
sub_list = [i for i in sub_folder if i not in remove_list]


# %%
# TODO: 
# 1. if beh_list is pain, then grab pain_events_ttl instead
# 2. if beh_list is pain, then _event_sort

# 1. glob all evetns list
# 2. glob all ttl files 
# 3. if ttl file exists, pop events and merge with beh_list 
# 4. if ttl file - then extract ttl column 
# 5. if non ttl file - then proceed with vanilla code, while adding onset times
for sub in sorted(sub_list):
    ttl_list = []
    ttl_list = glob.glob(join(spm_dir, sub, '*','*_events_ttl.tsv'))
    beh_list = glob.glob(join(spm_dir, sub, '*','*_events.tsv'))
    if bool(ttl_list):
        for ttl_ind, ttl_fpath in enumerate(ttl_list):

        # extract info from ttl_list
            ttl_fname = os.path.basename(ttl_fpath)
            sub_num, ses_num, run_num, run_type = _extract_bids(ttl_fname)

            # construct non-ttl file from info
            beh_fname = f"sub-{sub_num:04d}_ses-{ses_num:02d}_task-social_run-{run_num:02d}-pain_events.tsv"
            beh_index = [i for i, e in enumerate(beh_list) if  e.endswith(beh_fname)]
            if bool(beh_index) and len(beh_index) == 1:
                beh_list.pop(beh_index[0])
                beh_list.append(ttl_fpath)
            else:
                continue
    
    subject_dataframe = pd.DataFrame([])

    for ind, fpath in enumerate(sorted(beh_list)):
        fname = os.path.basename(fpath)
        sub_num, ses_num, run_num, run_type = _extract_bids(fname)

        Path(join(single_dir, sub)).mkdir(parents=True, exist_ok=True)

        if run_type == 'pain' and fname.endswith('events_ttl.tsv'):

            # fpath = join(spm_dir, f"sub-{sub_num:04d}",  f"ses-{ses_num:02d}", f"sub-{sub_num:04d}_ses-{ses_num:02d}_task-social_run-{run_num:02d}-pain_events_ttl.tsv")
            os.path.exists(fpath)
            df = pd.DataFrame()
            df = pd.read_csv(fpath, sep = '\t')

            cue_num = len(df['event01_cue_onset'])
            trial_num = len(df['event03_stim_ttl-plateau'])

            nuissance_fname = join(fmriprep_dir, sub, f"ses-{ses_num:02d}", 'func', f"{sub}_ses-{ses_num:02d}_task-social_acq-mb8_run-{run_num}_desc-confounds_timeseries.tsv")
            if os.path.exists(nuissance_fname):
                C = pd.read_csv(nuissance_fname, sep = '\t')
                trans = list(C.loc[:, C.columns.str.startswith('trans_')].columns)
                rot = list(C.loc[:, C.columns.str.startswith('rot_')].columns)
                spike = list(C.loc[:, C.columns.str.startswith('motion_outlier')].columns)
                if spike:
                    C['spike_1col'] = C[spike].sum(axis = 1)
                    nuissance = [['csf'], trans, rot, ['dummy','spike_1col']]
                else:
                    nuissance = [['csf'], trans, rot, ['dummy']]
                n_list = [item for sublist in nuissance for item in sublist]
                nuissance_num = len(n_list) 
                new = pd.DataFrame(
                    index = range(cue_num + trial_num + nuissance_num + 1),
                    columns=['nifti_name','sub','ses','run','run_type','ev','num',
                    'onset','dur','mod','regressor',
                    'cue_type', 'stim_type','expect_rating','actual_rating','cue_con', 'stim_lin', 'stim_quad'])

                # CUE event fill in parameters for CUE event ____________________________________________
                new = _event_sort(df,new, 
                ind_first = 0, 
                ev = 'event01_cue_onset', 
                ev_name = 'cue', 
                dur = 1, mod = 1, 
                regressor = True, 
                cue_type = list(df.param_cue_type), 
                stim_type = list(df.param_stimulus_type))

                # STIM fill in parameters for STIM event _____________________________________________
                new = _event_sort(df,new, 
                ind_first = trial_num, 
                ev = 'event03_stim_ttl-plateau', 
                ev_name = 'stim', 
                dur = 5, mod = 1, 
                regressor = True, 
                cue_type = list(df.param_cue_type), 
                stim_type = list(df.param_stimulus_type))

                # Rating information ________________________________________________________________
                new.loc[0:cue_num+trial_num-1, 'expect_rating'] = list(pd.concat([df['event02_expect_angle']]*2, ignore_index=True))
                new.loc[0:cue_num+trial_num-1, 'actual_rating'] = list(pd.concat([df['event04_actual_angle']]*2, ignore_index=True))

                rating = pd.concat( [df.event02_expect_displayonset, df.event04_actual_displayonset])
                rt = pd.concat( [df.event02_expect_RT, df.event04_actual_RT]).reset_index(drop = True)
                rt.fillna(4, inplace = True)
                rating.sort_values(ascending = True, inplace = True, ignore_index=True)
                new.loc[cue_num+trial_num, 'onset'] = list(rating.repeat(2).reset_index(drop = True))
                new.loc[cue_num+trial_num, 'ev'] = 'rating'
                new.loc[cue_num+trial_num, 'dur'] = list(rt)
                new.loc[cue_num+trial_num, 'mod'] = 1
                new.loc[cue_num+trial_num, 'regressor'] = False

                matlab_rating = pd.concat([rating, rt], axis = 1)
                matlabname = f'{sub}_ses-{ses_num:02d}_run-{run_num:02d}_covariate-circularrating.csv'
                matlab_rating.to_csv(join(single_dir, sub, matlabname), index = False, header = ['rating', 'rt'] ) #sub-####_ses-##_run-##_event-rating.csv

                # parameter information for each single trial ________________________________________________________________
                new.loc[0:cue_num+trial_num-1,'cue_con'] = pd.concat([df['param_cue_type'].map(dict_cue)]*2, ignore_index=True)
                new.loc[0:cue_num+trial_num-1,'stim_lin'] = pd.concat([df['param_stimulus_type'].map(dict_stim)]*2, ignore_index=True)
                new.loc[0:cue_num+trial_num-1,'stim_quad'] = pd.concat([df['param_stimulus_type'].map(dict_stim_q)]*2, ignore_index=True)
                
                new['sub'] = sub_num
                new['ses'] = ses_num
                new['run'] = run_num
                new['run_type'] = 'pain-plateau'

                # filename build string e.g. sub-0005_ses-04_run-06-pain_ev-stim-0011.nii.gz
                new['nifti_name'] = 'sub-' + new['sub'].astype(str).str.zfill(4) + \
                '_ses-' + new['ses'].astype(str).str.zfill(2) + \
                '_run-' + new['run'].astype(str).str.zfill(2) + '-' + new['run_type'] + \
                    '_ev-' + new['ev'] + '-' + new['num'].astype(str).str.zfill(4)

                # dummy regressors _____________________________________________
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1, 'nifti_name'] = list(n_list)
                new['sub'] = sub_num
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'ses'] = ses_num
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'run'] = run_num
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'run_type'] = run_type
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'regressor'] = False
                subject_dataframe = pd.concat([subject_dataframe, new])
            else:
                break
        elif run_type == 'pain' and fname.endswith('events.tsv'):
            # open behavio fram and add average seconds to dataframe.
            df = pd.DataFrame()
            df = pd.read_csv(fpath, sep = '\t')
            cue_num = len(df['event01_cue_onset'])
            trial_num = len(df['event03_stimulus_displayonset']) 
            nuissance_fname = join(fmriprep_dir, sub, f"ses-{ses_num:02d}", 'func', f"{sub}_ses-{ses_num:02d}_task-social_acq-mb8_run-{run_num}_desc-confounds_timeseries.tsv")
            if os.path.exists(nuissance_fname):
                C = pd.read_csv(nuissance_fname, sep = '\t')
                trans = list(C.loc[:, C.columns.str.startswith('trans_')].columns)
                rot = list(C.loc[:, C.columns.str.startswith('rot_')].columns)
                spike = list(C.loc[:, C.columns.str.startswith('motion_outlier')].columns)
                C['spike_1col'] = C[spike].sum(axis = 1)
                nuissance = [trans, rot, ['spike_1col', 'dummy', 'csf']]
                n_list = [item for sublist in nuissance for item in sublist]
                nuissance_num = len(n_list) 
                new = pd.DataFrame(
                    index = range(cue_num + trial_num + nuissance_num + 1),
                    columns=['nifti_name','sub','ses','run','run_type','ev','num',
                    'onset','dur','mod','regressor',
                    'cue_type', 'stim_type','expect_rating','actual_rating','cue_con', 'stim_lin', 'stim_quad'])
                df['adjust_event03_stimulus'] = df['event03_stimulus_displayonset'] + 3.5
                # CUE event fill in parameters for CUE event ____________________________________________
                new = _event_sort(df,new, 
                ind_first = 0, 
                ev = 'event01_cue_onset', 
                ev_name = 'cue', 
                dur = 1, mod = 1, 
                regressor = True, 
                cue_type = list(df.param_cue_type), 
                stim_type = list(df.param_stimulus_type))

                # STIM fill in parameters for STIM event _____________________________________________
                new = _event_sort(df,new, 
                ind_first = trial_num, 
                ev = 'adjust_event03_stimulus', 
                ev_name = 'stim', 
                dur = 5, mod = 1, 
                regressor = True, 
                cue_type = list(df.param_cue_type), 
                stim_type = list(df.param_stimulus_type))
                
                        # Rating information ________________________________________________________________
                new.loc[0:cue_num+trial_num-1, 'expect_rating'] = list(pd.concat([df['event02_expect_angle']]*2, ignore_index=True))
                new.loc[0:cue_num+trial_num-1, 'actual_rating'] = list(pd.concat([df['event04_actual_angle']]*2, ignore_index=True))

                rating = pd.concat( [df.event02_expect_displayonset, df.event04_actual_displayonset])
                rt = pd.concat( [df.event02_expect_RT, df.event04_actual_RT]).reset_index(drop = True)
                rt.fillna(4, inplace = True)
                rating.sort_values(ascending = True, inplace = True, ignore_index=True)
                new.loc[cue_num+trial_num, 'onset'] = list(rating.repeat(2).reset_index(drop = True))
                new.loc[cue_num+trial_num, 'ev'] = 'rating'
                new.loc[cue_num+trial_num, 'dur'] = list(rt)
                new.loc[cue_num+trial_num, 'mod'] = 1
                new.loc[cue_num+trial_num, 'regressor'] = False

                matlab_rating = pd.concat([rating, rt], axis = 1)
                matlabname = f'{sub}_ses-{ses_num:02d}_run-{run_num:02d}_covariate-circularrating.csv'
                matlab_rating.to_csv(join(single_dir, sub, matlabname), index = False, header = ['rating', 'rt'] ) #sub-####_ses-##_run-##_event-rating.csv

                # parameter information for each single trial ________________________________________________________________
                new.loc[0:cue_num+trial_num-1,'cue_con'] = pd.concat([df['param_cue_type'].map(dict_cue)]*2, ignore_index=True)
                new.loc[0:cue_num+trial_num-1,'stim_lin'] = pd.concat([df['param_stimulus_type'].map(dict_stim)]*2, ignore_index=True)
                new.loc[0:cue_num+trial_num-1,'stim_quad'] = pd.concat([df['param_stimulus_type'].map(dict_stim_q)]*2, ignore_index=True)
                
                new['sub'] = sub_num
                new['ses'] = ses_num
                new['run'] = run_num
                new['run_type'] = 'pain-ptb'

                # filename build string e.g. sub-0005_ses-04_run-06-pain_ev-stim-0011.nii.gz
                new['nifti_name'] = 'sub-' + new['sub'].astype(str).str.zfill(4) + \
                '_ses-' + new['ses'].astype(str).str.zfill(2) + \
                '_run-' + new['run'].astype(str).str.zfill(2) + '-' + new['run_type'] + \
                    '_ev-' + new['ev'] + '-' + new['num'].astype(str).str.zfill(4)

                # dummy regressors _____________________________________________
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1, 'nifti_name'] = list(n_list)
                new['sub'] = sub_num
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'ses'] = ses_num
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'run'] = run_num
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'run_type'] = run_type
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'regressor'] = False
                subject_dataframe = pd.concat([subject_dataframe, new])
            else:
                break
        elif bool(run_type == 'vicarious') or bool(run_type == 'cognitive'):
            df = pd.DataFrame()
            df = pd.read_csv(fpath, sep = '\t')

            cue_num = len(df['event01_cue_onset'])
            trial_num = len(df['event03_stimulus_displayonset']) 
            nuissance_fname = join(fmriprep_dir, sub, f"ses-{ses_num:02d}", 'func', f"{sub}_ses-{ses_num:02d}_task-social_acq-mb8_run-{run_num}_desc-confounds_timeseries.tsv")
            if os.path.exists(nuissance_fname):
                C = pd.read_csv(nuissance_fname, sep = '\t')
                trans = list(C.loc[:, C.columns.str.startswith('trans_')].columns)
                rot = list(C.loc[:, C.columns.str.startswith('rot_')].columns)
                spike = list(C.loc[:, C.columns.str.startswith('motion_outlier')].columns)
                C['spike_1col'] = C[spike].sum(axis = 1)
                nuissance = [trans, rot, ['spike_1col', 'dummy', 'csf']]
                n_list = [item for sublist in nuissance for item in sublist]
                nuissance_num = len(n_list) 
                new = pd.DataFrame(
                    index = range(cue_num + trial_num + nuissance_num + 1),
                    columns=['nifti_name','sub','ses','run','run_type','ev','num',
                    'onset','dur','mod','regressor',
                    'cue_type', 'stim_type','expect_rating','actual_rating','cue_con', 'stim_lin', 'stim_quad'])

                # CUE event fill in parameters for CUE event ____________________________________________
                new = _event_sort(df,new, 
                ind_first = 0, 
                ev = 'event01_cue_onset', 
                ev_name = 'cue', 
                dur = 1, mod = 1, 
                regressor = True, 
                cue_type = list(df.param_cue_type), 
                stim_type = list(df.param_stimulus_type))

                # STIM fill in parameters for STIM event _____________________________________________
                new = _event_sort(df,new, 
                ind_first = trial_num, 
                ev = 'event03_stimulus_displayonset', 
                ev_name = 'stim', 
                dur = 5, mod = 1, 
                regressor = True, 
                cue_type = list(df.param_cue_type), 
                stim_type = list(df.param_stimulus_type))
                # Rating information ________________________________________________________________
                new.loc[0:cue_num+trial_num-1, 'expect_rating'] = list(pd.concat([df['event02_expect_angle']]*2, ignore_index=True))
                new.loc[0:cue_num+trial_num-1, 'actual_rating'] = list(pd.concat([df['event04_actual_angle']]*2, ignore_index=True))

                rating = pd.concat( [df.event02_expect_displayonset, df.event04_actual_displayonset])
                rt = pd.concat( [df.event02_expect_RT, df.event04_actual_RT]).reset_index(drop = True)
                rt.fillna(4, inplace = True)
                rating.sort_values(ascending = True, inplace = True, ignore_index=True)
                new.loc[cue_num+trial_num, 'onset'] = list(rating.repeat(2).reset_index(drop = True))
                new.loc[cue_num+trial_num, 'ev'] = 'rating'
                new.loc[cue_num+trial_num, 'dur'] = list(rt)
                new.loc[cue_num+trial_num, 'mod'] = 1
                new.loc[cue_num+trial_num, 'regressor'] = False

                matlab_rating = pd.concat([rating, rt], axis = 1)
                matlabname = f'{sub}_ses-{ses_num:02d}_run-{run_num:02d}_covariate-circularrating.csv'
                matlab_rating.to_csv(join(single_dir, sub, matlabname), index = False, header = ['rating', 'rt'] ) #sub-####_ses-##_run-##_event-rating.csv

                # parameter information for each single trial ________________________________________________________________
                new.loc[0:cue_num+trial_num-1,'cue_con'] = pd.concat([df['param_cue_type'].map(dict_cue)]*2, ignore_index=True)
                new.loc[0:cue_num+trial_num-1,'stim_lin'] = pd.concat([df['param_stimulus_type'].map(dict_stim)]*2, ignore_index=True)
                new.loc[0:cue_num+trial_num-1,'stim_quad'] = pd.concat([df['param_stimulus_type'].map(dict_stim_q)]*2, ignore_index=True)
                
                new['sub'] = sub_num
                new['ses'] = ses_num
                new['run'] = run_num
                new['run_type'] = run_type

                # filename build string e.g. sub-0005_ses-04_run-06-pain_ev-stim-0011.nii.gz
                new['nifti_name'] = 'sub-' + new['sub'].astype(str).str.zfill(4) + \
                '_ses-' + new['ses'].astype(str).str.zfill(2) + \
                '_run-' + new['run'].astype(str).str.zfill(2) + '-' + new['run_type'] + \
                    '_ev-' + new['ev'] + '-' + new['num'].astype(str).str.zfill(4)

                # dummy regressors _____________________________________________
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1, 'nifti_name'] = list(n_list)
                new['sub'] = sub_num
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'ses'] = ses_num
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'run'] = run_num
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'run_type'] = run_type
                new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'regressor'] = False

                # subject_dataframe = subject_dataframe.append(new)
                subject_dataframe = pd.concat([subject_dataframe, new])
            else:
                break
    subject_dataframe.reset_index(inplace = True)
    subject_dataframe.to_csv(join(single_dir,sub,f'{sub}_singletrial_{keyword}.csv'))
