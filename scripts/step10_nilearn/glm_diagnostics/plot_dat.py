# %%
import mat73
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
import h5py
from os.path import dirname, join as pjoin
import scipy.io as sio
# https://stackoverflow.com/questions/17316880/reading-v-7-3-mat-file-in-python
# data_dict = mat73.loadmat('/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/resources/model01_6conditions_sub-0069_SPM.mat')
# import spm mat
# plot dat
# 1) plot data matrix (image x voxel)
# 2) plot spatial covariance (image x image)
# 3) spatial correlation across image
# 4) histogram image values
# 5) global mean value 
# 6) multivariate distance (outlier status)
# TODO: apply canlab mask.nii and then plot the brain data
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
arrays = {}
f = h5py.File(mat_fname)
for k, v in f.items():
    arrays[k] = np.array(v)

# %% SPM.Sess(1).U(1).  condition string name (success)
run_ind = 8
cond_ind = 0
first_ses = f['SPM']['Sess']['U'][run_ind][0]
print(f"f['SPM']['Sess']['U'][{run_ind}][0]: {np.array(f[first_ses])}")
name = f[first_ses]['name'][cond_ind][0]
print(f"f[f[name][0][0]][()]: {f[f[name][0][0]][()]}")
char_list = np.array(f[f[name][0][0]][()])
strlist = [u''.join(chr(int(c)) for c in char_list)]
print(f"after conversion: {strlist}")

# %%
# SPM.xX.name
spm_xX_name = []
regressor_len = f['SPM']['xX']['name'].shape[0]
for reg in list(np.arange(regressor_len)):
    regressors_name = f['SPM']['xX']['name'][reg][0]

    np.array(f[regressors_name])
    char_list = np.array(f[regressors_name])
    strlist = [u''.join(chr(int(c)) for c in char_list)]
    spm_xX_name.append(strlist)
reg_df = pd.DataFrame(spm_xX_name)
stim_index = reg_df[reg_df[0].str.contains("cue-")].index.tolist()
cue_index = reg_df[reg_df[0].str.contains("CUE")].index.tolist()
rating_index = reg_df[reg_df[0].str.contains("_RATING")].index.tolist()
reg_index = stim_index + cue_index + rating_index
# %% covariance
f['SPM']['xX']['Bcov'][()]
fig, ax = plt.subplots(figsize=(20,20))
ax = sns.heatmap(f['SPM']['xX']['Bcov'][()], cmap = 'viridis', ax=ax)

# %% SPM.xX.X - Design matrix (raw, not temporally smoothed) ___________________________________________________________
# ax = sns.heatmap(f['SPM']['xX']['X'][()].T, cmap = 'rainbow')
plt.show()
X = pd.DataFrame(f['SPM']['xX']['X'][()])
# plot_covariance(X.T, 'test')
fig, ax1 = plt.subplots(figsize=(30,30))
fig1 = sns.heatmap(f['SPM']['xX']['X'][()][sorted(reg_index)].T,cmap = 'rainbow', ax = ax1)
fig1.set_title('Design Matrix, events only', fontsize = 30)
plt.show()
fig, ax2 = plt.subplots(figsize=(30,30))
plot_covariance(pd.DataFrame(f['SPM']['xX']['X'][()][sorted(reg_index)].T), 'covariance matrix', ax = ax2)

plt.show()
print(f"total number of event regressors: {len(reg_index)}")

# %% SPM.xX.Bcov - variance-covariance matrix of parameter estimates
f['SPM']['xX']['Bcov'][()]
fig, ax = plt.subplots(figsize=(20,20))
fig3 = sns.heatmap(f['SPM']['xX']['Bcov'][()], cmap = 'viridis', ax=ax)
fig3.set_title('variance covariance matrix full regressors', fontsize = 30)

# %%
np.array(f['SPM']['VResMS']['dim'][()])
f['SPM']['xVol']['DIM'][()]
# %%


# %%
dict(f['SPM']['Sess'].attrs.items())
# {'H5PATH': b'/SPM',
#  'MATLAB_class': b'struct',
#  'MATLAB_fields': array([array([b'U'], dtype='|S1'), array([b'C'], dtype='|S1'),
#         array([b'r', b'o', b'w'], dtype='|S1'),
#         array([b'c', b'o', b'l'], dtype='|S1'),
#         array([b'F', b'c'], dtype='|S1')], dtype=object)}

# %% SPM.xVol.M
f['SPM']['xVol']['M'][()]

# %% 
# xX.pKX pseudoinverse of K*W*X, computed by spm_sp
f['SPM']['xX']['pKX'][()]
fig, ax = plt.subplots(figsize=(20,20))
fig3 = sns.heatmap(f['SPM']['xX']['xKXs']['X'][()], cmap = 'viridis', ax=ax)
fig3.set_title('pKX', fontsize = 30)

# %%
