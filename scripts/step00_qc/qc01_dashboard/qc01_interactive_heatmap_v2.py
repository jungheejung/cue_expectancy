#!/usr/bin/env python3
"""
This code reads the formatted ST participant scannotes from 
qc00_format_scannotes.py
It will plot a dash board in plotly, for interactive use
"""

# %% libraries _____________________________________________________________
import dash
import dash_core_components as dcc
import dash_html_components as html
import dash_table
import dash_bio as dashbio
import urllib.request as urlreq
from dash.dependencies import Input, Output, ClientsideFunction
from datetime import datetime as dt
from pathlib import Path
import os
import pandas as pd
import numpy as np
import plotly.graph_objects as go
import plotly.express as px
import plotly.io as pio
from plotly.subplots import make_subplots
from datetime import datetime
import io
from base64 import b64encode



__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 



# %% functions _____________________________________________________________
def discrete_colorscale(bvals, colors):
    """
    bvals - list of values bounding intervals/ranges of interest
    colors - list of rgb or hex colorcodes for values in [bvals[k], bvals[k+1]],0<=k < len(bvals)-1
    returns the plotly  discrete colorscale
    __author__ https://chart-studio.plotly.com/~empet/15229/heatmap-with-a-discrete-colorscale/#/
    """
    if len(bvals) != len(colors)+1:
        raise ValueError('len(boundary values) should be equal to  len(colors)+1')
    bvals = sorted(bvals)     
    nvals = [(v-bvals[0])/(bvals[-1]-bvals[0]) for v in bvals]  #normalized values
    
    dcolorscale = [] #discrete colorscale
    for k in range(len(colors)):
        dcolorscale.extend([[nvals[k], colors[k]], [nvals[k+1], colors[k]]])
    return dcolorscale    

def description_card():
    """
    :return: A Div containing dashboard title & descriptions.
    """
    return html.Div(
        id="description-card",
        children=[
            html.H5("Clinical Analytics"),
            html.H3("Welcome to the Clinical Analytics Dashboard"),
            html.Div(
                id="intro",
                children="Explore clinic patient volume by time of day, waiting time, and care score. Click on the heatmap to visualize patient experience at different time points.",
            ),
        ],
    )
clinic_list = ['ses-01', 'ses-02', 'ses-03', 'ses-04']
admit_list = ['task-social', 'task-align', 'task-short', 'task-faces', 'task-narratives','task-fractional']

def generate_control_card():
    """
    :return: A Div containing controls for graphs.
    """
    return html.Div(
        id="control-card",
        children=[
            html.P("Select Clinic"),
            dcc.Dropdown(
                id="clinic-select",
                options=[{"label": i, "value": i} for i in clinic_list],
                value=clinic_list[0],
            ),
            html.Br(),
            html.P("Select Check-In Time"),
            dcc.DatePickerRange(
                id="date-picker-select",
                start_date=dt(2014, 1, 1),
                end_date=dt(2014, 1, 15),
                min_date_allowed=dt(2014, 1, 1),
                max_date_allowed=dt(2014, 12, 31),
                initial_visible_month=dt(2014, 1, 1),
            ),
            html.Br(),
            html.Br(),
            html.P("Select Admit Source"),
            dcc.Dropdown(
                id="admit-select",
                options=[{"label": i, "value": i} for i in admit_list],
                value=admit_list[:],
                multi=True,
            ),
            html.Br(),
            html.Div(
                id="reset-btn-outer",
                children=html.Button(id="reset-btn", children="Reset", n_clicks=0),
            ),
        ],
    )

#

# %% directories _____________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2]

# %% parameters
color_dict = {'complete': 7, # green
'Yes': 7, # green
'no_data': 1, # gray
'complete_dontuse': 3, # red
'repeat_use': 5, # shaded green
'repeat_dontuse':3,
'incomplete_use': 5, # shaded green
'Partial': 3, # shaded green
'Incomplete': 3,
np.nan: 1} # gray

bvals = [0,2,4,6, 8]
colors = ['#F2F3F4', '#ff5964', '#F4D03F' , '#2ECC71']
dcolorsc = discrete_colorscale(bvals, colors)

bvals = np.array(bvals)
tickvals = [np.mean(bvals[k:k+2]) for k in range(len(bvals)-1)] #position with respect to bvals where ticktext is displayed
# ticktext = [f'<{bvals[1]}'] + [f'{bvals[k]}-{bvals[k+1]}' for k in range(1, len(bvals)-2)]+[f'>{bvals[-2]}']
ticktext = ['No data', 'complete_dontuse', 'repeat_use, incomplete_use', 'complete']

