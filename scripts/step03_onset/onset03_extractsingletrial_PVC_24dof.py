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
from os.path import join
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
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'onset'] = df[ev] 
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'ev'] = ev_name
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'dur'] = dur
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'mod'] = mod
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'regressor'] = regressor
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'num'] = list(range(len(df[ev])))
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'cue_type'] = cue_type
    new_df.loc[ind_first: ind_first+len(df[ev])-1, 'stim_type'] = stim_type
    return new_df
# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
main_dir = '/Volumes/spacetop_projects_social'
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social'
beh_dir = join(main_dir, 'data','beh', 'beh02_preproc')
fsl_dir = join(main_dir, 'data', 'd03_onset', 'onset01_FSL')
spm_dir = join(main_dir, 'data', 'd03_onset', 'onset02_SPM')
single_dir = join(main_dir, 'data','d03_onset','onset03_SPMsingletrial_24dof')
fmriprep_dir = join('/Volumes/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep')
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/fmriprep'
dict_cue = {'low_cue':-1, 'high_cue':1}
dict_stim = {'low_stim':-1, 'med_stim':0, 'high_stim':1}
dict_stim_q = {'low_stim':1, 'med_stim':-2, 'high_stim':1}
# %%
sub_folders = next(os.walk(beh_dir))[1]
sub_folder = [i for i in sub_folders if i.startswith('sub-')]
remove_int = [1,2,3,4,5]
remove_list = [f"sub-{x:04d}" for x in remove_int]
sub_list = [i for i in sub_folder if i not in remove_list]

for sub in sorted(sub_list):
    beh_list = []
    beh_list = glob.glob(join(spm_dir, sub, '*','*_events.tsv'))
    subject_dataframe = pd.DataFrame([])
    for ind, fpath in enumerate(sorted(beh_list)):
        fname = os.path.basename(fpath)
        entities = dict(
                match.split('-', 1)
                for match in fname.split('_')
                if '-' in match
                )
        
        df = pd.DataFrame()
        df = pd.read_csv(fpath, sep = '\t')
        sub_num = int(entities['sub'])
        ses_num = int(entities['ses'])
        run_num = int(entities['run'].split('-')[0])
        run_type = entities['run'].split('-')[-1]
        
        Path(join(single_dir, sub)).mkdir(parents=True, exist_ok=True)

        cue_num = len(df.event01_cue_onset)
        trial_num = len(df.event03_stimulus_displayonset) 
        #  TODO: load fmriprep nuissance tsv file. 
        # TODO: figure out how many columns it has. then insert the column names
        nuissance_fname = join(fmriprep_dir, sub, f"ses-{ses_num:02d}", 'func', f"{sub}_ses-{ses_num:02d}_task-social_acq-mb8_run-{run_num}_desc-confounds_timeseries.tsv")
        if os.path.exists(nuissance_fname):
            C = pd.read_csv(nuissance_fname, sep = '\t')
            # C.loc[:, C.columns.str.startswith('motion_outlier')].columns
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
            _event_sort(df,new, 
            ind_first = 0, 
            ev = 'event01_cue_onset', 
            ev_name = 'cue', 
            dur = 1, mod = 1, 
            regressor = True, 
            cue_type = list(df.param_cue_type), 
            stim_type = list(df.param_stimulus_type))

            # STIM fill in parameters for STIM event _____________________________________________
            _event_sort(df,new, 
            ind_first = cue_num, 
            ev = 'event03_stimulus_displayonset', 
            ev_name = 'stim', 
            dur = 5, mod = 1, 
            regressor = True, 
            cue_type = list(df.param_cue_type), 
            stim_type = list(df.param_stimulus_type))

            # expect actual rating ________________________________________________________________
            new.loc[0:cue_num+trial_num-1, 'expect_rating'] = list(pd.concat([df.event02_expect_angle]*2, ignore_index=True))
            new.loc[0:cue_num+trial_num-1, 'actual_rating'] = list(pd.concat([df.event04_actual_angle]*2, ignore_index=True))

            # RATING fill in parameters for STIM event ____________________________________________
            # trial_num = len(df.ISI03_onset - df.param_trigger_onset) 
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

            new.loc[0:cue_num+trial_num-1,'cue_con'] = pd.concat([df['param_cue_type'].map(dict_cue)]*2, ignore_index=True)
            new.loc[0:cue_num+trial_num-1,'stim_lin'] = pd.concat([df['param_stimulus_type'].map(dict_stim)]*2, ignore_index=True)
            new.loc[0:cue_num+trial_num-1,'stim_quad'] = pd.concat([df['param_stimulus_type'].map(dict_stim_q)]*2, ignore_index=True)
            #
            new['sub'] = sub_num
            new['ses'] = ses_num
            new['run'] = run_num
            new['run_type'] = run_type

            # filename build string e.g. sub-0005_ses-04_run-06-pain_ev-stim-0011.nii.gz
            new['nifti_name'] = 'sub-' + new['sub'].astype(str).str.zfill(4) + \
            '_ses-' + new['ses'].astype(str).str.zfill(2) + \
            '_run-' + new['run'].astype(str).str.zfill(2) + '-' + new['run_type'] + \
                '_ev-' + new['ev'] + '-' + new['num'].astype(str).str.zfill(4)
            # print(f"sub-{new.sub:04d}_ses-{new['ses']:02d}_run-{new['run']:02d}*.nii.gz")

            # dummy regressors _____________________________________________
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1, 'nifti_name'] = list(n_list)
            new['sub'] = sub_num
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'ses'] = ses_num
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'run'] = run_num
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'run_type'] = run_type
            new.loc[cue_num+trial_num+1:cue_num+trial_num+nuissance_num+1,'regressor'] = False
            subject_dataframe = subject_dataframe.append(new)
        else:
            break

    subject_dataframe.reset_index(inplace = True)
    subject_dataframe.to_csv(join(single_dir, sub,  f'{sub}_singletrial.csv'), index = False)
