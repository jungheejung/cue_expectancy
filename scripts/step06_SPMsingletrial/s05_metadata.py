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

param_list = [sub_list, 
['pain', 'vicarious', 'cognitive', 'general'],
['cue', 'stim']]
# task_list = []
# ev_list = []
# task = 'cognitive'
# ev = 'cue'

full_list = list(itertools.product(*param_list))
for sub, task, ev in full_list:
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
    try:
        os.ulink(save_fname)
    except:
        print("Error while deleting file or file doesn't exist")   
    filtered.to_csv(save_fname)