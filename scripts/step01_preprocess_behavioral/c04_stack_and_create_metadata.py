# purpose, grab all participants from d_beh in social infleunce cognitive task and stack all sessions into participant-wise csv files
# steps
# glob data directory
# input: github.com/spatialtopology/d_beh
# output dir: social_influence_analysis > data > d02_preprocessed_meta

# %% libraries __________________________________________________
import os
import glob
import sys
from pathlib import Path
import pandas as pd
import itertools

# %% directories __________________________________________________
data_dir = '/Users/h/Dropbox/projects_dropbox/d_beh'
print(f"input data directory: {data_dir}")
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1]
print(f"script/output data directory: {main_dir}")
sub_folder = next(os.walk(data_dir))[1]
sub_list = [s for s in sub_folder if "sub" in s]
task_list = ['pain', 'cognitive', 'vicarious']
total_list = list(itertools.product(sub_list, task_list))

# %% glob all files and stack __________________________________________________
# sub = 'sub-0009'
for i, (sub, task) in enumerate(total_list):
    print(sub)
    sub_files = sorted(glob.glob(os.path.join(
        data_dir, sub, 'task-social', '*', f'*{task}_beh.csv')))
    li = []
    if sub_files:
        for filename in sub_files:
            df = pd.read_csv(filename, index_col=None, header=0)
            li.append(df)

        total_sub = pd.concat(li, axis=0, ignore_index=True)
        total_sub_fldr = os.path.join(
            main_dir, 'data', 'dartmouth', 'd02_preprocessed_meta', sub)
        Path(total_sub_fldr).mkdir(parents=True, exist_ok=True)
        total_sub.to_csv(os.path.join(
            total_sub_fldr,  f"{sub}_task-social_{task}_meta.csv"), index=False)
# %%
