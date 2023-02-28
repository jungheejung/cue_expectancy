# %%
import mat73
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
# https://stackoverflow.com/questions/17316880/reading-v-7-3-mat-file-in-python
data_dict = mat73.loadmat('/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/resources/model01_6conditions_sub-0069_SPM.mat')
# import spm mat
# plot dat
# 1) plot data matrix (image x voxel)
# 2) plot spatial covariance (image x image)
# 3) spatial correlation across image
# 4) histogram image values
# 5) global mean value 
# 6) multivariate distance (outlier status)
from os.path import dirname, join as pjoin
import scipy.io as sio
def plot_covariance(dm, fig_title, **kwargs):
    """
    dm:
        pandas dataframe. Each columns is a regressors with onset time values in each row
    returns:
        plot
    """
    from sklearn.preprocessing import StandardScaler
    stdsc = StandardScaler()
    X_std = stdsc.fit_transform(dm.values)
    cov_mat = np.cov(X_std.T)
    if dm.shape[1] < 10:
        annot_bool, annot_size = True, 12
    else:
        annot_bool, annot_size = False, 0
    ax = sns.heatmap(cov_mat, annot = annot_bool, square = True, fmt='.2f', annot_kws = {'size':annot_size},linewidth=0.5, cmap = 'viridis',yticklabels = dm.columns, xticklabels = dm.columns , **kwargs)
    if dm.shape[1] > 10:
        # ax.xaxis.set_ticks(ax.get_xticklabels())
        # ax.yaxis.set_ticks(ax.get_yticklabels())
        ax.set_yticklabels(ax.get_yticklabels(), rotation = 60, fontsize = 10)
        ax.set_xticklabels(ax.get_xticklabels(), rotation = 60, fontsize = 10)
    ax.set_title(fig_title)
    return ax

mat_fname = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/resources/model01_6conditions_sub-0069_SPM.mat'
# mat_contents = sio.loadmat(mat_fname, struct_as_record=False)
# import hdf5storage
# mat = hdf5storage.loadmat(mat_fname)
# %%
import h5py
import numpy as np
# with h5py.File(mat_fname, 'r') as f:
#     f.keys()
arrays = {}
f = h5py.File(mat_fname)
for k, v in f.items():
    arrays[k] = np.array(v)
# %%
f['SPM']['xX']['X'][()]
# first_ses = f['SPM']['Sess']['U']
# name = f[first_ses]['name'] # <HDF5 dataset "name": shape (9, 1), type "|O">
# f[first_ses]['name'][0][0] # <HDF5 object reference>
# first_ses = f['SPM']['Sess']['U'][1][0]

first_ses = f['SPM']['Sess']['U'][1][0]
f[first_ses]
# %%
# 1) SPM.xX.X - Design matrix (raw, not temporally smoothed)
# plt.plot(f['SPM']['xX']['X'][()])
ax = sns.heatmap(f['SPM']['xX']['X'][()].T, cmap = 'rainbow')
plt.show()
X = pd.DataFrame(f['SPM']['xX']['X'][()])
plot_covariance(X.T, 'test')


data = [f[element['Sess']][:] for element in f['SPM']]
# 2) TODO: only plot the regressors. 
# step: SPM.Sess(s).U.name
f['SPM']['Sess']

first_ses = f['SPM']['Sess']['U'][0][0]
np.array(f[first_ses])
f[first_ses][0]
# %%
f['SPM']['xX']['Bcov'][()]
fig, ax = plt.subplots(figsize=(20,20))
ax = sns.heatmap(f['SPM']['xX']['Bcov'][()], ax=ax)
# plt.plot(f['SPM']['xX']['Bcov'][()])

# %%
np.array(f['SPM']['VResMS']['dim'][()])
# %%


# %%
