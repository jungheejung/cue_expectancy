# %%
import pandas as pd
import os, glob, sys
from datetime import datetime
from os.path import join
# %% directory
main_dir = '/Volumes/spacetop_projects_social/'
script_dir = join(main_dir, 'scripts/step04_SPM/model02_CcEScA/log_glm_cueonly')
logcenter_dir = join(main_dir, 'scripts/logcenter')
fname = join(script_dir, 'glmlog_04-25-2022.txt')
complete = pd.read_csv(fname, names = ['fname'], header = None, sep = None, index_col=False) #, delim_whitespace=True )

# %% COMPLETE ______________________________________________________
complete[['fname', 'status_string']] = complete['fname'].str.split(pat = '.o ', expand = True)
complete['complete'] = complete['status_string'].astype(str).str[-8:].str.contains('complete')
# %% split
complete_subset = complete[complete['complete'] == True]
incomplete_subset = complete[complete['complete'] == False]
# %% save
date = datetime.now().strftime("%m-%d-%Y")
complete_subset['complete_sub'] = complete_subset['status_string'].str.extract(r'(sub-.*(?= complete))', expand = True)
complete_subset.sort_values(by = 'complete_sub', inplace = True)
df_complete = complete_subset.drop_duplicates(subset=['complete_sub'])
df_complete['complete_sub'].to_csv(join(script_dir, f'list_complete_subject_{date}.txt'), index=False)
df_complete['complete_sub'].to_csv(join(logcenter_dir, f's04-glm_complete_subjectlist_{date}.txt'), index=False)
# %% INCOMPLETE ______________________________________________________
incomplete_subject_list = []
for index,row in incomplete_subset.iterrows():
    with open(row.fname + '.o' , 'r') as f:
        last_line = f.readlines()[0]
        incomplete_subject_list.append(f"{last_line}")
# %%
df = pd.DataFrame(incomplete_subject_list, columns= ['log_extract'])
# df[['subject', 'incomplete_id']] = df['subject'].str.split(pat = 'subject id: ', expand = True)
df['subject_id'] = df['log_extract'].str.extract(r'(subject id: .\d+)', expand = True)
df[['id', 'incomplete_num']] = df['subject_id'].str.split(pat = 'subject id: ', expand = True)
# %%
df = df.dropna()
df['incomplete_sub'] =  df["incomplete_num"].astype(int).apply(lambda x: f'sub-{x:04d}')
df.sort_values(by = 'incomplete_sub', inplace = True)
final_incomplete = sorted(list(set(df['incomplete_sub']).difference(complete_subset['complete_sub'])))

date = datetime.now().strftime("%m-%d-%Y")
with open(os.path.join(script_dir, f'list_incomplete_RERUN_{date}.txt'), 'w') as f:
    for row in final_incomplete:
        f.write(str(row) + '\n')

with open(os.path.join(logcenter_dir, f's04-glm_incomplete_RERUN_subjectlist_{date}.txt'), 'w') as f:
    for row in final_incomplete:
        f.write(str(row) + '\n')

# df['incomplete_sub'].to_csv(join(script_dir, f'incomplete_subject_list_{date}.txt'), index=False)

# # %% FIND INTERSECTION ______________________________________________________
# complete_subset['complete_sub']
# df['incomplete_sub']

# final_incomplete
# %%
