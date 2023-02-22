# %% libraries
import os
import nilearn as nl
import pandas as pd
from nltools.data import Design_Matrix
import numpy as np
from nltools.utils import get_resource_path
from nltools.file_reader import onsets_to_dm
from nltools.data import Design_Matrix
import glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from nltools.stats import regress
from nltools.external import glover_hrf
from statsmodels.stats.outliers_influence import variance_inflation_factor

# TODO: plot regressors in different colors
# %% functions
def plot_timeseries(data, labels=None, linewidth=3):
    '''Plot a timeseries
    
    Args:
        data: (np.ndarray) signal varying over time, where each column is a different signal.
        labels: (list) labels which need to correspond to the number of columns.
        linewidth: (int) thickness of line
    '''
    plt.figure(figsize=(20,5))
    plt.plot(data, linewidth=linewidth)
    plt.ylabel('Intensity', fontsize=18)
    plt.xlabel('Time', fontsize=18)
    plt.tight_layout()
    if labels is not None:
        if len(labels) != data.shape[1]:
            raise ValueError('Need to have the same number of labels as columns in data.')
        plt.legend(labels, fontsize=18)

def plot_vif(dm, fig_title, marker_size = 50):
    from statsmodels.stats.outliers_influence import variance_inflation_factor
    #fig_title = "VIF: event-only regressors"
    vif_data = pd.DataFrame()
    vif_data["feature"] = dm.columns
    vif_data["VIF"] = [variance_inflation_factor(dm.values, i)
                            for i in range(len(dm.columns))]
    vifplot = sns.scatterplot(x = 'feature', y = 'VIF', data = vif_data, s = marker_size)
    sns.despine(right=True, top=True)
    vifplot.axhline(2, linestyle=":", lw = 1)
    vifplot.axhline(4, linestyle=":", lw = 1)
    vifplot.axhline(8, linestyle=":", lw = 1)
    vifplot.set_title(fig_title)
    return vifplot

