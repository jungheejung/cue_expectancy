#!/usr/bin/env python3
"""
based on concatenated niftis, 
extract metadata from _singletrial.csv
"""
# %% libraries ________________________________________________________________________
import os, sys, glob, shutil
import pdb
from pathlib import Path
import itertools
import pandas as pd

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 
# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
nifti_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's03_concatnifti')

sub_folders = next(os.walk(nifti_dir))[1]
sub_folder = [i for i in sub_folders if i.startswith('sub-')]
remove_int = [1,2,3,4,5]
remove_list = [f"sub-{x:04d}" for x in remove_int]
sub_list = [i for i in sub_folder if i not in remove_list]
items_to_remove = ['singletrial_SPM_03-pain-post', 'singletrial_SPM_02-pain-late','singletrial_SPM_04-pain-plateau','singletrial_SPM_01-pain-early']
for item in items_to_remove:
    if item in sub_list:
        sub_list.remove(item)
sub_list = sorted(sub_list)

param_list = [sub_list, 
['pain', 'vicarious', 'cognitive'],
['cue', 'stim']]

full_list = list(itertools.product(*param_list))
for sub, run_type, ev in full_list:
    # /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/data/d03_onset/onset03_SPMsingletrial/sub-0055
    subject_csv = os.path.join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_singletrial_plateau.csv" )
    nifti_fname = os.path.join(nifti_dir, sub, f"niftifname_{sub}_task-social_run_{run_type}_ev-{ev}.txt")

    if os.path.exists(subject_csv) & os.path.exists(nifti_fname):
        print(f"loading {sub} {run_type} {ev}")
        nifti = pd.read_csv(nifti_fname, sep = '\t', header = None)
        meta = pd.read_csv(subject_csv)
    # subset task and ev, # based on text file, # only grab rows that exist
        nifti['fname'] = nifti[0].map(lambda x: os.path.basename(x).lstrip('./').rstrip('.nii'))
        nifti['sub'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[1].astype(int)
        nifti['ses'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[2].astype(int)
        nifti['run'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[3].astype(int)
        nifti['run_type'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[4]
        # nifti['fname'].str.split(
            # f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[4]
        nifti['ev'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[5]
        nifti['num'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[6].astype(int)

        meta = meta.dropna(subset=['num'])
        meta['num'] = meta['num'].astype(np.int64)

        mask = meta[['sub', 'ses', 'run', 'ev', 'num']].apply(lambda x: all(
            np.in1d(x, nifti[['sub', 'ses', 'run', 'ev', 'num']])), axis=1)
        filtered = meta.loc[mask, ]
        filtered['nifti_name'] = filtered['sub'].apply(lambda x: f"sub-{x:04d}") +'_'+ filtered['sub'].apply(lambda x: f"ses-{x:02d}") +'_'+ \
        filtered['run'].apply(lambda x: f"run-{x:02d}") +'-'+ run_type + '_task-social-' + filtered['num'].apply(lambda x: f"ev-stim-{x:04d}")
    # subset = meta[(meta.task == task ) & (meta.ev == ev)].reset_index(drop = True)

    # %%
    # filtered = subset[subset.nifti_name  == nifti.fname]
    # filtered.rename(columns={0:"beta_index_fsl"})
    save_fname = os.path.join(nifti_dir, sub, f"metadata_{sub}_task-social_run-{run_type}_ev-{ev}.csv")
    if os.path.exists(save_fname):
        os.remove(save_fname)
    else:
        print(f"{sub}_task-social_run-{run_type}_ev-{ev} doesnt exist")
    filtered.to_csv(save_fname)

# general
param_list = [sub_list, 
['cue', 'stim']]

full_list = list(itertools.product(*param_list))
for sub, ev in full_list:
# load niftifname txt 
    nifti_fname = os.path.join(nifti_dir, sub, f"niftifname_{sub}_task-social_run-general_ev-{ev}.txt")
    nifti = pd.read_csv(nifti_fname, sep = '\t', header = None)
    # load f'{sub}_singletrial.csv
    subject_csv = os.path.join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial', sub, f"{sub}_singletrial.csv" )
    meta = pd.read_csv(subject_csv)
    # subset task and ev, # based on text file, # only grab rows that exist
    nifti['fname'] = nifti[0].map(lambda x: x.lstrip('./').rstrip('.nii'))
    subset = meta[(meta.ev == ev)].reset_index(drop = True)

    # %%
    filtered = subset[subset.nifti_name  == nifti.fname]
    filtered.rename(columns={0:"beta_index_fsl"})
    save_genfname = os.path.join(nifti_dir, sub, f"metadata_{sub}_task-social_run-general_ev-{ev}.csv")
    if os.path.exists(save_genfname):
        os.remove(save_genfname)
    else:
        print(f"{sub}_task-social_run-general_ev-{ev} doesnt exist")
    filtered.to_csv(save_genfname)
