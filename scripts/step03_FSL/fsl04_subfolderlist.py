#!/usr/bin/env python
# encoding: utf-8
"""
subfolderlist.py
extract subfolders, save into txt file for job array submission
"""
# __author__ = "McKell Carter, Heejung Jung"
# __version__ = "1.0.1"
# __email__ = "heejung.jung@colorado.edu"
# __status__ = "Production"
# __userinput__ = "fmriprep_dir"

# TODO: figure out which sources to check
# 1. fmriprep preprocessed images
# 2. tcol folders 
# 3. how to update job array list? cross check if overlaps, if not append. don't overwrite "complete"
# 4. based on isolate_nifti > can also check which jobs completed

# TODO TODO TODO:
# oct 14 because I'm migrating into spacetop_projects_social instead of spacetop/social
# currently nifti_dir is '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_nifti'
# later, copy over and change it to /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social

# 1. libraries and directories __________________________________________
import os, glob, sys, time, shutil
import numpy as np
import fileinput
import itertools
from pathlib import Path
import pandas as pd
from datetime import date
import json

# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
print(main_dir)
ev_dir = os.path.join(main_dir,  'analysis', 'fmri', 'fsl', 'multivariate', 'isolate_ev')
fmriprep_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep'
sub_list = next(os.walk(fmriprep_dir))[1]
approved = ['sub']
sub_list[:] = [url for url in sub_list if any(sub in url for sub in approved)]

# nifti_dir = os.path.join(main_dir,  'analysis', 'fmri', 'fsl', 'multivariate', 'isolate_nifti')
nifti_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_nifti'

os.chdir(ev_dir)
filesDepth4 = sorted(glob.glob('*/*/*/*'))
approved = ['.csv']
filesDepth4[:] = [f for f in filesDepth4 if not any(sub in f for sub in approved)]

save_dir = os.path.join(main_dir, 'scripts', 'step03_FSL')
df = pd.DataFrame(data = [sub.split("/") for sub in filesDepth4], columns=['sub', 'ses', 'run', 'ev'])

# TODO: check if nifti exists
# if so, added complete at the end of the column
df['niftidir'] = nifti_dir
df['filename'] = df[['sub', 'ses', 'run', 'ev']].agg('_'.join, axis=1)
df['filename'] = df['filename'].astype(str) + '.nii.gz'

df['fpath'] = df[['niftidir', 'sub', 'filename']].agg('/'.join, axis = 1)
print(df.head())
df['exists'] = df['fpath'].map(os.path.isfile)
print(sub_list)
# TODO: exclude rows from pandas df where no fmriprep sub folder exists. 
subset_df = df[df['sub'].isin(sub_list)]
subset_df.drop(columns=['niftidir', 'filename'], inplace = True)
print(subset_df)

print(subset_df.agg(['nunique']))
total = subset_df.agg(['nunique'])
print(type(total))
today = date.today()
d1 = today.strftime("%Y-%m-%d")
print("total list summary\n{0}\n\t* sub: {1}\n\t* files: {2}\n\t* no. of complete: {3}".format(
    d1, total.iloc[0,0], total.iloc[0,4], subset_df.exists.eq(True).sum()))

json_summary = {
	"file description": "summary of single trial combintations, based on existing fmriprep nifti outputs and .fsf files created from behavioral files",
	"date": d1,
	"number of unique subjects": int(total.iloc[0, 0]),
	"number of unique files for FSL": int(total.iloc[0, 4]),
	"number of already completed single trials": int(subset_df.exists.eq(True).sum()),
	"subject list": sub_list
}

Path(os.path.join(current_dir, 'log')).mkdir(parents=True, exist_ok=True)
filename = os.path.join(current_dir, 'log', "summary_{0}.json".format(d1))
with open(filename, 'w') as outfile:
    json.dump(json_summary, outfile)
subset_df.to_csv(os.path.join(current_dir, 'log', "summary_{0}.txt".format(d1)), sep = ',', index=False, header = True)
subset_df.to_csv(os.path.join(save_dir, 'fsl05_jobarraylist.txt'), sep = ',', index=False, header = False)
