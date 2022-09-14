#!/usr/bin/env python3
"""
Visualizes expected run length

Each task has an expected run length. Cross compare. 
visualize on plotly

TODO:
1. go in to behaviorla dir
2. for each subject session, run, extract metadata
3. grab column param_experiment_duration
4. save in pandas
"""
# %% libraries
from genericpath import exists
import dash_table
import dash
from pathlib import Path
from plotly.subplots import make_subplots
import os, glob
import plotly.graph_objects as go
import plotly.express as px
import pandas as pd
import plotly.io as pio
from datetime import datetime
import numpy as np
import itertools

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

# %% directories _____________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2]
# data_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd02_preprocessed' )
data_dir = os.path.join(main_dir, 'data', 'd02_preproc-beh', 'd02_preprocessed' )
child_data = next(os.walk(data_dir))[1]
remove_int = [1,2,3,4,5]
remove_list = [f"sub-{x:04d}" for x in remove_int]
sub_list = [x for x in child_data if x != remove_list]

# %% parameters _____________________________________________________________
runlength = {
    'task-social':398.76
}
# %%
ses_list = [1,3,4]
sub_ses = list(itertools.product(sorted(sub_list), ses_list))
task = 'task-social'
column_list = ['sub','ses','run','run_type','meta','experiment_dur']
total_df = pd.DataFrame(columns = column_list)
flag = []
# %% 

for i, (sub, ses_ind) in enumerate(sub_ses):
    try: 
        # print( sub, ses_ind)
        ses = f"ses-{ses_ind:02d}"
        run_list = glob.glob(os.path.join(data_dir, sub, ses, f"{sub}_{ses}_task-social_*_beh.csv"))
        # if run_list:
        for ind, run_fpath in enumerate(run_list):
            # new_df = pd.DataFrame(np.zeros(1,len(column_list)), columns = column_list)
            run_fname = os.path.basename(run_fpath)
            run = run_fname.split('_')
            run_type = run_fname.split('_')[3]
            run_df = pd.read_csv(run_fpath)
            total_df = total_df.append({'sub':sub,'ses':ses,
            'run':int(run_type.split('-')[1]),
            'run_type':run_type,
            'task':run_type.split('-')[2],
            'meta':f"{sub}_{ses}_{run_type}", 
            'experiment_dur':run_df['param_experiment_duration'][0]}, 
            ignore_index=True)

    # append dataframe
    except:
        print(f"error in {sub}_{ses}")
        flag.append(f"{sub}_{ses}_{run_type}")
        # save error in log file
    # if file exists
# %%
filename = os.path.join(current_dir, 'experiment_length.csv')
total_df.to_csv(filename, index=False)