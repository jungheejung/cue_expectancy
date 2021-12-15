# %% libraries ________________________________________________________________________
import os, sys, glob, shutil
import pdb
from pathlib import Path
import itertools
import pandas as pd
# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
nifti_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's03_concatnifti')
sub_list = next(os.walk(nifti_dir))[1]
items_to_remove = ['sub-0000', 'sub-0002']
for item in items_to_remove:
    if item in sub_list:
        sub_list.remove(item)
param_list = [sub_list, 
['pain', 'vicarious', 'cognitive', 'general'],
['cue', 'stim']]
# task_list = []
# ev_list = []
# task = 'cognitive'
# ev = 'cue'

full_list = list(itertools.product(*param_list))
for sub, task, ev in full_list:
    print(f"subject: {sub}, task: {task}, event: {ev}")
    # load niftifname txt 
    nifti_fname = os.path.join(nifti_dir, sub, f"niftifname_{sub}_task-{task}_ev-{ev}.txt")
    nifti = pd.read_csv(nifti_fname, sep = '\t', header = None)
    # load f'{sub}_singletrial.csv
    subject_csv = os.path.join(main_dir, 'data', 'dartmouth', 'd06_singletrial_SPM', sub, f"{sub}_singletrial.csv" )
    meta = pd.read_csv(subject_csv)
    # subset task and ev, # based on text file, # only grab rows that exist
    nifti['fname'] = nifti[0].map(lambda x: x.lstrip('./').rstrip('.nii'))
    subset = meta[(meta.task == task ) & (meta.ev == ev)].reset_index(drop = True)

    # %%
    filtered = subset[subset.nifti_name  == nifti.fname]
    filtered.rename(columns={0:"beta_index_fsl"})
    save_fname = os.path.join(nifti_dir, sub, f"metadata_{sub}_task-{task}_ev-{ev}.csv")
    if os.path.exists(save_fname):
        os.remove(save_fname)
    else:
        print(f"{sub}_task-{task}_ev-{ev} doesnt exist")
    filtered.to_csv(save_fname)
