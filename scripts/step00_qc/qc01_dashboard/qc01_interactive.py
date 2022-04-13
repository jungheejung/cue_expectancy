
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

# %% directories _____________________________________________________________
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2]
# %% color based on value
# https://plotly.com/python/table/#cell-color-based-on-variable
# https://stackoverflow.com/questions/61686382/change-the-text-color-of-cells-in-plotly-table-based-on-value-string

# %% load data with select columns
st = pd.read_csv(os.path.join(main_dir, 'spacetop-scannotes_01-27-2022.csv'))
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


fig.write_html(os.path.join(main_dir, "TEST.html"))

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