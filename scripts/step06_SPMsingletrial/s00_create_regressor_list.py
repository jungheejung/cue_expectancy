# create a table 
# each row corresponds to each regressor
# contains nifti name, onset, duration ,modulation degree
# CUE, STIM, wm, csf, 6DOR, 6 dummy regressor
# next run...
# Each index corresponds to the 

# %%
import os, glob, itertools
import pandas as pd
from pathlib import Path 

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
ev_single_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd06_singletrial_SPM')
# %%
sub_list = next(os.walk(csv_dir))[1]
sub_list.remove('sub-0001')
for sub in sub_list:
    beh_list = []
    beh_list = glob.glob(os.path.join(csv_dir, sub, '*','*_beh.csv'))
    subject_dataframe = pd.DataFrame([])
    for ind, fpath in enumerate(sorted(beh_list)):
        fname = os.path.basename(fpath)
        
        df = pd.DataFrame()
        df = pd.read_csv(fpath)

        sub_num = df.src_subject_id[0].astype(int)
        ses_num= df.session_id[0].astype(int)
        run_num = int(fname.split('_')[3].split('-')[1])
        task_name = df.param_task_name[0]

        Path(os.path.join(ev_single_dir, sub)).mkdir(parents=True, exist_ok=True)

        cue_num = len(df.event01_cue_onset - df.param_trigger_onset)
        trial_num = len(df.event03_stimulus_displayonset - df.param_trigger_onset) 
        nuissance = ['csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z', 'dummy', 'intercept']
        nuissance_num = len(nuissance)
        new = pd.DataFrame(
            index = range(cue_num + trial_num + nuissance_num + 1),
            columns=['nifti_name','sub','ses','run','task','ev','num','onset','dur','mod','regressor', 'cue_type', 'stim_type'])

        # CUE event fill in parameters for CUE event ____________________________________________
        cue_num = len(df.event01_cue_onset - df.param_trigger_onset)
        new.loc[0:cue_num-1, 'onset'] = df.event01_cue_onset - df.param_trigger_onset
        new.loc[0:cue_num-1, 'ev'] = 'cue'
        new.loc[0:cue_num-1, 'dur'] = 1
        new.loc[0:cue_num-1, 'mod'] = 1
        new.loc[0:cue_num-1, 'regressor'] = True
        new.loc[0:cue_num-1, 'num'] = list(range(cue_num))
        new.loc[0:cue_num-1, 'cue_type'] = list(df.param_cue_type)
        new.loc[0:cue_num-1, 'stim_type'] = list(df.param_stimulus_type)


        # STIM fill in parameters for STIM event ____________________________________________
        trial_num = len(df.event03_stimulus_displayonset - df.param_trigger_onset) 
        new.loc[cue_num:cue_num+trial_num-1, 'onset'] = list(df.event03_stimulus_displayonset - df.param_trigger_onset + 2)
        new.loc[cue_num:cue_num+trial_num-1, 'ev'] = 'stim'
        new.loc[cue_num:cue_num+trial_num-1, 'dur'] = 5
        new.loc[cue_num:cue_num+trial_num-1, 'mod'] = 1
        new.loc[cue_num:cue_num+trial_num-1, 'regressor'] = True
        new.loc[cue_num:cue_num+trial_num-1, 'num'] = list(range(trial_num))
        new.loc[cue_num:cue_num+trial_num-1, 'cue_type'] = list(df.param_cue_type)
        new.loc[cue_num:cue_num+trial_num-1, 'stim_type'] = list(df.param_stimulus_type)

        # RATING fill in parameters for STIM event ____________________________________________
        # trial_num = len(df.ISI03_onset - df.param_trigger_onset) 
        rating = pd.concat( [df.event02_expect_displayonset-df.param_trigger_onset, df.event04_actual_displayonset-df.param_trigger_onset])
        rt = pd.concat( [df.event02_expect_RT, df.event04_actual_RT]).reset_index(drop = True)
        rt.fillna(4, inplace = True)
        rating.sort_values(ascending = True, inplace = True, ignore_index=True)
        new.loc[cue_num+trial_num, 'onset'] = list(rating - df.param_trigger_onset.repeat(2).reset_index(drop = True))
        new.loc[cue_num+trial_num, 'ev'] = 'rating'
        new.loc[cue_num+trial_num, 'dur'] = list(rt)
        new.loc[cue_num+trial_num, 'mod'] = 1
        new.loc[cue_num+trial_num, 'regressor'] = False
        matlab_rating = pd.concat([rating, rt], axis = 1)
        matlabname = f'{sub}_ses-{ses_num:02d}_run-{run_num:02d}_rating.csv'
        matlab_rating.to_csv(os.path.join(ev_single_dir, sub, matlabname), index = False, header = ['rating', 'rt'] ) #sub-####_ses-##_run-##_event-rating.csv


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
    subject_dataframe.to_csv(os.path.join(ev_single_dir, sub,  f'{sub}_singletrial.csv'))

# %%
