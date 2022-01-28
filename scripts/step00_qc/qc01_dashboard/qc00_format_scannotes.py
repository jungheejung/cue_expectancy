#!/usr/bin/env python3
"""
This code reformats spacetop scannotes.
Download from google sheets.
It will reformat column names, extract information on session and task, run. 
After reformat, complete vs incomplete runs will be color coded.  
"""


# %% libraries
from collections import OrderedDict
import dash_table
import dash
import openpyxl
from pathlib import Path
from plotly.subplots import make_subplots
import os
import plotly.graph_objects as go
import plotly.express as px
import pandas as pd
import numpy as np
import plotly.io as pio
from datetime import datetime
pio.renderers.default = "vscode"
# https: // stackoverflow.com/questions/61686382/change-the-text-color-of-cells-in-plotly-table-based-on-value-string

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
# %% load dataframe _____________________________________________________________
data_xls = pd.read_excel(os.path.join(main_dir,'scripts','step00_qc','Copy of ST_Participants.xlsx'), 
'scan_info', dtype=str, index_col=None)
data_xls.to_csv(os.path.join(main_dir,'scripts','step00_qc','csvfile.csv'), encoding='utf-8', index=False)

# %%
df = pd.read_csv(os.path.join(main_dir, 'scripts',
                 'step00_qc', 'csvfile.csv'))
df.columns = df.columns.str.replace(' +', '_', regex=True).str.replace(
    '\n+', '_', regex=True).str.replace('\r+', '_', regex=True).str.replace(',', '_', regex=True)
columns_to_drop = ['Staff', 'Time_in_Scanner', 'Audio_Check_(during_scout)',
                   'T-Points_for_scan_time?', '#_T-Points', 'GitPush?', 'BioPac_Saved?', 'Data_on_Rolando?', 'Data_sent_comments?', 'Post-scan:_Debrief']
df.drop(labels=columns_to_drop, inplace=True, axis=1)

# split dataframes _____________________________________________________________
ses_01 = df[df["Session_#"] == 'ses-01']
ses_02 = df[df["Session_#"] == 'ses-02']
ses_03 = df[df["Session_#"] == 'ses-03']
ses_04 = df[df["Session_#"] == 'ses-04']

