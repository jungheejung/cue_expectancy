# %%
import sys
import glob
import os
import seaborn as sns
import matplotlib.pyplot as plt
from os.path import join
import neurokit2 as nk
import numpy as np
import pandas as pd
from datetime import datetime
from pathlib import Path

"""
20 seconds
# get a list that matches this pattern
# {sub}_{ses}_*_runtype-pain_epochstart--1_epochend-8_physio-scltimecourse.csv

# step 1. concatenate into dataframe while handeling info
# - sub
# - ses
# - run number
# - trial number
# ,src_subject_id,session_id,param_task_name,param_run_num,param_cue_type,param_stimulus_type,param_cond_type,trial_num,trial_order,iv_stim,mean_signal,

# step 2. downsample to 25 hz
# step 3. z score within paritcipant
# step 4. average per condition 
"""

# %% glob data ________________________
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
# local_physiodir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/analysis/physio'
physio_dir = join(main_dir, 'analysis/physio/')
# task = 'cognitive'
epochstart = -1
epochend = 15
samplingrate = 25
ttlindex = 2
date = datetime.now().strftime("%m-%d-%Y")
# %%
for task in [ 'pain', 'cognitive', 'vicarious']:
    # NOTE: <<--------only run once
    flist = glob.glob(
        join(physio_dir, '**', f'sub-0*{task}*_epochend-{epochend}_samplingrate-{samplingrate}_ttlindex-{ttlindex}_physio-scltimecourse.csv'), recursive=True)
    # sub-0053_ses-01_run-02_runtype-vicarious_epochstart--1_epochend-20_samplingrate-25_ttlindex-2_physio-scltimecourse
    # sub-0062_ses-01_run-06_runtype-vicarious_epochstart--1_epochend-20_samplingrate-25_ttlindex-2_physio-scltimecourse
    #  NOTE: stack all data and save as .csv ________________________
    li = []
    frame = pd.DataFrame()
    for filename in sorted(flist):
        df = pd.read_csv(filename, index_col=None, header=0)
        li.append(df)
    frame = pd.concat(li, axis=0, ignore_index=True)
    frame.to_csv(join(physio_dir, 'physio01_SCL',
                f'sub-all_ses-all_run-all_runtype-{task}_epochstart-{epochstart}_epochend-{epochend}_samplingrate-{samplingrate}_ttlindex-{ttlindex}_physio-scltimecourse.csv'), index = False)

