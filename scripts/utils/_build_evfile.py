#!/usr/bin/env python
# encoding: utf-8
# %% libraries ________________________________________________________________________
import pandas as pd
import os, glob
from pathlib import Path
from datetime import datetime


# __author__ = "Heejung Jung"
# __version__ = "1.0.1"
# __email__ = "heejung.jung@colorado.edu"
# __status__ = "Production"


def _build_evfile(df, onset_col, dur_col, mod_col, fname, **dict_map):
    """Creates a 3-column EV txt file for FSL, by combining behavioral and biopac data
    Args:
        df (dataframe): 
                merged dataframe with behavioral biopac data
        onset_col (str): 
                column name from original dataframe
        dur_col (str or float): 
                if string, adds dataframe columns as list; else, add number
        mod_col (str or int): 
                if str, following argument holds dictionary. 
                Use dictionary to map contrast values.
                else if int, insert directly to dataframe
    Returns:
        new_df (pandas dataframe): saved within function
    """
    new_df = pd.DataFrame()
    new_df['onset'] = df[onset_col] 

    if isinstance(dur_col, str):
        new_df['dur'] = df[dur_col]
    else:
        new_df['dur'] = dur_col
    if isinstance(mod_col, str):
        if dict_map:
            new_df['mod'] = df[mod_col].map(dict_map['dict_map'])
        else:
            new_df['mod'] = df[mod_col]
    else:
        new_df['mod'] = mod_col
    new_df.to_csv(fname, header = None, index = None, sep='\t', mode='w')