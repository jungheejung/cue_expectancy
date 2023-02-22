# %% libraries
%matplotlib inline
import os, glob, re
import nilearn as nl
import pandas as pd
import numpy as np
from nltools.data import Design_Matrix
from nltools.utils import get_resource_path
from nltools.file_reader import onsets_to_dm
from nltools.data import Design_Matrix
import matplotlib.pyplot as plt
import seaborn as sns
from nltools.stats import regress
from nltools.external import glover_hrf
from statsmodels.stats.outliers_influence import variance_inflation_factor

# TODO: plot regressors in different colors
# TODO: return the regressors with high VIF
# flag runs that aren't usable. 
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

def plot_vif(dm, fig_title, marker_size = 50, **kwargs):
    from statsmodels.stats.outliers_influence import variance_inflation_factor
    #fig_title = "VIF: event-only regressors"
    vif_data = pd.DataFrame()
    vif_data["feature"] = dm.columns
    vif_data["VIF"] = [variance_inflation_factor(dm.values, i)
                            for i in range(len(dm.columns))]
    ax = sns.scatterplot(x = 'feature', y = 'VIF', data = vif_data, s = marker_size, **kwargs)
    sns.despine(right=True, top=True)
    # ax.set_yticklabels(vif_data["VIF"].tolist(), rotation = 60, fontsize = 8)
    ax.set_xticklabels(vif_data["feature"].tolist(), rotation = 60, fontsize = 10)
    ax.axhline(2, linestyle=":", lw = 3, color = 'gray')
    ax.axhline(4, linestyle=":", lw = 3, color = 'gray')
    ax.axhline(8, linestyle=":", lw = 3, color = 'gray')
    ax.set_title(fig_title)
    return ax

def plot_covariance(dm, fig_title, **kwargs):
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
    ax = sns.heatmap(cov_mat, annot = annot_bool, square = True, fmt='.2f', annot_kws = {'size':annot_size},linewidth=0.5, cmap = 'viridis',yticklabels = dm.columns, xticklabels = dm.columns , **kwargs)
    if dm.shape[1] > 10:
        ax.set_yticklabels(ax.get_yticklabels(), rotation = 60, fontsize = 10)
        ax.set_xticklabels(ax.get_xticklabels(), rotation = 60, fontsize = 10)
    ax.set_title(fig_title)
    return ax
# %% parameter
num_runs = 18
TR = 0.46
sampling_freq = 1./TR
all_runs = Design_Matrix(sampling_freq = sampling_freq)
run_length = 872
sub = 'sub-0061'
ses = 'ses-01'
run = 'run-01'
run_ind = int(re.findall(r'\d+', run)[0])
onset_dir= f'/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/data/beh/beh02_preproc/{sub}'
cov_dir = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/scripts/physio/spacetop_fmriprep/motion_covariates'
   
