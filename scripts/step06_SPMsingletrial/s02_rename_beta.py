#!/usr/bin/env python3
"""
this script grabs the beta files from SPM
it renames the betafiles using the metadata from the onsets folder
each renamed betafile will have a naming convention as the following
{sub}_{ses}_{run}-{run_num}-{run_type}_task-social_ev-{ev_type}_{ev_num}.nii
"""
# %% import libraries
import os, shutil
from pathlib import Path
import pandas as pd
import logging
import datetime

# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
# /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social/data/d03_onset/onset03_SPMsingletrial/sub-0024/sub-0024_singletrial_plateau.csv
meta_dir = os.path.join(main_dir, 'data', 'd03_onset', 'onset03_SPMsingletrial')
singletrial_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's01_singletrial')
output_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's02_isolatenifti')
save_dir = os.path.join(main_dir, 'scripts', 'logcenter')

sub_folders = next(os.walk(singletrial_dir))[1]
sub_folder = [i for i in sub_folders if i.startswith('sub-')]
remove_int = [1,2,3,4,5]
remove_list = [f"sub-{x:04d}" for x in remove_int]
sub_list = [i for i in sub_folder if i not in remove_list]
items_to_remove = ['singletrial_SPM_03-pain-post', 'singletrial_SPM_02-pain-late','singletrial_SPM_04-pain-plateau','singletrial_SPM_01-pain-early']
for item in items_to_remove:
    if item in sub_list:
        sub_list.remove(item)
sub_list = sorted(sub_list)
print(sub_list)

# %% logger parameters __________________________________________________
txt_filename = os.path.join(
    save_dir, f's06-SPMsingletrial_c02-renamebeta_flaglist_{datetime.date.today().isoformat()}.txt')

formatter = logging.Formatter('%(levelname)s - %(message)s')
handler = logging.FileHandler(txt_filename)
handler.setFormatter(formatter)
handler.setLevel(logging.DEBUG)
# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setFormatter(formatter)
ch.setLevel(logging.INFO)
logging.getLogger().addHandler(handler)
logging.getLogger().addHandler(ch)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
# %%
# sub = sub_list[0]
for sub in sub_list:
    T = pd.read_csv(os.path.join(meta_dir, sub, f'{sub}_singletrial_plateau.csv'))
    T['spm_index'] = T.index.tolist() 
    T['spm_index'] = T['spm_index'] +1

    subset = T[T.regressor == True].copy()
    subset['source_name'] = subset["spm_index"].astype(int).apply(lambda x: f'beta_{x:04d}.nii')
    # 'source_name' >> 'nifti_name'
    for ind, row in subset.iterrows():
#        print(ind, row)
        source_name = os.path.join(singletrial_dir, sub, row.source_name)
        nifti_name = f"sub-{row['sub']:04d}_ses-{row['ses']:02d}_run-{row['run']:02d}-{row['task']}_task-social_ev-{row['ev']}-{int(row['num']):04d}.nii"
        dest_name = os.path.join(output_dir, sub, nifti_name)
        Path(os.path.join(output_dir, sub)).mkdir(parents=True, exist_ok=True)
        print(source_name)
        print(dest_name)
        if os.path.exists(source_name):
            shutil.copy(source_name, dest_name)
            logger.info(msg="Success - {nifti_name}")
        else:
            logger.warning(msg="Failed to copy - {nifti_name}")
            break

