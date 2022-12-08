# %%
import os, glob
import pandas as pd

# glob.glob()
fpath = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/data/beh/beh02_preproc/sub-0010/ses-04/sub-0010_ses-04_task-social_run-02-pain_beh.csv'
df = pd.read_csv(fpath)

df2 = df.drop("Unnamed: 0", axis = 1)
# %%
df2.to_csv(fpath, index = False)