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
df = pd.DataFrame([sub.split("/") for sub in filesDepth4])

# TODO: check if nifti exists
# if so, added complete at the end of the column
# print( df[[0]].astype(str) + '_' + df[[1]].astype(str) + '_' + df[[2]].astype(str) + '_' + df[[3]].astype(str) + '.nii.gz')
df['niftidir'] = nifti_dir
df['filename'] = df[[0,1,2,3]].agg('_'.join, axis=1)
df['filename'] = df['filename'].astype(str) + '.nii.gz'

# df['filename'] =str(df[[0]].astype(str) + '_' + df[[1]].astype(str) + '_' + df[[2]].astype(str) + '_' + df[[3]].astype(str) + '.nii.gz')
# print("{0}_{1}_{2}_{3}.nii.gz".format(df[[0]], df[[1]], df[[2]], df[[3]]))
# print(df.head())
# df['fpath'] = nifti_dir + os.path.sep + df[[0]].astype(str) + os.path.sep +  df['filename'].astype(str)
df['fpath'] = df[['niftidir', 0, 'filename']].agg('/'.join, axis = 1)
print(df.head())
df['exists'] = df['fpath'].map(os.path.isfile)
print(sub_list)
# TODO: exclude rows from pandas df where no fmriprep sub folder exists. 
df = df[df[[0]].isin(sub_list)]
# df['exists'] = df['filename'].map(os.path.isfile)
print(df.head())

# os.path.isfile(os.path.join(nifti_dir, "{0}_{1}_{2}_{3}.nii.gz".format(df[[0]], df[[1]], df[[2]], df[[3]] ) ))
# /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop/social/analysis/fmri/fsl/multivariate/isolate_nifti/sub-0010

df.to_csv(os.path.join(save_dir, 'fsl05_jobarraylist_test.txt'), sep = ',', index=False, header = False)

# with open(os.path.join(save_dir, 'fsl05_jobarraylist.txt'), 'w') as f:
#     for item in filesDepth4:
#         f.write("%s\n" % item)

