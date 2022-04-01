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
ev_bids_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd06_singletrial_SPM')
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

date = datetime.now().strftime("%m-%d-%Y")
textfile = open(os.path.join(log_dir, f"flag_{date}.txt"), "w")
textfile.write("this file contains anomalies from biopac-extracted TTL data and behavioral data\n" )
textfile.write("it raises a flag if biopac data doesn't match behavioral data\n" )

# %%
flag = []
for i, (sub, ses_ind) in enumerate(sub_ses):
    try:
        print( sub, ses_ind)
        ses = f"ses-{ses_ind:02d}"
        biopac_list = glob.glob(os.path.join(biopac_ttl_dir, sub, ses, 'task-social', '*ttl.csv'))

        # beh_list = glob.glob(os.path.join(csv_dir, sub, ses,'*_beh.csv'))
        Path(os.path.join(ev_dir, sub, ses)).mkdir(parents=True, exist_ok=True)
        Path(os.path.join(ev_bids_dir, sub, ses)).mkdir(parents=True, exist_ok=True)

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
                # 'event01_cue_onset': 'onset01_cue',
                # 'event02_expect_displayonset': 'onset02_ratingexpect',
                # 'event03_stimulus_displayonset': 'onset03_stim',
                'ttl_1':'TTL1',
                'ttl_2':'TTL2',
                'ttl_3':'TTL3',
                'ttl_4':'TTL4',
                'early':'event03_stim_earlyphase_0-4500ms', # duration of 4.5s
                'late': 'event03_stim_latephase_4500-9000ms', # duration of 4.5s
                'poststim':'event03_stim_poststim_9000-135000ms', # duration of 4.5s
                'ttl_plateau':'event03_stim_ttl-plateau', # calculate duration 
                'plateau_dur':'event03_stim_ttl-plateau-dur',
                # 'event04_actual_displayonset': 'onset04_ratingactual',
                # 'param_cue_type': 'pmod_cue_type',
                # 'param_stimulus_type': 'pmod_stim_type',
                # 'event02_expect_RT': 'pmod_expect_RT',
                # 'event02_expect_angle_demean': 'pmod_expect_angle_demean',
                # 'event04_actual_RT': 'pmod_actual_RT',
                # 'event04_actual_angle_demean': 'pmod_actual_angle_demean'
                
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
                # 1-2. CUE modulated with cue type
                # 1-3. CUE modulated with cue type
                fname_11 = os.path.join(ev_dir, sub, ses, label+'_EV01-CUE_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset01_cue', dur_col=1, mod_col=1, fname=fname_11)

                fname_12 = os.path.join(ev_dir, sub, ses, label+'_EV01-CUE_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset01_cue', dur_col=1, fname=fname_12, mod_col = 'pmod_cue_type', dict_map = dict_cue)              

                fname_13 = os.path.join(ev_dir, sub, ses, label+'_EV01-CUE_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset01_cue', dur_col=1, mod_col='event02_expect_angle', fname=fname_13)

                # 2. RATING EXPECT ______________________ DUR: RT
                # 2-1. RATING onset only
                fname_2 = os.path.join(ev_dir, sub, ses, label+'_EV02-EXPECT_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset02_ratingexpect', dur_col='pmod_expect_RT', mod_col=1, fname=fname_2)
                
                # # 3. STIM :: expected time (2s after onset - 7s after onset) ___________________________________________________________________________
                    # STIM_onsetonly, STIM_pmod-cue, STIM_pmod-actual, STIM_pmod-expect, STIM-pmod-level
                # 3-1-1. stim x 5s x onset time only
                # 3-1-2. stim x 5s x cue type
                # 3-1-3. stim x 5s x actual rating
                # 3-1-4. stim x 5s x expect rating
                # 3-1-5. stim x 5s x stimulus intensity level
                fname_311 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_onsetonly.txt')
                _build_evfile(df = mri_ttl, onset_col='onset03_stim', dur_col = 5, mod_col = 1, fname = fname_311)
                
                fname_312 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_pmod-cue.txt')
                _build_evfile(df = mri_ttl, onset_col='onset03_stim', dur_col = 5, mod_col = 'pmod_cue_type', fname = fname_312, dict_map = dict_cue)
                
                fname_313 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_pmod-actual.txt')
                _build_evfile(df = mri_ttl, onset_col='onset03_stim', dur_col = 5, mod_col = 'pmod_actual_angle_demean', fname = fname_313)
                
                fname_314 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_pmod_expect.txt')
                _build_evfile(df = mri_ttl, onset_col='onset03_stim', dur_col = 5, mod_col = 'pmod_expect_angle_demean', fname = fname_314)
                
                fname_315 = os.path.join(ev_dir, sub, ses, label+'_EV03-STIM-EXPECTED-5s_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim', dur_col=4.5, fname=fname_315, mod_col='pmod_stim_type', dict_map = dict_stim)
                
                # 3-2-1. stim x TTL early x onset time only     
                # 3-2-2. stim x TTL early x cue type    
                # 3-2-3. stim x TTL early x actual rating  
                # 3-2-4. stim x TTL early x expect rating
                # 3-2-5. stim x TTL early x onset time only
                fname_321 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col=1, fname = fname_321)
                
                fname_322 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col='pmod_cue_type', fname = fname_322, dict_map = dict_cue)
                
                fname_323 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_pmod-actual.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col='pmod_actual_angle_demean', fname = fname_323)
                
                fname_324 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_pmod_expect.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col='pmod_expect_angle_demean', fname = fname_324)
                
                fname_325 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-EARLY_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_earlyphase_0-4500ms', dur_col=4.5, mod_col='pmod_stim_type', fname=fname_325, dict_map = dict_stim)
                
                # 3-3-1. stim x TTL late x onset time only
                # 3-3-2. stim x TTL late x cue type           
                # 3-3-3. stim x TTL late x actual rating
                # 3-3-4. stim x TTL late x expect rating
                # 3-3-5. stim x TTL late x onset time only
                fname_331 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col=1, fname = fname_331)
                
                fname_332 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col='pmod_cue_type', fname = fname_332, dict_map = dict_cue)
                
                fname_333 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_pmod-actual.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col='pmod_actual_angle_demean', fname = fname_333)
                
                fname_334 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_pmod_expect.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col='pmod_expect_angle_demean', fname = fname_334)
                
                fname_335 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-LATE_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_latephase_4500-9000ms', dur_col=4.5, mod_col='pmod_stim_type', fname=fname_335, dict_map = dict_stim)
                

                # 3-4-1. stim x TTL post x onset time only   
                # 3-4-2. stim x TTL post x cue type 
                # 3-4-3. stim x TTL post x actual rating  
                # 3-4-4. stim x TTL post x expect rating
                # 3-4-5. stim x TTL post x onset time only     
                fname_341 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col=1, fname = fname_341)
                
                fname_342 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col='pmod_cue_type', fname = fname_342, dict_map = dict_cue)
                
                fname_343 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_pmod-actual.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col='pmod_actual_angle_demean', fname = fname_343)
                
                fname_344 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_pmod_expect.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col='pmod_expect_angle_demean', fname = fname_344)
                
                fname_345 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-POST_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_poststim_9000-135000ms', dur_col=4.5, mod_col='pmod_stim_type', fname=fname_345, dict_map = dict_stim)
                

                # 3-5-1. stim x TTL plateau x onset time only          
                # 3-5-2. stim x TTL plateau x cue type 
                # 3-5-3. stim x TTL plateau x actual rating
                # 3-5-4. stim x TTL plateau x expect rating
                # 3-5-5. stim x TTL plateau x onset time only
                fname_351 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col=1, fname = fname_351)
                
                fname_352 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_pmod-cue.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col='pmod_cue_type', fname = fname_352, dict_map = dict_cue)
                
                fname_353 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_pmod-actual.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col='pmod_actual_angle_demean', fname = fname_353)
               
                fname_354 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_pmod_expect.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col='pmod_expect_angle_demean', fname = fname_354)
                
                fname_355 = os.path.join(ev_dir, sub, ses, label+'_EV03-TTL-PLATEAU_pmod_level.txt')
                _build_evfile(df=mri_ttl, onset_col='onset03_stim_ttl-plateau', dur_col='onset03_stim_ttl-plateau-dur', mod_col='pmod_stim_type', fname=fname_355, dict_map = dict_stim)
                

                # 4. RATING ACTUAL __________________________________________________________________
                # 4-1. RATING onset only
                fname_4 = os.path.join(ev_dir, sub, ses, label+'_EV04-ACTUAL-onsetonly.txt')
                _build_evfile(df=mri_ttl, onset_col='onset04_ratingactual', dur_col='pmod_actual_RT', mod_col=1, fname=fname_4)

    except:
        with open(os.path.join(log_dir, "flag_{date}.txt"), "a") as logfile:
            traceback.print_exc(file=logfile)

