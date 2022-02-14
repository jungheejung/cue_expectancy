
# %% import libraries
import os, shutil,sys
from pathlib import Path
import pandas as pd
import traceback
# go into each SPM dir
# based on table, identify beta number
# rename and mv
# isolate_nifti
# %% parameters ________________________________________________________________________
ttl_key = sys.argv[1]
print(ttl_key)
ttl_dict = {
'early':'singletrial_SPM_01-pain-early',
'late':'singletrial_SPM_02-pain-late',
'post':'singletrial_SPM_03-pain-post',
'plateau':'singletrial_SPM_04-pain-plateau'}
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1] # discovery: /dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_social
meta_dir = os.path.join(main_dir, 'data', 'dartmouth', f"d06_{ttl_dict[ttl_key]}")
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
    try: 
        print(f"starting {sub}")
        T = pd.read_csv(os.path.join(meta_dir, sub, f'{sub}_singletrial_{ttl_key}.csv'), index_col = False)
        del T['index']
        T = T.reset_index()
        T['spm_index'] = T.index.tolist() 
        T['spm_index'] = T['spm_index'] +1
        #print(T.columns)
        print(T.head())
        subset = T[T.regressor == True].copy()
        subset['source_name'] = subset["spm_index"].astype(int).apply(lambda x: f'beta_{x:04d}.nii')
        # 'source_name' >> 'nifti_name'
        for ind, row in subset.iterrows():
    #       
            # print(ind, row)
            #print(row['sub'])
            print(row)
            print(row['num'])
            source_fname = os.path.join(spm_dir, sub, row['source_name'])
            nifti_name = f"sub-{row['sub']:04d}_ses-{row['ses']:02d}_run-{row['run']:02d}-pain-{ttl_dict[ttl_key]}_{row['task']}_ev-{row['ev']}-{row['num']:04d}.nii"
            dest_name = os.path.join(nifti_dir, sub, nifti_name)
            Path(os.path.join(nifti_dir, sub)).mkdir(parents=True, exist_ok=True)
            print(source_fname)
            print(dest_name)
            shutil.copy(source_fname, dest_name)
    except:
        with open("exceptions.log", "a") as logfile:
            traceback.print_exc(file=logfile)
# %%