# %% color based on value
# https://plotly.com/python/table/#cell-color-based-on-variable
# https://stackoverflow.com/questions/61686382/change-the-text-color-of-cells-in-plotly-table-based-on-value-string

# %% load data with select columns
st = pd.read_csv(os.path.join(main_dir, 'resources','spacetop-scannotes_01-27-2022.csv'))
plt_st = st.drop(labels=

['ses-01','ses-02','ses-03','ses-04',
'T1_02quality','T1_03actions', 'ses-01_scan-comments','ses-02_scan-comments',
'ses-03_scan-comments','ses-04_scan-comments',
'ses-01_accession',
'ses-02_accession',
'ses-03_accession',
'ses-04_accession',
'ses-01_biopac', 'ses-02_biopac','ses-03_biopac','ses-04_biopac',
'ses-01_EDA','ses-02_EDA','ses-03_EDA','ses-04_EDA',
'ses-01_PPG','ses-02_PPG','ses-03_PPG','ses-04_PPG',
'ses-01_biopac','ses-02_biopac','ses-03_biopac','ses-04_biopac',
'ses-01_biopac.1','ses-02_biopac.1','ses-03_biopac.1','ses-04_biopac.1'], axis = 1)

# df_plotly = plot_st.map(color_dict)
# %%

 
plt_clr = plt_st.replace(color_dict)
plt_clr.set_index('sub-ID', inplace=True)
# https://cmdlinetips.com/2021/05/pandas-applymap-change-values-of-dataframe/#:~:text=Pandas%20applymap()%20function%20takes,the%20elements%20in%20data%20frame.


# figure building
# %%
# fig = px.imshow(plt_val.T)
# fig.show()
# plt_clr.set_index('sub-ID', inplace=True)
def df_to_plotly(df):
    return {'z': df.values.tolist(),
            'x': df.columns.tolist(),
            'y': df.index.tolist()}
df_heatmap = df_to_plotly(plt_clr)

fig = go.Figure(data=go.Heatmap(df_to_plotly(plt_clr.T),
colorscale = dcolorsc,
xgap = 1,
ygap = 1,
colorbar = dict(thickness=25, 
                                     tickvals=tickvals, 
                                     ticktext=ticktext)))

fig.update_layout(
    title={
        'text': "Spacetop Data Collection Dashboard",
        'y':0.95,
        'x':0.5,
        'xanchor': 'center',
        'yanchor': 'top'})


fig.show()

fig.write_html(os.path.join(main_dir, "heatmap.html"))

# interactive dash _________________________________________



buffer = io.StringIO()
# app = dash.Dash(__name__)
app = dash.Dash(
    __name__,
    meta_tags=[{"name": "viewport", "content": "width=device-width, initial-scale=1"}],
)
app.title = "Clinical Analytics Dashboard"

server = app.server
app.config.suppress_callback_exceptions = True
# fig.write_html(buffer)
# html_bytes = buffer.getvalue().encode()


# encoded = b64encode(html_bytes).decode()
# app.layout =   html.Div([
#     dcc.Graph(id="graph", figure=fig),
#     html.A(
#         html.Button("Download HTML"), 
#         id="download",
#         href="data:text/html;base64," + encoded,
#         download="plotly_graph.html"
#     )
# ])

app.layout = html.Div([
    html.Div(children=[
        html.Label('Dropdown'),
        dcc.Dropdown(['New York City', 'Montréal', 'San Francisco'], 'Montréal'),

        html.Br(),
        html.Label('Multi-Select Dropdown'),
        dcc.Dropdown(['New York City', 'Montréal', 'San Francisco'],
                     ['Montréal', 'San Francisco'],
                     multi=True),

        html.Br(),
        html.Label('Radio Items'),
        dcc.RadioItems(['New York City', 'Montréal', 'San Francisco'], 'Montréal'),
    ], style={'padding': 10, 'flex': 1}),

    html.Div(children=[
        html.Label('Checkboxes'),
        dcc.Checklist(['New York City', 'Montréal', 'San Francisco'],
                      ['Montréal', 'San Francisco']
        ),

        html.Br(),
        html.Label('Text Input'),
        dcc.Input(value='MTL', type='text'),

        html.Br(),
        html.Label('Slider'),
        dcc.Slider(
            min=0,
            max=9,
            marks={i: f'Label {i}' if i == 1 else str(i) for i in range(1, 6)},
            value=5,
        ),
    ], style={'padding': 10, 'flex': 1})
], style={'display': 'flex', 'flex-direction': 'row'})

if __name__ == '__main__':
    app.run_server(debug=True)
# %%
