#!/usr/bin/env python
# encoding: utf-8
# %% libraries ________________________________________________________________________
import pandas as pd
import os, glob
import pdb
from pathlib import Path
import itertools
from datetime import datetime
import traceback

"""fsl01_extract_three_column_ttl.py
This file integrates the behavioral onsets, in conjunction with the TTL onsets, 
extracted from biopac acquisition files

1. identify the intersection of biopac and behavioral data
2. within d03_EV_FSL, save additional 3 column text files
3. within d04_EV_SPM, insert TTL information and save as .tsv file

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
    new_df['onset'] = df[onset_col] 

    if isinstance(dur_col, str):
        new_df['dur'] = df[dur_col]
    else:
        new_df['dur'] = dur_col
    if isinstance(mod_col, str):
        if dict_map:
            new_df['mod'] = df[mod_col].map(dict_map['dict_map'])
        else:
            new_df['mod'] = df[mod_col]
    else:
        new_df['mod'] = mod_col
    new_df.to_csv(fname, header = None, index = None, sep='\t', mode='w')


# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
print("\nscript directory is: {0}".format(current_dir))
print("\ntop directory is: {0}".format(main_dir))
csv_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd02_preprocessed')
ev_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd03_EV_FSL')
ev_bids_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd04_EV_SPM')
# biopac directory is outside of social influence repository. Set accordingly
biopac_ttl_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/biopac/dartmouth/b03_extract_ttl/'
log_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/scripts/step03_onset/flag'

# %%  identify subjects with biopac data, remove unwanted subjects
biopac_list = next(os.walk(biopac_ttl_dir))[1]
remove_int = [1,2,3,4,5]
remove_list = [f"sub-{x:04d}" for x in remove_int]
sub_list = [x for x in biopac_list if x != remove_list]
ses_list = [1,3,4]
sub_ses = list(itertools.product(sorted(sub_list), ses_list))

date = datetime.now().strftime("%m/%d/%Y")
textfile = open(os.path.join(log_dir, "flag_{date}.txt"), "w")
textfile.write("this file contains anomalies from biopac-extracted TTL data and behavioral data\n" )
textfile.write("it raises a flag if biopac data doesn't match behavioral data\n" )

# %%
flag = []
for i, (sub, ses_ind) in enumerate(sub_ses):
    try:
        print( sub, ses_ind)
        ses = f"ses-{ses_ind:02d}"
        biopac_list = glob.glob(os.path.join(biopac_ttl_dir, sub, ses, 'task-social', '*ttl.csv'))
        #################
        # STOP: TODO: 02/03/2022
        # x write code so that glob biopac file list first
        # x from that, identify matching behavioral list
        # x from that, open behavioal list and ttl list
        # x merge and save to dataframe -> SPM
        # x separately save as txt files -> FSL

        # beh_list = glob.glob(os.path.join(csv_dir, sub, ses,'*_beh.csv'))
        Path(os.path.join(ev_dir, sub, ses)).mkdir(parents=True, exist_ok=True)
        Path(os.path.join(ev_bids_dir, sub, ses)).mkdir(parents=True, exist_ok=True)

        #FILENAME = os.path.join(csv_dir, sub, ses, 'sub-' + 'ses-' + 'task-*' + 'run-*' )
        for ind, bio_fpath in enumerate(biopac_list):
            # example: sub-0029_ses-04_task-social_run-01_physio-ttl.csv
            # based on biopac run info, find corresponding behavioral file
            bio_fname = os.path.basename(bio_fpath)
            run = bio_fname.split('_')[3]
            biopac_df = pd.read_csv(bio_fpath)
            

            # load behavioral data
            beh_fpath = glob.glob(os.path.join(csv_dir, sub, ses,  f"{sub}_{ses}_task-social_{run}-*_beh.csv"))
            beh_fname = os.path.basename(beh_fpath[0])
            run_type = beh_fname.split('_')[3]
            label = "_".join(beh_fname.split('_')[0:4])
            # IF loop 1) CHECK that run type is "pain"
            if 'pain' in run_type:
                df = pd.read_csv(beh_fpath[0])
            
                # dictionary:
                dict_cue = {'low_cue':-1, 'high_cue':1}
                dict_stim = {'low_stim':-1, 'med_stim':0, 'high_stim':1}
                dict_stim_q = {'low_stim':1, 'med_stim':-2, 'high_stim':1}
                dict_col = {
                'event01_cue_onset': 'onset01_cue',
                'event02_expect_displayonset': 'onset02_ratingexpect',
                'event03_stimulus_displayonset': 'onset03_stim',
                'ttl_1':'TTL1',
                'ttl_2':'TTL2',
                'ttl_3':'TTL3',
                'ttl_4':'TTL4',
                'early':'onset03_stim_earlyphase_0-4500ms', # duration of 4.5s
                'late': 'onset03_stim_latephase_4500-9000ms', # duration of 4.5s
                'poststim':'onset03_stim_poststim_9000-135000ms', # duration of 4.5s
                'ttl_plateau':'onset03_stim_ttl-plateau', # calculate duration 
                'plateau_dur':'onset03_stim_ttl-plateau-dur',
                'event04_actual_displayonset': 'onset04_ratingactual',
                'param_cue_type': 'pmod_cue_type',
                'param_stimulus_type': 'pmod_stim_type',
                'event02_expect_RT': 'pmod_expect_RT',
                'event02_expect_angle_demean': 'pmod_expect_angle_demean',
                'event04_actual_RT': 'pmod_actual_RT',
                'event04_actual_angle_demean': 'pmod_actual_angle_demean'
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
                datalad[['event02_expect_angle_demean', 'event04_actual_angle_demean']] = datalad[['event02_expect_angle', 'event04_actual_angle']].transform(lambda df: df - df.mean())
                datalad[['event02_expect_angle_demean', 'event04_actual_angle_demean']] = datalad[['event02_expect_angle', 'event04_actual_angle']].fillna(0).copy()
                datalad[['event02_expect_RT', 'event04_actual_RT']] = datalad[['event02_expect_RT', 'event04_actual_RT']].fillna(4).copy()

                # merge biopac and behavioral info
                mri_ttl = pd.concat([datalad, biopac_df[['ttl_1','ttl_2','ttl_3','ttl_4']]], axis=1, join="inner")
                # TODO: check if missing TTL matches _______________________________________________________________
                # df['event03_stimulus_P_trigger'] if successful: 'Command Recieved: TRIGGER_AND_Response: RESULT_OK'
                # if biopac_df
                # ________________________________________________________________________________________________
                mri_ttl['early'] = mri_ttl['ttl_1']
                mri_ttl['late'] = mri_ttl['ttl_1'] + 4.5
                mri_ttl['poststim'] = mri_ttl['ttl_1'] + 9
                mri_ttl['ttl_plateau'] = mri_ttl['ttl_2']
                mri_ttl['plateau_dur'] = mri_ttl['ttl_3'] - mri_ttl['ttl_2']
                # merge biopac data
                mri_ttl.rename(dict_col, axis='columns',inplace = True)
                mri_ttl_fname = os.path.join(ev_bids_dir, sub, ses, label+'_events_ttl.tsv' )
                mri_ttl.to_csv(mri_ttl_fname, index=None,sep='\t')
                # II. create EV ________________________________________________________________________
                # column 1: onset, column 2: duration, column 3: value of the input during period (parametric modulator)


                #onset
                # 1. CUE ______________________
                # 1-1. CUE onset only
                # ev_cue_onset_only = pd.DataFrame()
                # ev_cue_onset_only['onset'] = df['event01_cue_onset'] - df['param_trigger_onset'] #CUE;
                # ev_cue_onset_only['dur'] = 1
                # ev_cue_onset_only['mod'] = 1
                # fname_1_1 = os.path.join(ev_dir, sub, ses, label+'_EV01-CUE_onsetonly.txt')
                # ev_cue_onset_only.to_csv(fname_1_1, header=None, index=None, sep='\t')


                fname_11 = os.path.join(ev_dir, sub, ses, label+'_EV01-CUE_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset01_cue', dur_col=1, mod_col=1, fname=fname_11)
                
                # 1-2. CUE modulated with cue type
                # ev_cue_pmod_cue = pd.DataFrame()
                # ev_cue_pmod_cue['onset'] = df['event01_cue_onset'] - df['param_trigger_onset'] #CUE;
                # ev_cue_pmod_cue['dur'] = 1
                # ev_cue_pmod_cue['mod'] = df['param_cue_type'].map(dict_cue)
                # fname_1_2 = os.path.join(ev_dir, sub, ses, label+'_EV01-CUE_pmod-cue.txt')
                # ev_cue_pmod_cue.to_csv(fname_1_2, header=None, index=None, sep='\t', mode='w')

                fname_12 = os.path.join(ev_dir, sub, ses, label+'_EV01-CUE_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset01_cue', dur_col=1, fname=fname_12, mod_col = 'pmod_cue_type', dict_map = dict_cue)
                # 1-3. CUE modulated with cue type
                # ev_cue_pmod_expect = pd.DataFrame()
                # ev_cue_pmod_expect['onset'] = df['event01_cue_onset'] - df['param_trigger_onset'] #CUE;
                # ev_cue_pmod_expect['dur'] = 1
                # ev_cue_pmod_expect['mod'] = df['event02_expect_angle']
                # fname_1_3 = os.path.join(ev_dir, sub, ses, label+'_EV01-CUE_pmod-expect.txt')
                # ev_cue_pmod_expect.to_csv(fname_1_3, header=None, index=None, sep='\t', mode='w')
                fname_13 = os.path.join(ev_dir, sub, ses, label+'_EV01-CUE_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset01_cue', dur_col=1, mod_col='event02_expect_angle', fname=fname_13)

                # 2. RATING EXPECT ______________________ DUR: RT
                # 2-1. RATING onset only
                # ev_expect_onset_only = pd.DataFrame()
                # ev_expect_onset_only['onset'] = df['event02_expect_displayonset'] - df['param_trigger_onset'] #CUE;
                # ev_expect_onset_only['dur'] = df['event02_expect_RT']
                # ev_expect_onset_only['mod'] = 1
                # fname_2_1 = os.path.join(ev_dir, sub, ses, label+'_EV02-EXPECT_onsetonly.txt')
                # ev_expect_onset_only.to_csv(fname_2_1, header=None, index=None, sep='\t', mode='w')

                fname_2 = os.path.join(ev_dir, sub, ses, label+'_EV02-EXPECT_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset02_ratingexpect', dur_col='pmod_expect_RT', mod_col=1, fname=fname_2)
                
                # # 3. STIM :: expected time (2s after onset - 7s after onset) ___________________________________________________________________________
                # # 3-1. stim x 5s x no pmod
                # ev_stim_onset_only = pd.DataFrame()
                # ev_stim_onset_only['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] - 2;
                # ev_stim_onset_only['dur'] = 5
                # ev_stim_onset_only['mod'] = 1
                # fname_3_1 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM_onsetonly.txt')
                # ev_stim_onset_only.to_csv(fname_3_1, header=None, index=None, sep='\t', mode='w')
                # # 3-2. stim x 5s x cue
                # ev_stim_pmod_cue = pd.DataFrame()
                # ev_stim_pmod_cue['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] -2;
                # ev_stim_pmod_cue['dur'] = 5
                # ev_stim_pmod_cue['mod'] = df['param_cue_type'].map(dict_cue)
                # fname_3_2 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM_pmod-cue.txt')
                # ev_stim_pmod_cue.to_csv(fname_3_2, header=None, index=None, sep='\t', mode='w')

                # # 3-3. stim x 5s x actual rating
                # ev_stim_pmod_actual = pd.DataFrame()
                # ev_stim_pmod_actual['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] -2;
                # ev_stim_pmod_actual['dur'] = 5
                # ev_stim_pmod_actual['mod'] = df['event04_actual_angle']
                # fname_3_3 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM_pmod-actual.txt')
                # ev_stim_pmod_actual.to_csv(fname_3_3, header=None, index=None, sep='\t', mode='w')

                # # 3-4. stim x 5s x expect rating
                # ev_stim_pmod_expect = pd.DataFrame()
                # ev_stim_pmod_expect['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] -2;
                # ev_stim_pmod_expect['dur'] = 5
                # ev_stim_pmod_expect['mod'] = df['event02_expect_angle']
                # fname_3_4 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM_pmod-expect.txt')
                # ev_stim_pmod_expect.to_csv(fname_3_4, header=None, index=None, sep='\t', mode='w')

                # # 3-5. stim x 5s x stimulus intensity level
                # ev_stim_pmod_stim = pd.DataFrame()
                # ev_stim_pmod_stim['onset'] = df['event03_stimulus_displayonset'] - df['param_trigger_onset'] #CUE;
                # ev_stim_pmod_stim['dur'] = 5
                # ev_stim_pmod_stim['mod'] = df['param_stimulus_type'].map(dict_stim)
                # fname_3_5 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-pmod-level.txt')
                # ev_stim_pmod_expect.to_csv(fname_3_5, header=None, index=None, sep='\t', mode='w')
                

                    # return new_df
                    # STIM_onsetonly, STIM_pmod-cue, STIM_pmod-actual, STIM_pmod-expect, STIM-pmod-level
                # 3-1. stim x 5s x onset time only
                fname_311 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_onsetonly.txt')
                _build_evfile(df = mri_ttl, onset_col='onset03_stim', dur_col = 5, mod_col = 1, fname = fname_311)
                # 3-2. stim x 5s x cue type
                fname_312 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_pmod-cue.txt')
                _build_evfile(df = mri_ttl, onset_col='onset03_stim', dur_col = 5, mod_col = 'pmod_cue_type', fname = fname_312, dict_map = dict_cue)
                # 3-3. stim x 5s x actual rating
                fname_313 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_pmod-actual.txt')
                _build_evfile(df = mri_ttl, onset_col='onset03_stim', dur_col = 5, mod_col = 'pmod_actual_angle_demean', fname = fname_313)
                # 3-4. stim x 5s x expect rating
                fname_314 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_pmod_expect.txt')
                _build_evfile(df = mri_ttl, onset_col='onset03_stim', dur_col = 5, mod_col = 'pmod_expect_angle_demean', fname = fname_314)
                # 3-5. stim x 5s x stimulus intensity level
                fname_315 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim', dur_col=4.5, fname=fname_315, mod_col='pmod_stim_type', dict_map = dict_stim)
                
                # 2-1. stim x TTL early x onset time only           
                fname_321 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col=1, fname = fname_321)
                # 2-2. stim x TTL early x cue type
                fname_322 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col='pmod_cue_type', fname = fname_322, dict_map = dict_cue)
                # 2-3. stim x TTL early x actual rating
                fname_323 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_pmod-actual.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col='pmod_actual_angle_demean', fname = fname_323)
                # 2-4. stim x TTL early x expect rating
                fname_324 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_pmod_expect.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col='pmod_expect_angle_demean', fname = fname_324)
                # 2-5. stim x TTL early x onset time only
                fname_325 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col='pmod_stim_type', fname=fname_325, dict_map = dict_stim)
                
                # 3-1. stim x TTL late x onset time only           
                fname_331 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col=1, fname = fname_331)
                # 3-2. stim x TTL late x cue type
                fname_332 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col='pmod_cue_type', fname = fname_332, dict_map = dict_cue)
                # 3-3. stim x TTL late x actual rating
                fname_333 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_pmod-actual.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col='pmod_actual_angle_demean', fname = fname_333)
                # 3-4. stim x TTL late x expect rating
                fname_334 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_pmod_expect.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col='pmod_expect_angle_demean', fname = fname_334)
                # 3-5. stim x TTL late x onset time only
                fname_335 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col='pmod_stim_type', fname=fname_335, dict_map = dict_stim)
                

                # 4-1. stim x TTL post x onset time only           
                fname_341 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col=1, fname = fname_341)
                # 4-2. stim x TTL post x cue type
                fname_342 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col='pmod_cue_type', fname = fname_342, dict_map = dict_cue)
                # 4-3. stim x TTL post x actual rating
                fname_343 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_pmod-actual.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col='pmod_actual_angle_demean', fname = fname_343)
                # 4-4. stim x TTL post x expect rating
                fname_344 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_pmod_expect.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col='pmod_expect_angle_demean', fname = fname_344)
                # 4-5. stim x TTL post x onset time only
                fname_345 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col='pmod_stim_type', fname=fname_345, dict_map = dict_stim)
                

                # 5-1. stim x TTL plateau x onset time only           
                fname_351 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col=1, fname = fname_351)
                # 5-2. stim x TTL plateau x cue type
                fname_352 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col='pmod_cue_type', fname = fname_352, dict_map = dict_cue)
                # 5-3. stim x TTL plateau x actual rating
                fname_353 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_pmod-actual.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col='pmod_actual_angle_demean', fname = fname_353)
                # 5-4. stim x TTL plateau x expect rating
                fname_354 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_pmod_expect.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col='pmod_expect_angle_demean', fname = fname_354)
                # 5-5. stim x TTL plateau x onset time only
                fname_355 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col='pmod_stim_type', fname=fname_355, dict_map = dict_stim)
                

                # 4. RATING ACTUAL __________________________________________________________________
                # 4-1. RATING onset only
                fname_4 = os.path.join(ev_dir, sub, ses, label+'_EV04-ACTUAL-onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset04_ratingactual', dur_col='pmod_actual_RT', mod_col=1, fname=fname_4)
                
                # ev_expect_onset_only = pd.DataFrame()
                # ev_expect_onset_only['onset'] = df['event04_actual_displayonset'] - df['param_trigger_onset'] #CUE;
                # ev_expect_onset_only['dur'] = df['event04_actual_RT']
                # ev_expect_onset_only['mod'] = 1
                # fname_4_1 = os.path.join(ev_dir, sub, ses, label+'_EV04-ACTUAL-onsetonly.txt')
                # ev_expect_onset_only.to_csv(fname_4_1, header=None, index=None, sep='\t', mode='w')
    except:
        with open(os.path.join(log_dir, "flag_{date}.txt"), "a") as logfile:
            traceback.print_exc(file=logfile)

# # %%    # iIF loop 2) IF RUN TYPE NOT PAIN, raise a flag and save flag
#         elif 'pain' not in run_type:
#             flag.append(bio_fpath)

# save flags to separate folder __________________________________________________________________

# for element in flag:
#     textfile.write(element + "\n")
# textfile.close()
