
# %% import libraries
import os, shutil,sys
from pathlib import Path
import pandas as pd
# go into each SPM dir
# based on table, identify beta number
# rename and mv
# isolate_nifti
# %% parameters ________________________________________________________________________
ttl_key = sys.argv[1]
ttl_dict = {
'early':'singletrial_SPM_01-pain-early',
'late':'singletrial_SPM_02-pain-late',
'post':'singletrial_SPM_03-pain-post',
'plateau':'singletrial_SPM_04-pain-plateau'}
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
meta_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd06_singletrial_SPM', ttl_dict[ttl_key])
spm_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's01_singletrial',ttl_dict[ttl_key])
nifti_dir = os.path.join(main_dir, 'analysis', 'fmri', 'spm', 'multivariate', 's02_isolatenifti',ttl_dict[ttl_key])
sub_list = next(os.walk(spm_dir))[1]
items_to_remove = ['sub-0001','sub-0002','sub-0003','sub-0004','sub-0005' ]
for item in items_to_remove:
    if item in sub_list:
        sub_list.remove(item)
sub_list = sorted(sub_list)
print(sub_list)
# %%
# sub = sub_list[0]
for sub in sub_list:
    T = pd.read_csv(os.path.join(meta_dir, sub, f'{sub}_singletrial_{ttl_key}.csv'))
    T['spm_index'] = T.iloc[:,0] + 1

    subset = T[T.regressor == True].copy()
    subset['source_name'] = subset["spm_index"].astype(int).apply(lambda x: f'beta_{x:04d}.nii')
    # 'source_name' >> 'nifti_name'
    for ind, row in subset.iterrows():
#        print(ind, row)
        source_name = os.path.join(spm_dir, sub, row.source_name)
        dest_name = os.path.join(nifti_dir, sub, row.nifti_name + '.nii')
        Path(os.path.join(nifti_dir, sub)).mkdir(parents=True, exist_ok=True)
        print(source_name)
        print(dest_name)
        shutil.copy(source_name, dest_name)

# %%
