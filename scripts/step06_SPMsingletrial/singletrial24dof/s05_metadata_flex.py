# %% libraries ________________________________________________________________________
import os
import sys
import glob
import shutil
import pdb
from pathlib import Path
import itertools
import pandas as pd
import re
import numpy as np
# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
# discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
main_dir = Path(current_dir).parents[1]
nifti_dir = os.path.join(main_dir, 'analysis', 'fmri',
                         'spm', 'multivariate_24dofcsd', 's03_concatnifti')
sub_list = next(os.walk(nifti_dir))[1]
items_to_remove = ['sub-0000', 'sub-0002']
for item in items_to_remove:
    if item in sub_list:
        sub_list.remove(item)

param_list = [sorted(sub_list),
              ['early', 'late', 'post', 'plateau'],
              ['stim']]
ttl_dict = {
    'early': 'd06_singletrial_SPM_01-pain-early',
    'late': 'd06_singletrial_SPM_02-pain-late',
    'post': 'd06_singletrial_SPM_03-pain-post',
    'plateau': 'd06_singletrial_SPM_04-pain-plateau'
}
full_list = list(itertools.product(*param_list))
for sub, task, ev in full_list:
    # load niftifname txt
    subject_csv = os.path.join(main_dir, 'data', 'dartmouth',
                               ttl_dict[task], sub, f"{sub}_singletrial_{task}.csv")
    nifti_fname = os.path.join(
        nifti_dir, sub, f"niftifname_{sub}_task-pain-{task}_ev-{ev}.txt")
    if os.path.exists(subject_csv) & os.path.exists(nifti_fname):
        print(f"loading {sub} {task} {ev}")
        meta = pd.read_csv(subject_csv)
        nifti = pd.read_csv(nifti_fname, sep='\t', header=None)
        nifti['fname'] = nifti[0].map(
            lambda x: os.path.basename(x.lstrip('./').rstrip('.nii')))
        # int(re.findall('\d+', [match for match in nifti['fname'].str.split('_') if "sub" in match][0])[0])
        # result = nifti['fname'].str.split(f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-stim-(\d+)', expand=True) # ([A-Za-z]+)_task-social_ev-stim-(\d+)
        nifti['sub'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[1].astype(int)
        nifti['ses'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[2].astype(int)
        nifti['run'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[3].astype(int)
        nifti['task'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[4]
        nifti['ev'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[5]
        nifti['num'] = nifti['fname'].str.split(
            f'sub-(\d+)_ses-(\d+)_run-(\d+)-([A-Za-z-]+)_task-social_ev-([A-Za-z-]+)-(\d+)', expand=True)[6].astype(int)

        meta = meta.dropna(subset=['num'])
        meta['num'] = meta['num'].astype(np.int64)

        # tryout
        # hsp.loc[~(hsp['Type_old'] == hsp['Type_new'])]
        # subset = df1[(df1.start <= df1.start_key) & (df1.end <= df1.end_key)]
        # meta[(meta.sub == nifti.sub) & (meta.ses == nifti.ses)]
        # meta['sub'].eq(nifti['sub']).all(1)
        # mask = meta[['sub', 'ses', 'run', 'ev', 'num']].eq(nifti[['sub', 'ses', 'run','ev' ,'num']])
        # https://stackoverflow.com/questions/70461095/pandas-find-matching-rows-in-two-dataframes-without-using-merge
        mask = meta[['sub', 'ses', 'run', 'ev', 'num']].apply(lambda x: all(
            np.in1d(x, nifti[['sub', 'ses', 'run', 'ev', 'num']])), axis=1)
        filtered = meta.loc[mask, ]
        filtered['nifti_name'] = filtered['sub'].apply(lambda x: f"sub-{x:04d}") +'_'+ filtered['sub'].apply(lambda x: f"ses-{x:02d}") +'_'+ \
        filtered['run'].apply(lambda x: f"run-{x:02d}") +'-pain-'+ task + '_task-social-' + filtered['num'].apply(lambda x: f"ev-stim-{x:04d}")
        save_fname = os.path.join(
            nifti_dir, sub, f"metadata_{sub}_task-pain-{task}_ev-{ev}.csv")
        if os.path.exists(save_fname):
            os.remove(save_fname)
        else:
            print(f"{sub}_task-{task}_ev-{ev} doesnt exist")
        filtered.to_csv(save_fname, index=False)

    else:
        print(f"no match for {sub} {task} {ev}")
