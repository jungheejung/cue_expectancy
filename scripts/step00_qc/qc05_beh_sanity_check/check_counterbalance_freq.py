#!/usr/bin/env python3
"""
Checks counterbalance frequncy
there are 2 x 3 conditions (2 cue (high/low) x 3 stimulus intensity (high/med/low)
I want to know if there are equal number of conditions spread across the experiment


columns
subject | total_run_freq | pain_run_freq | vicarious_run_freq | cognitive_run_freq
rows: condition
1,2,3,4,5,6
# 1) for each subject
# 2) glob *beh.csv files 
# 3) count PVC runs respectively and total number of runs
NOTE:
https://www.geeksforgeeks.org/how-to-drop-a-level-from-a-multi-level-column-index-in-pandas-dataframe/
"""
# %% libraries
from genericpath import exists
from importlib.metadata import files
from pathlib import Path
import os
import glob
import pandas as pd
import plotly.io as pio
from datetime import datetime
import numpy as np
import itertools

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
# people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__credits__ = ["Heejung"]
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development"

# %% directories _____________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2]
# data_dir = os.path.join(main_dir, 'data', 'dartmouth', 'd02_preprocessed' )
data_dir = os.path.join(main_dir, 'data','beh', 'beh02_preproc')
child_data = next(os.walk(data_dir))[1]
remove_int = [1, 2, 3, 4, 5]
remove_list = [f"sub-{x:04d}" for x in remove_int]
sub_list = [x for x in child_data if x != remove_list]

# %% SANDBOX
sub = 'sub-0011'
run_list = glob.glob(os.path.join(data_dir, sub, "**",
                     f"{sub}_*_task-social_*_beh.csv"))
beh_fname = sorted(run_list)[0]
beh_df = pd.read_csv(sorted(run_list)[0])
beh_df['param_cond_type']
# %% SANDBOX multiindex
index = pd.MultiIndex.from_tuples([
    ("ses-01", "run-01"),
    ("ses-01", "run-02"),
    ("ses-01", "run-03"),
    ("ses-01", "run-04"),
    ("ses-01", "run-05"),
    ("ses-01", "run-06"),
    ("ses-03", "run-01"),
    ("ses-03", "run-02"),
    ("ses-03", "run-03"),
    ("ses-03", "run-04"),
    ("ses-03", "run-05"),
    ("ses-03", "run-06"),
    ("ses-04", "run-01"),
    ("ses-04", "run-02"),
    ("ses-04", "run-03"),
    ("ses-04", "run-04"),
    ("ses-04", "run-05"),
    ("ses-04", "run-06")
])

# stack 
# runs per session. skip and add 12 NA if no run
# axis 1
for i, sub in enumerate(sorted(sub_list)):
    run_list = []
    try:
        run_list = glob.glob(os.path.join(data_dir, sub, "**", f"{sub}_*_task-social_*_beh.csv"))
        sorted(run_list)
        pd.read_csv(run_list)





df = pd.DataFrame([["Ross", "Joey", "Chandler"],
                   ["Rachel", "", "Monica"]],
                  columns=index)
index = df.index
index. name = "subject"
# %%
