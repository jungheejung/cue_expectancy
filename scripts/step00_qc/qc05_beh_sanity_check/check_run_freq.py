#!/usr/bin/env python3
"""
Checks number of runs per participant

columns
subject | total_run_freq | pain_run_freq | vicarious_run_freq | cognitive_run_freq
# 1) for each subject
# 2) glob *beh.csv files 
# 3) count PVC runs respectively and total number of runs
"""
# %% libraries
from genericpath import exists
from importlib.metadata import files
from pathlib import Path
import os, glob
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
print(main_dir)
# data_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd02_preprocessed' )
data_dir = os.path.join(main_dir, 'data','beh', 'beh02_preproc')
child_data = next(os.walk(data_dir))[1]
remove_int = [1,2,3,4,5]
remove_list = [f"sub-{x:04d}" for x in remove_int]
sub_list = [x for x in child_data if x != remove_list]

# %%
task = 'task-cue'
column_list = ['sub','total_run_freq','pain_run_freq','vicarious_run_freq','cognitive_run_freq']
total_df = pd.DataFrame(columns = column_list)
flag = []

# %%
for i, sub in enumerate(sorted(sub_list)):
    run_list = []
    try:
        run_list = glob.glob(os.path.join(data_dir, sub, "**", f"{sub}_*_beh.csv"))
        total_run_freq = len(run_list)
        p_flist = [p for p in run_list if 'pain' in os.path.basename(p) ]
        v_flist = [v for v in run_list if 'vicarious' in os.path.basename(v) ]
        c_flist = [c for c in run_list if 'cognitive' in os.path.basename(c) ]

        run_dict = {
            'sub':sub,
            'total_run_freq': len(run_list),
            'pain_run_freq': len(p_flist),
            'vicarious_run_freq': len(v_flist),
            'cognitive_run_freq': len(c_flist)
        }

        run_dict_df = pd.DataFrame([run_dict])
        total_df = pd.concat([total_df, run_dict_df], ignore_index=True)
    except:
        print(f"error in {sub}")
        flag.append(f"{sub}")

# save as
filename = os.path.join(current_dir, 'run_frequency.csv')
total_df.to_csv(filename, index=False)


