#!/usr/bin/env python
# encoding: utf-8

# %%
from operator import index
import os, re, glob
import numpy as np
import pandas as pd
from pathlib import Path
import itertools
"""
fmriprep_motionextract.py
fmriprep produces confounds_timeseries.tsv files 
from this extract motion regressors
also add .json of what regressors are extracted (we want to save regressors without headers, so that SPM and FSL can read it.)
"""
# __author__ = "Heejung Jung"
# __version__ = "1.0.1"
# __email__ = "heejung.jung@colorado.edu"
# __status__ = "Production"

# TODO:
# [ ] 01: go to fmriprep
# [ ] 02: glob number of confound files 
# [ ] 03: read_csv 
# [ ] 04: extract handful of columns 
# [ ] 05: save into d05_motion
# %% parameter _____________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[0]
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep'
save_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd05_motion')
variables = ['csf', 'white_matter', 'trans_x', 'trans_y', 'trans_z', 'rot_x', 'rot_y', 'rot_z']
# /dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/sub-0024/ses-01/func
# /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/data/dartmouth/d05_motion/sub-0003/ses-01
sub_list = next(os.walk(fmriprep_dir))[1]
approved = ['sub']
sub_list[:] = [url for url in sub_list if any(sub in url for sub in approved)]

print("\nmain_dir: {0}".format(main_dir))
# print("sub_list: {0}".format(sub_list))
# fname = sub-0024_ses-01_task-social_acq-mb8_run-6_desc-confounds_timeseries.tsv

for sub in sub_list:
    
    print("\nsub: {0}".format(sub))
    confound_list = glob.glob(os.path.join(fmriprep_dir, sub, '*', 'func', sub+'*desc-confounds_timeseries.tsv'))

    if confound_list:
        for fname in confound_list:         
            info = os.path.basename(fname).split("_")
            # print("info: {0}".format(info))
            # sub = info[0] # sub-0002
            ses = info[1] # ses-01
            task = info[2] # task-social
            acq = info[3] # acq-mb8
            run = info[4] # run-5
            run_num = "{0:02d}".format(int(re.findall('\d', run)[0]))
            # print("\nre: {0}".format(int(re.findall('\d', run)[0])))
            print("\n{0} {1} {2}".format(sub, ses, run_num))    
            # print("run_num: {0}".format(run_num))
            # print(confound_list)
            df = pd.read_csv(fname)
            data = df[df.columns.intersection(variables)]
            new_dir = os.path.join(save_dir, sub, ses)
            Path(new_dir).mkdir(parents=True, exist_ok=True)
            new_fname = os.path.join(new_dir, '{0}_{1}_task-social_run-{2}_confounds-subset.txt'.format(sub,ses,run_num))
            
            data.to_csv(new_fname, header=None, index=None, sep='\t')
    print("sub motion list complete")

# confounds-subset.json