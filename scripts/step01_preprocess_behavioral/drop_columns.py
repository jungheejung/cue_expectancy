# %%
import os, glob
import pandas as pd
from os.path import join

data_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/beh/beh02_preproc/'
flist = glob.glob(join(data_dir, '**', 'sub-*_task-social*_beh.csv'), recursive=True)

# %%
for fpath in sorted(flist):
    df = pd.read_csv(fpath)
    drop = [col for col in df.columns if 'Unnamed' in col]
    if len(drop) > 0:
        df2 = df.drop("Unnamed: 0", axis = 1)
        df2.to_csv(fpath, index = False)
    else:
        continue
# %%