# TODO
# %% identify how many run and sessions exist in dataset
beh_list = glob.glob(os.path.join(onset_dir, '*', '*.csv'))
for beh_fname in sorted(beh_list):
    beh_basename = os.path.basename(beh_fname)
    ses_num = int(re.findall('\d+', [match for match in beh_basename.split('_') if "ses" in match][0])[0])
    run_num = int(re.findall('\d+', [match for match in beh_basename.split('_') if "run" in match][0])[0])
    task_name = re.match("(run)-(\d+)-(\w+)", [match for match in beh_basename.split('_') if "run" in match][0])[3]
    ses = 'ses-{:02d}'.format(ses_num)
    run = 'run-{:02d}'.format(run_num)
    print(f"{ses}, {run}")
    # step 1: design matrix _________________________________________________________________________________________
    f,(ax1,ax2,ax3, axcb) = plt.subplots(1,4, 
                gridspec_kw={'width_ratios':[1,1,1,0.08]}, figsize=(17, 5))
    ax1.get_shared_y_axes().join(ax2,ax3)

    # 1) Load in onsets for this run
    #onsets_fname = glob.glob(f'{sub}_{ses}_task-social_{run}*_beh.csv')[0]#os.path.join(get_resource_path(),'onsets_example.txt')
    onset = pd.read_csv(beh_fname)
    onset[['cue','expectrating', 'outcomerating', 'stim']] = onset[['event01_cue_onset','event02_expect_displayonset', 'event04_actual_displayonset', 'event03_stimulus_displayonset']] - onset[['param_trigger_onset']].values
    # duration[['cue','expectrating', 'outcomerating', 'stim']] = onset[['event01_cue_onset','event02_expect_RT', 'event04_actual_displayonset', 'event04_actual_RT']] - onset[['param_trigger_onset']].values
    H = onset[['cue','expectrating', 'outcomerating', 'stim']].stack()
    X = H.reset_index().rename({'level_0': "trial", 'level_1': "Stim", 0: "Onset"}, axis = 'columns')
    dm = onsets_to_dm(X[['Onset', 'Stim']], sampling_freq=sampling_freq,run_length = 872, sort=True)
    # dm.heatmap()
    g1 = sns.heatmap(dm, cbar = False, ax = ax1)
    g1.set_title('Design matrix onset');g1.set_ylabel('TRs (0.46s, 872 images)')

    #  2) Convolve them with the hrf
    dm_conv = dm.convolve()
    g2 = sns.heatmap(dm_conv, cbar = False, ax = ax2)
    g2.set_ylabel('');g2.set_xlabel('');g2.set_yticks([])
    g2.set_title('Design matrix, convolved with HRF')
    # 2) Load in covariates for this run
    # cov_dir = '/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/scripts/physio/spacetop_fmriprep/motion_covariates'
    cov_fname = f'{sub}_{ses}_task-social_acq-mb8_run-{run_num}_desc-confounds_timeseries.tsv'
    covariatesFile = os.path.join(cov_dir, cov_fname)
    cov = pd.read_csv(covariatesFile, sep = '\t')
    cov = Design_Matrix(cov, sampling_freq = sampling_freq)

    # 3) In the covariates, fill any NaNs with 0, add intercept and linear trends and dct basis functions
    cov = cov.fillna(0)
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
    # full.heatmap()
    g3 = sns.heatmap(full, cbar_ax=axcb, ax = ax3)
    g3.set_ylabel('')
    g3.set_xlabel('')
    g3.set_yticks([])
    g3.set_title('Full design matrix with nuissance covariates')
    plt.suptitle(f"{sub} {ses} {run}", fontsize = 20)
    plt.show()
    # step 2: covariance and VIF _________________________________________________________________________________________
    # plot 1-1) covariance of the full design matrix
    # plot 1-2) covariance of the event only design matrix
    # plot 2-1) VIF of the full design matrix
    # plot 2-2) VIF of the full design matrix
    f,axes= plt.subplots(ncols = 2,nrows = 2, figsize=(20,20), sharey = False)
    plot_covariance(full, fig_title = 'Covariance: full design matrix', ax = axes[0,0], cbar = False)
    plot_covariance(dm, fig_title = 'Covariance: event only', ax = axes[0,1], cbar = False)
    fullvif = plot_vif(full, fig_title = "VIF: full design matrix", marker_size = 50, ax = axes[1,0])
    fullvif.set_xticklabels(fullvif.get_xticklabels(), rotation = 60, fontsize = 8)
    plot_vif(dm_conv, fig_title = "VIF: event-only regressors", marker_size = 50, ax = axes[1,1])
    f.suptitle(f'{sub} {ses} {run}', position=(.5,.95), fontsize=30)
    f.show()
    #plt.show()

#  5) Append it to the master Design Matrix keeping things separated by run
    all_runs = all_runs.append(full,axis=0)#unique_cols=cov.columns)
# %%
all_runs

plot_covariance(all_runs, fig_title = f"Covariance: all {len(beh_list)} runs")
plot_vif(all_runs, fig_title = f"VIF: all {len(beh_list)} runs")