def plot_covariance(dm):
    """
    dm:
        dataframe with columns as regressors; values in each row
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
    ax = sns.heatmap(cov_mat, cbar = True, annot = annot_bool, square = True, fmt='.2f', annot_kws = {'size':annot_size},linewidth=0.5, cmap = 'viridis',yticklabels = dm.columns, xticklabels = dm.columns )
    if dm.shape[1] > 10:
        ax.set_yticklabels(ax.get_yticklabels(), rotation = 60, fontsize = 8)
        ax.set_xticklabels(ax.get_xticklabels(), rotation = 60, fontsize = 8)
    return ax
# %% parameter
num_runs = 18
TR = 0.46
sampling_freq = 1./TR
all_runs = 1
run_length = 872


# %% 1) Load in onsets for this run
onsets_fname = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/data/beh/beh02_preproc/sub-0061/ses-01/sub-0061_ses-01_task-social_run-01-pain_beh.csv'#os.path.join(get_resource_path(),'onsets_example.txt')
onset = pd.read_csv(onsets_fname)
onset[['cue','expectrating', 'outcomerating', 'stim']] = onset[['event01_cue_onset','event02_expect_displayonset', 'event04_actual_displayonset', 'event03_stimulus_displayonset']] - onset[['param_trigger_onset']].values
# duration[['cue','expectrating', 'outcomerating', 'stim']] = onset[['event01_cue_onset','event02_expect_RT', 'event04_actual_displayonset', 'event04_actual_RT']] - onset[['param_trigger_onset']].values
H = onset[['cue','expectrating', 'outcomerating', 'stim']].stack()
X = H.reset_index().rename({'level_0': "trial", 'level_1': "Stim", 0: "Onset"}, axis = 'columns')

dm = onsets_to_dm(X[['Onset', 'Stim']], sampling_freq=sampling_freq,run_length = 872, sort=True)
dm.heatmap(yticklabels = True)
# onset_cue = onset['event01_cue_onset'] - onset['param_trigger_onset']
# onset_expectrating = onset['event02_expect_displayonset'] - onset['param_trigger_onset']
# onset_outcomerating = onset['event04_actual_displayonset'] - onset['param_trigger_onset']
# onset_stim = onset['event03_stimulus_displayonset'] - onset['param_trigger_onset']
# onset_mat = np.hstack([onset_cue,onset_expectrating,onset_outcomerating, onset_stim ]).T
# cond_mat = np.hstack([
#     np.repeat('cue', onset_cue.size, axis = 0),
#     np.repeat('expectrating', onset_expectrating.size, axis = 0),
#     np.repeat('outcomerating', onset_outcomerating.size, axis = 0),
#     np.repeat('stim', onset_stim.size, axis = 0),
#            ])
# X = pd.DataFrame.from_dict({'Onset': onset_mat, 'Stim': cond_mat})

# %%
# a) covariance
# from sklearn.preprocessing import StandardScaler
# stdsc = StandardScaler()
# X_std = stdsc.fit_transform(dm.values)
# cov_mat = np.cov(X_std.T)
# ax = sns.heatmap(cov_mat, cbar = True, annot = True, square = True, fmt='.2f', 
#                  annot_kws = {'size':12},linewidth=0.5, cmap = 'viridis', xticklabels = dm.columns, yticklabels = dm.columns)
# plt.show()

# %% 2) Convolve them with the hrf
dm_conv = dm.convolve()
dm_conv.heatmap()
plt.title('HRF-convolved regressors')
plt.ylabel('TRs (0.46s, 872 images)')
# %% 2) Load in covariates for this run
cov_dir = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/scripts/physio/spacetop_fmriprep/motion_covariates'
cov_fname = 'sub-0061_ses-01_task-social_acq-mb8_run-1_desc-confounds_timeseries.tsv'
covariatesFile = os.path.join(cov_dir, cov_fname)
cov = pd.read_csv(covariatesFile, sep = '\t')
cov = Design_Matrix(cov, sampling_freq = sampling_freq)

# %%3) In the covariates, fill any NaNs with 0, add intercept and linear trends and dct basis functions
cov = cov.fillna(0)

# Retain a list of nuisance covariates (e.g. motion and spikes) which we'll also want to also keep separate for each run

nuissance_col = [ 'trans_x', 'trans_x_derivative1', 'trans_x_power2', 'trans_x_derivative1_power2', 
'trans_y', 'trans_y_derivative1', 'trans_y_derivative1_power2', 'trans_y_power2', 
'trans_z', 'trans_z_derivative1', 'trans_z_derivative1_power2', 'trans_z_power2', 
'rot_x', 'rot_x_derivative1', 'rot_x_derivative1_power2', 'rot_x_power2', 
'rot_y', 'rot_y_derivative1', 'rot_y_derivative1_power2', 'rot_y_power2', 
'rot_z', 'rot_z_derivative1', 'rot_z_derivative1_power2', 'rot_z_power2']
motion_col = [col for col in cov if col.startswith('motion')]
nuissance_list = list(nuissance_col) + list(motion_col)
cov_mat = cov[nuissance_list].add_poly(1).add_dct_basis()

# 4) Join the onsets and covariates together
full = []
full = dm_conv.append(cov_mat,axis=1)
full.heatmap()

# %%
# A) covariance
cov_full = plot_covariance(full)
plt.show()

# B) covariance of only regressors
cov_dm = plot_covariance(dm)
plt.show()

# C) VIF full regressors
vif_full = plot_vif(full, fig_title = "VIF: full regressors", marker_size = 50)
plt.show()

# C) VIF regressors of interest
vif_eventonly = plot_vif(dm_conv, fig_title = "VIF: event-only regressors", marker_size = 50)
plt.show()
# %% 5) Append it to the master Design Matrix keeping things separated by run
all_runs = all_runs.append(full,axis=0,unique_cols=cov.columns)
# %%
