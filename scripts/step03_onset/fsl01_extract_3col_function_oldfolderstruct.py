#!/usr/bin/env python
# encoding: utf-8
# %% libraries ________________________________________________________________________
import pandas as pd
import os, glob
import pdb
from pathlib import Path
import itertools

"""
onset01_extract_three_column.py
# get behavioral files from "beh02_preproc"
# subtract from trigger onset
# extract regressors:
# extract task name:
"""
# __author__ = "Heejung Jung"
# __version__ = "1.0.1"
# __email__ = "heejung.jung@colorado.edu"
# __status__ = "Production"


# %% functions ____
def _ev_pandas(empty_df, df, col_onset, col_dur, col_mod, txt_fname, label):
    # NumberTypes = (types.IntType, types.LongType, types.FloatType, types.ComplexType)
    empty_df['onset'] = df[col_onset] - df['param_trigger_onset']
    if isinstance(col_dur, str):
        empty_df['dur'] = df[col_dur]
    elif isinstance(col_dur, (int, long, float, complex)):
        empty_df['dur'] = col_dur
    # if isinstance(col_mod, str):
        # empty_df['mod'] = df[col_mod]
    if isinstance(col_mod, (int, long, float, complex)):
        empty_df['mod'] = col_mod
    else:
        empty_df['mod'] = col_mod
    # empty_df['mod'] = col_mod
    save_fname = os.path.join(fsl_dir, sub, ses, label+txt_fname)
    empty_df.to_csv(save_fname, header=None, index=None, sep='\t')
    # return(empty_df)


# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social

beh_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd02_preprocessed')
fsl_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd03_EV_FSL')
spm_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd04_EV_SPM')

