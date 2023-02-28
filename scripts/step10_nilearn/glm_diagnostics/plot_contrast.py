# load nifti with contrast image
# use nilearn and numpy to plot
# use plotly for interactive outlier selection
# %%
import os, glob
from nilearn import masking
from nilearn.plotting import plot_carpet
from sklearn.utils import Bunch
import numpy as np
import seaborn as sns
import pandas as pd
from nilearn import image
from matplotlib import pyplot as plt
import plotly.figure_factory as ff
import numpy as np
import pandas as pd
import plotly.graph_objects as go
# %%
data = Bunch()
nii_fname = '/Volumes/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond/1stLevel/sub-0013/con_0020.nii'
cmaps_list = glob.glob('/Volumes/spacetop_projects_cue/analysis/fmri/spm/univariate/model01_6cond/1stLevel/*/con_0020.nii')
mask = '/Users/h/Documents/MATLAB/CanlabCore/CanlabCore/canlab_canonical_brains/Canonical_brains_surfaces/brainmask_canlab.nii'
data['cmaps'] = sorted(cmaps_list)
data['sub_list'] = [os.path.basename(os.path.dirname(i)) for i in data.cmaps]
from nilearn.plotting import plot_stat_map, plot_anat, plot_img
plot_img(data.cmaps[2], colorbar=True, cbar_tick_format="%i")
# plot_anat(data.anat, colorbar=True, cbar_tick_format="%i")

# %% plot stacked contrast namps plot 1 __________________________________________________________________________________

data['stacked_cmaps'] = image.concat_imgs(data.cmaps)
fig, ax = plt.subplots(1,1)
stacked_np = image.get_data(data['stacked_cmaps'])
display = plot_carpet(data.stacked_cmaps, 
                      mask, t_r = None, figure = fig, axes =ax )
display.axes[1].set_ylabel('voxels')
display.axes[1].set_xlabel(f'participants (N= {len(data.cmaps)})')
display.show()
# %%
k = np.reshape(stacked_np, (73*86*73,60))
fig = go.Figure(data=go.Heatmap(
        z = k.T,
        y = data.sub_list,
        colorscale='Viridis'))

# %% plot 1 dash __________________________________________________________________________________


# %% plot 4 __________________________________________________________________________________

k = np.reshape(stacked_np, (73*86*73,60))
k.shape #(458294, 60)
participant_df = pd.DataFrame(k)
participant_df[0][~np.isnan(participant_df[0])]
sns.kdeplot(
    # x = participant_df.index,
    # hue = participant_df.columns, #'class_name',
    # kind = 'kde',
    data = participant_df,
)
# %% plot 4 dash__________________________________________________________________________________


df = participant_df
fig = ff.create_distplot([df[c].dropna() for c in df.columns], df.columns, bin_size=100)
fig.show()
# %% plot 5 __________________________________________________________________________________
k_mean = np.nanmean(k, axis=0)
k_std = np.nanstd(k, axis = 0)
data = {'mean':k_mean,
           'std':k_std,}
k_df = pd.DataFrame.from_dict(data)
# define chart 
fig, ax = plt.subplots()

#create chart
ax.bar(x=np.arange(len(k_df)), #x-coordinates of bars
       height=k_df['mean'], #height of bars
       yerr=k_df['std'], #error bar width
       capsize=4) #length of error bar caps
# k_df.set_index(index, inplace=True)
# TODO: change axis label

# %% plot 5 in plotly __________________________________________________________________________________


fig = go.Figure(data=go.Scatter(
        x=[0, 1, 2],
        y=[6, 10, 2],
        error_y=dict(
            type='data', # value of error bar given in data coordinates
            array=[1, 2, 3],
            visible=True)
    ))

fig = go.Figure(data=go.Scatter(
        x=np.arange(len(k_df)),
        y=k_df['mean'],
        error_y=dict(
            type='data', # value of error bar given in data coordinates
            array=k_df['std'],
            visible=True)
    ))
fig.show()
# %%
plt.hist(stacked_np)

# %%
from nilearn.datasets import fetch_localizer_contrasts

n_subjects = 16
data = fetch_localizer_contrasts(
    ['left vs right button press'],
    n_subjects,
    get_tmaps=True,
    legacy_format=False,
)
# %%
data