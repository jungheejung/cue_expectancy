#!/usr/bin/env python3

"""
based on collected data in https://github.com/spatialtopology/d_beh
check the order of the runs
compile into a csv file

"""
# %%
import pandas as pd
import numpy as np
import os, glob
from os.path import join
import re
from pathlib import Path 
__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

# glob the git dir
# %%
git_dir = '/Users/h/Dropbox/projects_dropbox/d_beh'
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1]
print(current_dir)
print(main_dir)

run_list = glob.glob(join(git_dir, 'sub-*', 'task-social', 'ses-*', '*.csv'))
# len_sub = len(glob.glob(join(git_dir, 'sub-*')))
sub_folders = next(os.walk(git_dir))[1]
sub_list = [i for i in sub_folders if i.startswith('sub-')]
df_run = pd.DataFrame(np.nan, 
                    index=range(len(sub_list)*3),
                    columns= ['sub','ses', 'run-01', 'run-02', 'run-03', 'run-04', 'run-05', 'run-06'])
df_run['sub'] = np.repeat(sorted(sub_list), 3)
df_run['ses'] = ['ses-01', 'ses-03', 'ses-04'] * len(sub_list)
# %%
for ind, run_path in enumerate(sorted(run_list)):
    entities = {}
    filename = os.path.basename(run_path)
    entities = dict(
    match.split('-', 1)
    for match in filename.split('_')
    if '-' in match
    )
    sub_bids = f"sub-{ entities['sub']}"
    ses_bids = f"ses-{ entities['ses']}"
    run_num = int(re.findall(r'\d+', entities['run'])[0])
    run_bids = f"run-{run_num:02d}"
    df_run.loc[(df_run['sub'] == sub_bids) & (df_run['ses'] == ses_bids), run_bids] = str(" ".join(re.findall("[a-zA-Z]+", entities['run'])))

df_run.to_csv(join(main_dir,'data','spacetop_task-social_run-metadata.csv'), index = False)