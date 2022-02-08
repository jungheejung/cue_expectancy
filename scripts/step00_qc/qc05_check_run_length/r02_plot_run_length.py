#!/usr/bin/env python3

"""Plot experiment duration based on pandas dataframe
"""
# %%
import pandas as pd
import plotly.express as px
__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "GPL"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

# %%
filename = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step00_qc/qc05_check_run_length/experiment_length.csv'
df = pd.read_csv(filename)

runlength = {
    'task-social':398.76

}

# %%
pd.options.plotting.backend = "plotly"
mask = df['sub'].isin(['sub-0001'])
filter = df[~mask]
fig = filter[['experiment_dur']].plot(kind='hist',
                                    nbins=500,
                                    histnorm='probability density',
                                    opacity=0.75,
                                    marginal='box',
                                    title='experiment duration for task-social')

fig.add_shape(type='line',
                    yref="y",
                    xref="x",
                    x0=398.76,
                    y0=-1,
                    x1=398.76,
                    y1= 10,
                    # y1=df['experiment_dur'].max()*1,
                    line={'dash': 'dash', 'color':'red'}
                    )
fig
fig.write_image('./plot_run_length.png')
# %%
