
# %% import libraries
import os, shutil
from pathlib import Path
import pandas as pd
# go into each SPM dir
# based on table, identify beta number
# rename and mv
# isolate_nifti
# %% parameters ________________________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
meta_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd06_singletrial_SPM')
spm_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's01_singletrial')
nifti_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's02_isolatenifti')
<<<<<<< HEAD
#sub_list = next(os.walk(spm_dir))[1]
sub_folders = next(os.walk(nifti_dir))[1]
=======
sub_folders = next(os.walk(spm_dir))[1]
>>>>>>> 1dc429aa9078c87e4a1f00a0456e8d3df637a30b
sub_list = [i for i in sub_folders if i.startswith('sub-')]
items_to_remove = ['sub-0001','sub-0002','sub-0003','sub-0004','sub-0005',
'sub-0006','sub-0007','sub-0008','sub-0009','sub-0010',
'sub-0014','sub-0015','sub-0016','sub-0018','sub-0019','sub-0020',
'sub-0023','sub-0024','sub-0025','sub-0021',
'sub-0032', 
'sub-0050','sub-0030', 'sub-0035',  'sub-0043', 
 'sub-0080','sub-0031','sub-0033','sub-0037','sub-0026','sub-0028', 'sub-0029' ]
items_to_remove = ['singletrial_SPM_03-pain-post', 'singletrial_SPM_02-pain-late','singletrial_SPM_04-pain-plateau','singletrial_SPM_01-pain-early']
for item in items_to_remove:
    if item in sub_list:
        sub_list.remove(item)
sub_list = sorted(sub_list)
print(sub_list)
# %%
# sub = sub_list[0]
for sub in sub_list:
    T = pd.read_csv(os.path.join(meta_dir, sub, f'{sub}_singletrial.csv'))
    T['spm_index'] = T.index.tolist() 
    T['spm_index'] = T['spm_index'] +1


    subset = T[T.regressor == True].copy()
    subset['source_name'] = subset["spm_index"].astype(int).apply(lambda x: f'beta_{x:04d}.nii')
    # 'source_name' >> 'nifti_name'
    for ind, row in subset.iterrows():
#        print(ind, row)
        source_name = os.path.join(spm_dir, sub, row.source_name)
        nifti_name = f"sub-{row['sub']:04d}_ses-{row['ses']:02d}_run-{row['run']:02d}-{row['task']}_task-social_ev-{row['ev']}-{int(row['num']):04d}.nii"
        dest_name = os.path.join(nifti_dir, sub, nifti_name)
        Path(os.path.join(nifti_dir, sub)).mkdir(parents=True, exist_ok=True)
        print(source_name)
        print(dest_name)
        if os.path.exists(source_name):
            shutil.copy(source_name, dest_name)
        else:
            break

# %%