column_map = {
    'ses_01': {
        'drop': ['SID', 'Date', 'ses-04_Fractional__Run-01', 'ses-04_Fractional__Run-02',
                 'ses-03_short-video', 'ses-02_Narratives__Run-01',
                 'ses-02_Narratives__Run-02', 'ses-02_Narratives__Run-03',
                 'ses-02_Narratives__Run-04', 'ses-02_Faces__Run-01',
                 'ses-02_Faces_Run-02', 'ses-02_Faces__Run-03'],
        'rename': {'A#': 'ses-01_accession',
                   'Session_#': 'ses-01',
                   'ses-01_T1__(Structural)': 'T1_01status',
                   'ses-01_T1_Quality_Check': 'T1_02quality',
                   'ses-01_T1_actions': 'T1_03actions',
                   'ses-01_DWI': 'DWI',
                   'ses-01_03_04_PVC__Run-01': 'ses-01_task-social_run-01',
                   'ses-01_03_04_PVC__Run-02': 'ses-01_task-social_run-02',
                   'ses-01_03_04_PVC__Run-03': 'ses-01_task-social_run-03',
                   'ses-01_03_04_PVC__Run-04': 'ses-01_task-social_run-04',
                   'ses-01_03_04_PVC__Run-05': 'ses-01_task-social_run-05',
                   'ses-01_03_04_PVC__Run-06': 'ses-01_task-social_run-06',
                   'ses-01_02_03_04_Align_Videos__Run-01': 'ses-01_task-alignvideo_run-01',
                   'ses-01_02_03_04_Align_Videos__Run-02': 'ses-01_task-alignvideo_run-02',
                   'ses-01_02_03_04_Align_Videos__Run-03': 'ses-01_task-alignvideo_run-03',
                   'ses-01_02_03_04_Align_Videos__Run-04': 'ses-01_task-alignvideo_run-04',
                   'Scan_comments?': 'ses-01_scan-comments',
                   'BioPac?': 'ses-01_biopac',
                   'EDA_location': 'ses-01_EDA',
                   'PPD_location': 'ses-01_PPG',
                   'BioPac_Comments?': 'ses-01_biopac'}
    },
    'ses_02': {
        'drop': ['SID', 'Date', 'ses-01_T1__(Structural)', 'ses-01_T1_Quality_Check',
                 'ses-01_T1_actions', 'ses-01_DWI',
                 'ses-04_Fractional__Run-01', 'ses-04_Fractional__Run-02',
                 'ses-01_03_04_PVC__Run-01', 'ses-01_03_04_PVC__Run-02',
                 'ses-01_03_04_PVC__Run-03', 'ses-01_03_04_PVC__Run-04',
                 'ses-01_03_04_PVC__Run-05', 'ses-01_03_04_PVC__Run-06',
                 'ses-03_short-video'],
        'rename': {'A#': 'ses-02_accession',
                   'Session_#': 'ses-02',
                   'ses-02_Narratives__Run-01': 'ses-02_task-narratives_run-01',
                   'ses-02_Narratives__Run-02': 'ses-02_task-narratives_run-02',
                   'ses-02_Narratives__Run-03': 'ses-02_task-narratives_run-03',
                   'ses-02_Narratives__Run-04': 'ses-02_task-narratives_run-04',
                   'ses-02_Faces__Run-01': 'ses-02_task-faces_run-01',
                   'ses-02_Faces_Run-02': 'ses-02_task-faces_run-02',
                   'ses-02_Faces__Run-03': 'ses-02_task-faces_run-03',
                   'ses-01_02_03_04_Align_Videos__Run-01': 'ses-02_task-alignvideo_run-01',
                   'ses-01_02_03_04_Align_Videos__Run-02': 'ses-02_task-alignvideo_run-02',
                   'ses-01_02_03_04_Align_Videos__Run-03': 'ses-02_task-alignvideo_run-03',
                   'ses-01_02_03_04_Align_Videos__Run-04': 'ses-02_task-alignvideo_run-04',
                   'Scan_comments?': 'ses-02_scan-comments',
                   'BioPac?': 'ses-02_biopac',
                   'EDA_location': 'ses-02_EDA',
                   'PPD_location': 'ses-02_PPG',
                   'BioPac_Comments?': 'ses-02_biopac'}
    },
    'ses_03': {
        'drop': ['SID', 'Date', 'ses-01_T1__(Structural)',
                 'ses-01_T1_Quality_Check', 'ses-01_T1_actions', 'ses-01_DWI',
                 'ses-04_Fractional__Run-01', 'ses-04_Fractional__Run-02', 'ses-02_Narratives__Run-01',
                 'ses-02_Narratives__Run-02', 'ses-02_Narratives__Run-03',
                 'ses-02_Narratives__Run-04', 'ses-02_Faces__Run-01',
                 'ses-02_Faces_Run-02', 'ses-02_Faces__Run-03',
                 'ses-01_02_03_04_Align_Videos__Run-04', ],
        'rename': {'A#': 'ses-03_accession',
                   'Session_#': 'ses-03',
                   'ses-01_03_04_PVC__Run-01': 'ses-03_task-social_run-01',
                   'ses-01_03_04_PVC__Run-02': 'ses-03_task-social_run-02',
                   'ses-01_03_04_PVC__Run-03': 'ses-03_task-social_run-03',
                   'ses-01_03_04_PVC__Run-04': 'ses-03_task-social_run-04',
                   'ses-01_03_04_PVC__Run-05': 'ses-03_task-social_run-05',
                   'ses-01_03_04_PVC__Run-06': 'ses-03_task-social_run-06',
                   'ses-03_short-video': 'ses-03_task-shortvideo',
                   'ses-01_02_03_04_Align_Videos__Run-01': 'ses-03_task-alignvideo_run-01',
                   'ses-01_02_03_04_Align_Videos__Run-02': 'ses-03_task-alignvideo_run-02',
                   'ses-01_02_03_04_Align_Videos__Run-03': 'ses-03_task-alignvideo_run-03',
                   'Scan_comments?': 'ses-03_scan-comments',
                   'BioPac?': 'ses-03_biopac',
                   'EDA_location': 'ses-03_EDA',
                   'PPD_location': 'ses-03_PPG',
                   'BioPac_Comments?': 'ses-03_biopac'}
    },
    'ses_04': {
        'drop': ['SID', 'Date', 'ses-01_T1__(Structural)', 'ses-01_T1_Quality_Check',
                 'ses-01_T1_actions', 'ses-01_DWI',
                 'ses-03_short-video', 'ses-02_Narratives__Run-01',
                 'ses-02_Narratives__Run-02', 'ses-02_Narratives__Run-03',
                 'ses-02_Narratives__Run-04', 'ses-02_Faces__Run-01',
                 'ses-02_Faces_Run-02', 'ses-02_Faces__Run-03',
                 'ses-01_02_03_04_Align_Videos__Run-03',
                 'ses-01_02_03_04_Align_Videos__Run-04'],
        'rename': {'A#': 'ses-04_accession',
                   'Session_#': 'ses-04',
                   'ses-04_Fractional__Run-01': 'ses-04_task-fractional_run-01',
                   'ses-04_Fractional__Run-02': 'ses-04_task-fractional_run-02',
                   'ses-01_03_04_PVC__Run-01': 'ses-04_task-social_run-01',
                   'ses-01_03_04_PVC__Run-02': 'ses-04_task-social_run-02',
                   'ses-01_03_04_PVC__Run-03': 'ses-04_task-social_run-03',
                   'ses-01_03_04_PVC__Run-04': 'ses-04_task-social_run-04',
                   'ses-01_03_04_PVC__Run-05': 'ses-04_task-social_run-05',
                   'ses-01_03_04_PVC__Run-06': 'ses-04_task-social_run-06',
                   'ses-01_02_03_04_Align_Videos__Run-01': 'ses-04_task-alignvideo_run-01',
                   'ses-01_02_03_04_Align_Videos__Run-02': 'ses-04_task-alignvideo_run-02',
                   'Scan_comments?': 'ses-04_scan-comments',
                   'BioPac?': 'ses-04_biopac',
                   'EDA_location': 'ses-04_EDA',
                   'PPD_location': 'ses-04_PPG',
                   'BioPac_Comments?': 'ses-04_biopac'
                   }},

}