# %%
# sub_list = [2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25,26,28,29]
sub_list = next(os.walk(beh_dir))[1]
ses_list = [1,3,4]
sub_ses = list(itertools.product(sub_list, ses_list))
for i, (sub, ses_ind) in enumerate(sub_ses):
    print( sub, ses_ind)
    # sub = 'sub-{:04d}'.format(sub_ind)
    ses = 'ses-{:02d}'.format(ses_ind)
    beh_list = glob.glob(os.path.join(beh_dir, sub, ses,'*_beh.csv'))
    Path(os.path.join(fsl_dir, sub, ses)).mkdir(parents=True, exist_ok=True)
    Path(os.path.join(spm_dir, sub, ses)).mkdir(parents=True, exist_ok=True)

    #FILENAME = os.path.join(beh_dir, sub, ses, 'sub-' + 'ses-' + 'task-*' + 'run-*' )
    for ind, fpath in enumerate(beh_list):
        fname = os.path.basename(fpath)
        tasktype = fname.split('_')[2]
        runtype = fname.split('_')[3]

        label = "_".join(fname.split('_')[0:4] )

        df = pd.read_csv(fpath)

        # dictionary:
        dict_cue = {'low_cue':-1, 'high_cue':1}
        dict_stim = {'low_stim':-1, 'med_stim':0, 'high_stim':1}
        dict_stim_q = {'low_stim':1, 'med_stim':-2, 'high_stim':1}
        dict_col = {
        'event01_cue_onset': 'onset01_cue',
        'event02_expect_displayonset': 'onset02_ratingexpect',
        'event03_stimulus_displayonset': 'onset03_stim',
        'event04_actual_displayonset': 'onset04_ratingactual',
        'param_cue_type': 'pmod_cue_type',
        'param_stimulus_type': 'pmod_stim_type',
        'event02_expect_RT': 'pmod_expect_RT',
        'event02_expect_angle': 'pmod_expect_angle',
        'event04_actual_RT': 'pmod_actual_RT',
        'event04_actual_angle': 'pmod_actual_angle'
        }
        trigger = df['param_trigger_onset'][0]

        # 1. directories ________________________________________________________________________

        # I. create dataframe for datalad
        datalad_df = df[['event01_cue_onset','event02_expect_displayonset',
        'event03_stimulus_displayonset','event04_actual_displayonset']]
        # or I could do: datalad_df = df.filter(like='event')
        datalad = datalad_df - df['param_trigger_onset'][0]
        datalad = pd.concat([datalad, df[['param_cue_type','param_stimulus_type',
        'event02_expect_RT','event02_expect_angle',
        'event04_actual_RT', 'event04_actual_angle']]], axis = 1)
        datalad['cue_con'] = datalad['param_cue_type'].map(dict_cue)
        datalad['stim_lin'] = datalad['param_stimulus_type'].map(dict_stim)
        datalad['stim_quad'] = datalad['param_stimulus_type'].map(dict_stim_q)

        # save angle, RT in a separate tab
        # ANGLE: 1) demean , 2) for NA value, assign value of 0. this works for the parametric modulator
        # RT: if RT or angle is empty with a NA value, fill in duration as 4s ("time to rate")
        datalad[['event02_expect_angle', 'event04_actual_angle']] = datalad[['event02_expect_angle', 'event04_actual_angle']].transform(lambda df: df - df.mean())
        datalad[['event02_expect_angle', 'event04_actual_angle']] = datalad[['event02_expect_angle', 'event04_actual_angle']].fillna(0).copy()
        datalad[['event02_expect_RT', 'event04_actual_RT']] = datalad[['event02_expect_RT', 'event04_actual_RT']].fillna(4).copy()

        datalad.rename(dict_col, inplace = True)
        datalad_fname = os.path.join(spm_dir, sub, ses, label+'_events.tsv' )
        datalad.to_csv(datalad_fname, index=None,sep='\t')
        # II. create EV ________________________________________________________________________
        # column 1: onset, column 2: duration, column 3: value of the input during period (parametric modulator)



        #onset
        # 1. CUE ______________________
        # 1-1. CUE onset only
        #pdb.set_trace()
        ev_cue_onset_only = pd.DataFrame()
        _ev_pandas(ev_cue_onset_only, df, 
        'event01_cue_onset', 1, 1, '_EV01-CUE_onsetonly.txt', label)
        # ev_cue_onset_only['onset'] = df['event01_cue_onset'] - df['param_trigger_onset'] #CUE;
        # ev_cue_onset_only['dur'] = 1
        # ev_cue_onset_only['mod'] = 1
        # fname_1_1 = os.path.join(fsl_dir, sub, ses, label+'_EV01-CUE_onsetonly.txt')
        # ev_cue_onset_only.to_csv(fname_1_1, header=None, index=None, sep='\t')
        

        # 1-2. CUE modulated with cue type
        ev_cue_pmod_cue = pd.DataFrame()
        _ev_pandas(ev_cue_pmod_cue, df, 
        'event01_cue_onset', 1, df['param_cue_type'].map(dict_cue), 
        '_EV01-CUE_pmod-cue.txt', label)
        # ev_cue_pmod_cue['onset'] = df['event01_cue_onset'] - df['param_trigger_onset'] #CUE;
        # ev_cue_pmod_cue['dur'] = 1
        # ev_cue_pmod_cue['mod'] = df['param_cue_type'].map(dict_cue)
        # fname_1_2 = os.path.join(fsl_dir, sub, ses, label+'_EV01-CUE_pmod-cue.txt')
        # ev_cue_pmod_cue.to_csv(fname_1_2, header=None, index=None, sep='\t', mode='w')

        # 1-3. CUE modulated with cue type
        ev_cue_pmod_expect = pd.DataFrame()
        _ev_pandas(ev_cue_pmod_expect, df, 
        'event01_cue_onset', 1, df['event02_expect_angle'], 
        '_EV01-CUE_pmod-expect.txt', label)
        # ev_cue_pmod_expect['onset'] = df['event01_cue_onset'] - df['param_trigger_onset'] #CUE;
        # ev_cue_pmod_expect['dur'] = 1
        # ev_cue_pmod_expect['mod'] = df['event02_expect_angle']
        # fname_1_3 = os.path.join(fsl_dir, sub, ses, label+'_EV01-CUE_pmod-expect.txt')
        # ev_cue_pmod_expect.to_csv(fname_1_3, header=None, index=None, sep='\t', mode='w')

        # 2. RATING EXPECT ______________________ DUR: RT
        # 2-1. RATING onset only
        ev_expect_onset_only = pd.DataFrame()
        _ev_pandas(ev_expect_onset_only, df, 
        'event02_expect_displayonset', 'event02_expect_RT', 1, 
        '_EV02-EXPECT_onsetonly.txt', label)
        # ev_expect_onset_only['onset'] = df['event02_expect_displayonset'] - df['param_trigger_onset'] #CUE;
        # ev_expect_onset_only['dur'] = df['event02_expect_RT']
        # ev_expect_onset_only['mod'] = 1
        # fname_2_1 = os.path.join(fsl_dir, sub, ses, label+'_EV02-EXPECT_onsetonly.txt')
        # ev_expect_onset_only.to_csv(fname_2_1, header=None, index=None, sep='\t', mode='w')

        # 3. STIM ___________________________________________________________________________
        # 3-1. stim x 5s x no pmod
        ev_stim_onset_only = pd.DataFrame()
        _ev_pandas(ev_stim_onset_only, df, 
        'event03_stimulus_displayonset', 5, 1, 
        '_EV03-STIM_onsetonly.txt', label)
        # ev_stim_onset_only['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] #CUE;
        # ev_stim_onset_only['dur'] = 5
        # ev_stim_onset_only['mod'] = 1
        # fname_3_1 = os.path.join(fsl_dir, sub, ses, label+'_EV03-STIM_onsetonly.txt')
        # ev_stim_onset_only.to_csv(fname_3_1, header=None, index=None, sep='\t', mode='w')

        # 3-2. stim x 5s x cue
        ev_stim_pmod_cue = pd.DataFrame()
        _ev_pandas(ev_stim_pmod_cue, df, 
        'event03_stimulus_displayonset', 5, 1, 
        '_EV03-STIM_onsetonly.txt', label)
        ev_stim_pmod_cue['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] #CUE;
        ev_stim_pmod_cue['dur'] = 5
        ev_stim_pmod_cue['mod'] = df['param_cue_type'].map(dict_cue)
        fname_3_2 = os.path.join(fsl_dir, sub, ses, label+'_EV03-STIM_pmod-cue.txt')
        ev_stim_pmod_cue.to_csv(fname_3_2, header=None, index=None, sep='\t', mode='w')

        # 3-3. stim x 5s x actual rating
        ev_stim_pmod_actual = pd.DataFrame()
        ev_stim_pmod_actual['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] #CUE;
        ev_stim_pmod_actual['dur'] = 5
        ev_stim_pmod_actual['mod'] = df['event04_actual_angle']
        fname_3_3 = os.path.join(fsl_dir, sub, ses, label+'_EV03-STIM_pmod-actual.txt')
        ev_stim_pmod_actual.to_csv(fname_3_3, header=None, index=None, sep='\t', mode='w')

        # 3-4. stim x 5s x expect rating
        ev_stim_pmod_expect = pd.DataFrame()
        ev_stim_pmod_expect['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] #CUE;
        ev_stim_pmod_expect['dur'] = 5
        ev_stim_pmod_expect['mod'] = df['event02_expect_angle']
        fname_3_4 = os.path.join(fsl_dir, sub, ses, label+'_EV03-STIM_pmod-expect.txt')
        ev_stim_pmod_expect.to_csv(fname_3_4, header=None, index=None, sep='\t', mode='w')

        # 3-5. stim x 5s x stimulus intensity level
        ev_stim_pmod_stim = pd.DataFrame()
        ev_stim_pmod_stim['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] #CUE;
        ev_stim_pmod_stim['dur'] = 5
        ev_stim_pmod_stim['mod'] = df['param_stimulus_type'].map(dict_stim)
        fname_3_5 = os.path.join(fsl_dir, sub, ses, label+'_EV03-STIM-pmod-level.txt')
        ev_stim_pmod_expect.to_csv(fname_3_5, header=None, index=None, sep='\t', mode='w')


        # 4. RATING ACTUAL __________________________________________________________________
        # 4-1. RATING onset only
        ev_expect_onset_only = pd.DataFrame()
        ev_expect_onset_only['onset'] = df['event04_actual_displayonset'] - df['param_trigger_onset'] #CUE;
        ev_expect_onset_only['dur'] = df['event04_actual_RT']
        ev_expect_onset_only['mod'] = 1
        fname_4_1 = os.path.join(fsl_dir, sub, ses, label+'_EV04-ACTUAL-onsetonly.txt')
        ev_expect_onset_only.to_csv(fname_4_1, header=None, index=None, sep='\t', mode='w')




# 'event01_cue_onset'
# 'event02_expect_displayonset' #RATING EXPECT
# 'event03_stimulus_displayonset' #STIM
# 'event04_actual_displayonset' #RATING ACTUAL
#
# #Parametric modulator
# 'param_cue_type' #Cue contrast
# 'param_stim_type'
# 'event02_expect_RT'
# 'event02_expect_angle'
# 'event04_actual_RT'
# 'event04_actual_angle'
#
#
#
#
# ev_cue = pain['event01_cue_onset'] #CUE
# VARIABLE version
