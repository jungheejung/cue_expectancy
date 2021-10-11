#!/usr/bin/env python
# encoding: utf-8

"""
check text file (there was a bug)

CASE 1 No bold, No pe: "no brain image to begin with"
CASE 2 No bold, No pe: "false alarm save list and investigate"
CASE 3 bold and pe exist: "FSL complete"
CASE 4 bold but No pe: "not done yet, leave empty in list"
"""

# check DONE 
# check brain nifti 

# 1. libraries and directories __________________________________________
import os, glob, sys, time, shutil
import numpy as np
import fileinput
import itertools
import pandas as pd
import re
import pathlib
from shutil import copyfile

ev_dir = os.path.join('/dartfs-hpc','rc','lab','C','CANlab',
'labdata','projects','spacetop','social', 'analysis', 'fmri', 'fsl', 'multivariate', 'isolate_ev')

script_dir = os.path.join('/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/scripts/step03_FSL')
fmriprep_dir="/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep"
# ev_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_ev'
nifti_dir ="/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_nifti"
# load txt
df = pd.read_csv(os.path.join(script_dir, 'fsl05_jobarraylist.txt'),
                             sep=",",
                             header=None,
                             names=["sub", "ses", "run", "ev", "done"])

investigate = []
# only get rows that say DONE
for index, row in df[df['done'] == 'DONE'].iterrows():
    sub = row[0];    ses = row[1];    run = row[2];    ev = row[3];    done = row[4]
    run_num = re.findall(r'\d+', run)[0].strip("0")
    bold=os.path.join(fmriprep_dir, sub, ses, 'func', 
    '{0}_{1}_task-social_acq-mb8_run-{2}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'.format(sub, ses, run_num ))
    pe = os.path.join(ev_dir, sub, ses, run, ev, 'isolate_model.feat', 'stats', 'pe1.nii.gz')
    new_string = '{0}_{1}_{2}_{3}'.format(sub,ses,run,ev)

    # 1. if brain nifti doesn't exist but text file says DONE, delete DONE 
    if not os.path.isfile(bold) and not os.path.isfile(pe):
        # update text file by substituting DONE with empty
        df[df['done'] == 'DONE'].loc[index, 'done'] = ' '
        print("CASE 1: No fmriprep to begin with " + new_string)
    elif not os.path.isfile(bold) and not os.path.isfile(pe):
        df[df['done'] == 'DONE'].loc[index, 'done'] = ' '
        print("CASE 2: false alarm save list and investigate" + new_string)   
        investigate.append(raw.values)
    


    # 2. if brain nifti exists, text file says DONE, and STATS exists, then copy pe.nii.gz over
    elif os.path.isfile(bold) and os.path.isfile(pe):
        nifti_path = pathlib.Path(os.path.join(nifti_dir, sub))
        nifti_path.mkdir(parents = True, exist_ok = True)
        new_fname = new_string + '.nii.gz'
        copyfile(pe, os.path.join(nifti_path, new_fname))
        # delete existing files
        stats_dir = os.path.join(ev_dir, sub, ses, run, ev, 'isolate_model.feat')
        retain = ["stats"]
        # Loop through everything in folder in current working directory
        for item in os.listdir(stats_dir):
            if item not in retain:  # If it isn't in the list for retaining
                os.remove(item)  # Remove the item
        print("CASE 3: FSL complete, copying file over " + new_string)
    elif os.path.isfile(bold) and not os.path.isfile(pe):
        df[df['done'] == 'DONE'].loc[index, 'done'] = ' '
        print("CASE 4: Job not done yet, leave empty in list" + new_string)
df_new = df.append(pd.DataFrame(new_rows, columns=df.columns)).reset_index()