# rename and drop _____________________________________________________________
# ses_01.columns.str.replace(column_map['ses_01']['rename'])
ses_01.drop(labels=column_map['ses_01']['drop'], inplace=True, axis=1)
ses_01.rename(columns=column_map['ses_01']['rename'], inplace=True)
ses_02.drop(labels=column_map['ses_02']['drop'], inplace=True, axis=1)
ses_02.rename(columns=column_map['ses_02']['rename'], inplace=True)
ses_03.drop(labels=column_map['ses_03']['drop'], inplace=True, axis=1)
ses_03.rename(columns=column_map['ses_03']['rename'], inplace=True)
ses_04.drop(labels=column_map['ses_04']['drop'], inplace=True, axis=1)
ses_04.rename(columns=column_map['ses_04']['rename'], inplace=True)

# merge and final product
df_12 = pd.merge(ses_01, ses_02, on='sub-ID', how='outer')
df_123 = pd.merge(df_12, ses_03, on='sub-ID', how='outer')
stdf = pd.merge(df_123, ses_04, on='sub-ID', how='outer')
# %% save with timestamp _____________________________________________________________
st = stdf.set_index('sub-ID')
date = datetime.now().strftime("%m-%d-%Y")
st.to_csv(os.path.join(main_dir, f"spacetop-scannotes_{date}.csv"))

# %%
