# %%
import sys
import glob
import os
import seaborn as sns
import matplotlib.pyplot as plt
from os.path import join
import neurokit2 as nk
import numpy as np
import pandas as pd

"""
# get a list that matches this pattern
# {sub}_{ses}_*_runtype-pain_epochstart--1_epochend-8_physio-scltimecourse.csv

# step 1. concatenate into dataframe while handeling info
# - sub
# - ses
# - run number
# - trial number
# ,src_subject_id,session_id,param_task_name,param_run_num,param_cue_type,param_stimulus_type,param_cond_type,trial_num,trial_order,iv_stim,mean_signal,

# step 2. downsample to 25 hz
# step 3. z score within paritcipant
# step 4. average per condition 
"""

# %% glob data ________________________
physio_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/analysis/physio'
flist = glob.glob(
    join(physio_dir, '**', '*pain*physio-scltimecourse.csv'), recursive=True)
# %% stack all data and save as .csv ________________________
li = []

for filename in flist:
    df = pd.read_csv(filename, index_col=None, header=0)
    li.append(df)
frame = pd.concat(li, axis=0, ignore_index=True)
frame.to_csv(join(physio_dir, 'physio01_SCL',
             'sub-all_ses-all_run-all_runtype-pain_epochstart--1_epochend-8_physio-scltimecourse.csv'), index = False)
# sub-0016_ses-03_run-01_runtype-cognitive_epochstart--1_epochend-8_physio-scltimecourse
# %%downsample via neurokit ________________________
frame = pd.read_csv(join(physio_dir, 'physio01_SCL',
                    'sub-all_ses-all_run-all_runtype-pain_epochstart--1_epochend-8_physio-scltimecourse.csv'))
filter_col = [col for col in frame if col.startswith('time_')]
timeframe = frame[filter_col]
downsampled_interpolation = pd.DataFrame(index=list(range(frame.shape[0])),
                                         columns=list(range(225)))
new_rows = []

for index, row in timeframe.iterrows():
    ds = []
    downsampled_interpolation.loc[index, :] = nk.signal_resample(
        row, method="interpolation", sampling_rate=2000, desired_sampling_rate=25)
    # new_rows.append(ds)
# %% append metadata and behavioral ratings ________________________
metadata_col = [col for col in frame if not col.startswith(
    ('time_', 'Unnamed:'))]
metadata_df = frame[metadata_col]
merge_df = pd.concat(
    [metadata_df, downsampled_interpolation.reindex()], axis=1)

# %%
subset_df = merge_df.drop(columns=['session_id', 'param_task_name', 'param_run_num',
                          'param_cond_type', 'trial_num', 'trial_order', 'iv_stim', 'mean_signal'])

# %% plot grand average ________________________

# TODO: scale per participant!
mdf = subset_df.loc[:, 0:224].add_prefix('col_')
merge_df2 = pd.concat([metadata_df, mdf], axis=1)
subset_df = merge_df2.drop(columns=['session_id', 'param_task_name', 'param_run_num',
                           'param_cond_type', 'trial_num', 'trial_order', 'iv_stim', 'mean_signal'])
# %% average signal per condition
M = subset_df.groupby(by=['src_subject_id', 'param_cue_type',
                      'param_stimulus_type']).apply(lambda x: x.mean())
M.drop(columns=['src_subject_id'], inplace=True)
Mr = M.reset_index()
# %% group by first
def plot_condition_timeseries(df, cond, level_list, col_start, col_end, color_list, line_style):
    for ind, stim in enumerate(level_list):
        stim_df = df[df[cond] == stim]
        stim_mean = stim_df.loc[:, col_start:col_end].mean()
        stim_sd = stim_df.loc[:, col_start:col_end].std()
        timeseries = np.arange(len(stim_mean))
        N = len(list(subset_df.src_subject_id.unique()))
        if len(line_style) > 1:
            linesty = line_style[ind]
        else: 
            linesty = line_style[0]
        plt.plot(timeseries, stim_mean,
                 color = f'{color_list[ind]}',
                 linestyle=linesty, 
                 label=f"mean_{stim}")
        plt.fill_between(timeseries, stim_mean - stim_sd/np.sqrt(N), stim_mean +
                         stim_sd/np.sqrt(N), color=f'{color_list[ind]}', alpha=0.1)
    plt.plot()
    # plt.show()


plot_condition_timeseries(
    df = Mr,
    cond='param_stimulus_type',
    level_list=['high_stim', 'med_stim', 'low_stim'],
    col_start='col_0',
    col_end='col_224',
    color_list=['#E23201', '#FD9415', '#6BBCD1'], 
    line_style = ['solid'])
plt.title('stimulus SCR')
plt.show()

plot_condition_timeseries(
    df = Mr,
    cond='param_cue_type',
    level_list=['high_cue', 'low_cue'],
    col_start='col_0',
    col_end='col_224',
    color_list=['#FAAE7B', '#432371'],
    line_style = ['dashed'])
plt.title('cue SCR')
plt.show()

# %% int
plot_condition_timeseries(
    df =Mr[Mr['param_stimulus_type'] == 'high_stim'],
    cond='param_cue_type',
    level_list=['high_cue', 'low_cue'],
    col_start='col_0',
    col_end='col_224',
    color_list=['#E10000', '#E10000'],
    line_style = ['solid', 'dashed'])

plot_condition_timeseries(
    df =Mr[Mr['param_stimulus_type'] == 'med_stim'],
    cond='param_cue_type',
    level_list=['high_cue', 'low_cue'],
    col_start='col_0',
    col_end='col_224',
    color_list=['#FFAE00', '#FFAE00'],
    line_style = ['solid', 'dashed'])

plot_condition_timeseries(
    df =Mr[Mr['param_stimulus_type'] == 'low_stim'],
    cond='param_cue_type',
    level_list=['high_cue', 'low_cue'],
    col_start='col_0',
    col_end='col_224',
    color_list=['#848484','#848484'],#['#00B9EC', '#00B9EC'],
    line_style = ['solid', 'dashed'])
plt.title('stimulus * cue SCR')
plt.legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
plt.show()

# TODO:
# combine behavioral data
# col = ['r', 'y', 'b']
# for ind, stim in enumerate(['high_stim', 'med_stim', 'low_stim']):
#     stim_df = Mr[Mr['param_stimulus_type'] == stim]
#     stim_mean = stim_df.loc[:,'col_0':'col_224'].mean()
#     stim_sd = stim_df.loc[:,'col_0':'col_224'].std()
#     timeseries = np.arange(len(stim_mean))
#     N = len(list(subset_df.src_subject_id.unique()))
#     plt.plot(timeseries, stim_mean, f'{col[ind]}-', label='mean_1')
#     plt.fill_between(timeseries, stim_mean - stim_sd/np.sqrt(N), stim_mean + stim_sd/np.sqrt(N), color=f'{col[ind]}', alpha=0.2)
# plt.plot()

# %%
