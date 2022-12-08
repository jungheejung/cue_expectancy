# purpose:
# create grids with subject and run info.
# color code based on complete incomplete runs

# load st_participants
# stack according to columns
# reorganize rows

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
pio.renderers.default = "vscode"
# https: // stackoverflow.com/questions/61686382/change-the-text-color-of-cells-in-plotly-table-based-on-value-string

# %% directories
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[1]
# load dataframe _____________________________________________________________
df = pd.read_csv(os.path.join(main_dir, 'scripts',
                 'step00_qc', 'ST_Participants.csv'))
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

# _____________________________________________________________
# ses_01.columns.str.replace(column_map['ses_01']['rename'])
ses_01.drop(labels=column_map['ses_01']['drop'], inplace=True, axis=1)
ses_01.rename(columns=column_map['ses_01']['rename'], inplace=True)
ses_02.drop(labels=column_map['ses_02']['drop'], inplace=True, axis=1)
ses_02.rename(columns=column_map['ses_02']['rename'], inplace=True)
ses_03.drop(labels=column_map['ses_03']['drop'], inplace=True, axis=1)
ses_03.rename(columns=column_map['ses_03']['rename'], inplace=True)
ses_04.drop(labels=column_map['ses_04']['drop'], inplace=True, axis=1)
ses_04.rename(columns=column_map['ses_04']['rename'], inplace=True)


df_12 = pd.merge(ses_01, ses_02, on='sub-ID', how='outer')
df_123 = pd.merge(df_12, ses_03, on='sub-ID', how='outer')
stdf = pd.merge(df_123, ses_04, on='sub-ID', how='outer')
# %%
st = stdf.set_index('sub-ID')
st.to_csv(os.path.join(main_dir, 'spacetop_scannotes_01142022.csv'), index = False)

# s1.index.name = None

# %% color based on value
# https://plotly.com/python/table/#cell-color-based-on-variable
# https://stackoverflow.com/questions/61686382/change-the-text-color-of-cells-in-plotly-table-based-on-value-string

plot_st = st.drop(labels=
['T1_02quality',
       'T1_03actions', 'ses-01_scan-comments','ses-02_scan-comments',
'ses-03_scan-comments','ses-04_scan-comments',
'ses-01_biopac', 'ses-02_biopac','ses-03_biopac','ses-04_biopac',
'ses-01_EDA','ses-02_EDA','ses-03_EDA','ses-04_EDA',
'ses-01_PPG','ses-02_PPG','ses-03_PPG','ses-04_PPG',
'ses-01_biopac','ses-02_biopac','ses-03_biopac','ses-04_biopac'], axis = 1)
# map_color = {"complete": "green", "repeat_use": "purple", "no_data": "red"}
# spacetop_df["color"] = spacetop_df.map(map_color)
# cols_to_show = ["name", "value", "output"]
# %%
# https://dash.plotly.com/datatable/conditional-formatting
app= dash.Dash(__name__)
app.layout= dash_table.DataTable(
    data=plot_st.T.to_dict('records'),
    sort_action='native',
    columns=[{'name': i, 'id': i} for i in plot_st.columns],
    style_data_conditional=[
            {
                'if': {
                    'filter_query': '{{{col}}} = "complete"'.format(col=col),
                    'column_id': col
                },
                'backgroundColor': 'green',
                'color': 'white'
            } for col in plot_st.columns]
)


# %%
color_dict = {'complete': 'green',
'Yes': 'green',
'no_data': 'red',
'complete_dontuse': 'red',
'repeat_use': 'purple',
'incomplete_use': 'yellow',
np.nan: 'grey'}

fc= plot_st.applymap(color_dict.get)
# font_color = fc.applymap(color_dict.get)
font_color = fc.replace(np.nan, "grey")
# font_color = st.T.replace(color_dict).T.values
# font_color = fc.apply(lambda s: np.where(s.str.contains("None"), "grey"), ).values

# font_color=st.apply(lambda s: np.where(s.name == "col1", "black",
#                                        np.where(s.str.contains("complete"), "green"),

#                                        )).T.values
# font_color = ['rgb(40,40,40)', ['rgb(255,0,0)' if v <= 0 else 'rgb(10,10,10)' for v in vals]]

# %%
# plot_st.reset_index(inplace=True)
table_trace= go.Table(
                 header=dict(height=20,
                               values=[
                                   f"<b>{c.title()}</b>" for c in plot_st.columns],
                            #    align = ['left']*3,
                               fill_color='#386dea',
                               font_color='#fcfcfc',
                               font_size=5),
                 cells=dict(values=plot_st.T.values,
                            #   line = 'black',
                            #   align = ['left']*3,
                              font_color='#fcfcfc',
                              font_family="Arial",
                              font_size=5,
                              height=5,
                              fill=dict(color=font_color.T.values))
                             )

layout = go.Layout(autosize=True,width = 2000,
              title_text='spacetop participant',
                   title_x=0.5, showlegend=True)
fig= go.Figure(data=[table_trace], layout=layout)
fig.show()
# %%
import dash_html_components as html
import dash
import dash_core_components as dcc
app= dash.Dash()
app.layout= html.Div([
    dcc.Graph(figure=fig)
])

# # %% second attempt
# trace = go.Table(columnwidth = [.3,.3,.3,.3],
#     header=dict(values=[f"<b>{c.title()}</b>" for c in st.columns],
#                 fill = dict(color='#8849a5'),
#                 font = dict(color = 'white', size = 12),
#                 align = ['left'] ),
#     cells=dict(values=st.T.values,
#                fill = dict(color=[#unique color for the first column
#                                                 ['#b4a8ce' if val >=750 else '#f5f6f7' for val in gameplays] ]),
#                align = ['left'] * 5))

# data = [trace]

# periscope.plotly(data)

fig.write_html(os.path.join(main_dir, "TEST.html"))
# %%
