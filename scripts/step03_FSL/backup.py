#!/usr/bin/env python
# encoding: utf-8
"""
replace_template.py
open FSL template and replace variables with corresponding filenames

created by McKell Carter on 2012-02-04
modified by Heejung Jung on 2018-01-02 and 2021-08-14
"""

# 1. libraries and directories __________________________________________
import os, glob, sys, time, shutil
import numpy as np
import fileinput

# experiment_name = 'social'
# exper_dir = '/work/ics/data/projects/snaglab/Projects/POKER.05'
# event_file_list = ['at_CARD_lowbet.txt', 'at_CARD_lowfold.txt']
# template_fname = 'Scripts/isolateEvents/isolateEV01_templateBIDS.fsf'
# three_col_file_ext = '.tcol'
ev_dir = os.path.join('dartfs-hpc','rc','lab','C','CANlab',
'labdata','projects','spacetop','social','analysis','fmri','fsl',
'multivariate','isolate_ev')
fmriprep_dir = os.path.join('dartfs-hpc','rc','lab','C','CANlab',
'labdata','data','spacetop','derivatives','dartmouth','fmriprep','fmriprep')
motion_dir = os.path.join('dartfs-hpc', 'rc', 'lab', 'C', 'CANlab',
'labdata', 'projects', 'spacetop', 'social', 'data', 'dartmouth', 'd05_motion')
a = [[2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25,26,28,29],
[1,3,4],
[1,2,3,4,5,6]]
b = list(itertools.product(*a))

for sub_num, ses_num, run_num in b:
    sub = 'sub-{0}'.format(str(sub_num).zfill(4))
    ses = 'ses-{0}'.format(str(ses_num).zfill(2))
    run = 'run-{0}'.format(str(run_num).zfill(2))
    ev_top_dir = glob.glob(os.path.join(ev_dir, sub, ses, '{2}-*'.format(run) ))
    ev_list = os.listdir(ev_top_dir[0]) 
    for ev_folder in ev_list:
        fsloutput_dir = os.path.join(ev_top_dir, ev_folder)  
# TODO: 2. set directories __________________________________________


# TODO: 3. load txt file __________________________________________
template_f = file(exper_dir + os.sep + template_fname)
fsf_template = template_f.read()
template_f.close()

# TODO: 4. start replacing __________________________________________
OUTPUT=os.path.join(ev_dir, sub, ses, run-01-pain/ev-cue-0000/isolate_model
ANAT
FUNC=os.path.join(fmriprep_dir, sub, ses, 'func', '{0}_{1}_task-social_acq-mb8_run-{2}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'.format(sub, ses, run_num)
CONFOUNDS= os.path.join(motion_dir, sub, ses, '{0}_{1}_task-social_{2}_confounds-subset.txt'.format(sub, ses run)

EVDIR= os.path.join(ev_dir, sub, ses, /run-01-pain/ev-cue-0000
SINGLE_TITLE = "single_event"
COMBINE_TITLE = "combined_events"
SINGLE = "sub-0003_ses-01_task-social_run-01-pain_ev-cue-0000_single.tcol"
COMBINE = "sub-0003_ses-01_task-social_run-01-pain_ev-cue-0000_combine.tcol"
os.path.join(EVDIR, SINGLE)

                new_fsf_template = fsf_template.replace('ANATDATA', ANAT)
                new_fsf_template = new_fsf_template.replace('FUNCDATA', FUNC)
                new_fsf_template = new_fsf_template.replace('CONFOUNDS', CONFOUNDS)
                new_fsf_template = new_fsf_template.replace(