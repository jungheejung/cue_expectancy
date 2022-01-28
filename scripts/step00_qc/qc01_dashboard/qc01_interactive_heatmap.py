#!/usr/bin/env python3
"""
This code reads the formatted ST participant scannotes from 
qc00_format_scannotes.py
It will plot a dash board in plotly, for interactive use
"""

# %% libraries _____________________________________________________________

import dash_table
import dash
from pathlib import Path
from plotly.subplots import make_subplots
import os
import plotly.graph_objects as go
import plotly.express as px
import pandas as pd
import plotly.io as pio
from datetime import datetime
import numpy as np

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

#

# %% directories _____________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2]

# %% parameters
bvals = [0,2,4,6, 8]
colors = ['#b4bbc4', '#ff6666', '#dfedda' , '#94e88d']
dcolorsc = discrete_colorscale(bvals, colors)

bvals = np.array(bvals)
tickvals = [np.mean(bvals[k:k+2]) for k in range(len(bvals)-1)] #position with respect to bvals where ticktext is displayed
# ticktext = [f'<{bvals[1]}'] + [f'{bvals[k]}-{bvals[k+1]}' for k in range(1, len(bvals)-2)]+[f'>{bvals[-2]}']
ticktext = ['NA', 'complete_dontuse', 'repeat_use, incomplete_use', 'complete']

# %% color based on value
# https://plotly.com/python/table/#cell-color-based-on-variable
# https://stackoverflow.com/questions/61686382/change-the-text-color-of-cells-in-plotly-table-based-on-value-string

# %% load data with select columns
st = pd.read_csv(os.path.join(main_dir, 'spacetop-scannotes_01-27-2022.csv'))
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
color_dict = {'complete': 7, # green
'Yes': 7, # green
'no_data': 1, # gray
'complete_dontuse': 3, # red
'repeat_use': 5, # shaded green
'repeat_dontuse':3,
'incomplete_use': 5, # shaded green
'Partial': 5, # shaded green
'Incomplete': 5,
np.nan: 1} # gray
 
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

import io
from base64 import b64encode

import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import plotly.express as px

buffer = io.StringIO()
app = dash.Dash(__name__)

fig.write_html(buffer)
html_bytes = buffer.getvalue().encode()
encoded = b64encode(html_bytes).decode()
app.layout = html.Div([
    dcc.Graph(id="graph", figure=fig),
    html.A(
        html.Button("Download HTML"), 
        id="download",
        href="data:text/html;base64," + encoded,
        download="plotly_graph.html"
    )
])

app.run_server(debug=True)
# %%
