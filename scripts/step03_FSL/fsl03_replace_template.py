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
main_git_dir = os.path.join('/dartfs-hpc','rc','lab','C','CANlab',
'labdata','projects','spacetop','social')
ev_dir = os.path.join(main_git_dir,'analysis','fmri','fsl',
'multivariate','isolate_ev')
fmriprep_dir = os.path.join('/dartfs-hpc','rc','lab','C','CANlab',
'labdata','data','spacetop','derivatives','dartmouth','fmriprep','fmriprep')
motion_dir = os.path.join(main_git_dir, 'data', 'dartmouth', 'd05_motion')
script_dir = os.path.join(main_git_dir, 'scripts','step03_FSL')
a = [[2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,23,24,25,26,28,29],
[1,3,4],
[1,2,3,4,5,6]]
b = list(itertools.product(*a))

# TODO: 2. extract directories __________________________________________
# [x] extract the keyword that follows run-01

for sub_num, ses_num, run_num in b:
    sub = 'sub-{0}'.format(str(sub_num).zfill(4))
    ses = 'ses-{0}'.format(str(ses_num).zfill(2))
    run = 'run-{0}'.format(str(run_num).zfill(2))
    ev_top_dir = glob.glob(os.path.join(ev_dir, sub, ses, '{0}-*'.format(run) ))
    ev_fil_dir = [e_dir for e_dir in ev_top_dir if e_dir != [] ]
    run_fullname = os.path.basename(ev_fil_dir[0])
    ev_list = os.listdir(ev_top_dir[0]) 
    for ev_folder in sorted(ev_list):
        fsloutput_dir = os.path.join(ev_top_dir[0], ev_folder)  


        # TODO: 3. load txt file __________________________________________
        template_fname = os.path.join(script_dir, 'fsl03_TEMPLATE.fsf')
        f = open(template_fname, "r")
        fsf_template = f.read()
        # template_f = file(script_dir + os.sep + template_fname)
        # fsf_template = template_f.read()
        f.close()

        # TODO: 4. start replacing __________________________________________
        fsf_output = os.path.join(fsloutput_dir, 'isolate_model')
        fmriprep_func = os.path.join(fmriprep_dir, sub, ses, 'func', 
        '{0}_{1}_task-social_acq-mb8_run-{2}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'.format(sub, ses, run_num))
        motion_subset = os.path.join(motion_dir, sub, ses, 
        '{0}_{1}_task-social_{2}_confounds-subset.txt'.format(sub, ses, run))
        single_title = "single-event_{0}_{1}_task-social_{2}_{3}".format(sub, ses, run_fullname, ev_folder)
        single_fname = os.path.join(fsloutput_dir, "{0}_{1}_task-social_{2}_{3}_single.tcol".format(sub, ses, run_fullname, ev_folder))
        combine_title = "combined_events_{0}_{1}_task-social_{2}_{3}".format(sub, ses, run_fullname, ev_folder)
        combine_fname = os.path.join(fsloutput_dir, "{0}_{1}_task-social_{2}_{3}_combine.tcol".format(sub, ses, run_fullname, ev_folder))

        new_fsf_template = fsf_template.replace('OUTPUT', fsf_output)
        new_fsf_template = new_fsf_template.replace('FUNCDATA', fmriprep_func)
        new_fsf_template = new_fsf_template.replace('CONFOUNDS', motion_subset)
        new_fsf_template = new_fsf_template.replace('SINGLE_TITLE', single_title)
        new_fsf_template = new_fsf_template.replace('SINGLE_TCOL', single_fname)
        new_fsf_template = new_fsf_template.replace('COMBINE_TITLE', combine_title)
        new_fsf_template = new_fsf_template.replace('COMBINE_TCOL', combine_fname)

        # TODO: 5. save fsf template _________________________________________-
        new_template_fname = os.path.join(fsloutput_dir, 'isolated_model.fsf')
        with open(new_template_fname, 'w') as f:
            f.write(new_fsf_template)
        f.close()
# tmp_job_f = file(exper_dir + os.sep + tmp_job_fname, "w")
# tmp_job_f.write("\n".join(new_fsf_template))
# tmp_job_f.close()