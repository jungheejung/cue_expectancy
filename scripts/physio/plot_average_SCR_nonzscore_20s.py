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
from datetime import datetime
from pathlib import Path

"""
20 seconds
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
main_dir = '/Volumes/spacetop_projects_social'
# main_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis'
main_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue'
local_physiodir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis/analysis/physio'
physio_dir = join(main_dir, 'analysis/physio/')
local_physiodir = physio_dir
# task = 'cognitive'
epochstart = -3
epochend = 20
samplingrate = 25
ttlindex = 2
date = datetime.now().strftime("%m-%d-%Y")
fig_savedir = join(main_dir, 'figure/physio/physio01_SCL', date)
Path(fig_savedir).mkdir( parents=True, exist_ok=True )
# %%
for task in [ 'pain', 'cognitive', 'vicarious']:
    # NOTE: <<--------only run once
    flist = glob.glob(
        join(physio_dir, '**', f'sub-0*{task}*_epochend-{epochend}_samplingrate-{samplingrate}_ttlindex-{ttlindex}_physio-scltimecourse.csv'), recursive=True)
    # sub-0053_ses-01_run-02_runtype-vicarious_epochstart--1_epochend-20_samplingrate-25_ttlindex-2_physio-scltimecourse
    # sub-0062_ses-01_run-06_runtype-vicarious_epochstart--1_epochend-20_samplingrate-25_ttlindex-2_physio-scltimecourse
    #  NOTE: stack all data and save as .csv ________________________
    li = []
    frame = pd.DataFrame()
    for filename in sorted(flist):
        df = pd.read_csv(filename, index_col=None, header=0)
        li.append(df)
    frame = pd.concat(li, axis=0, ignore_index=True)
    frame.to_csv(join(local_physiodir, 'physio01_SCL', f'sub-all_ses-all_run-all_runtype-{task}_epochstart-{epochstart}_epochend-{epochend}_samplingrate-{samplingrate}_ttlindex-{ttlindex}_physio-scltimecourse.csv'), index = False)
    # NOTE: only run once -------- >>


    frame = pd.DataFrame()
    # NOTE: downsample via neurokit ________________________
    frame = pd.read_csv(join(local_physiodir, 'physio01_SCL',
                        f'sub-all_ses-all_run-all_runtype-{task}_epochstart-{epochstart}_epochend-{epochend}_samplingrate-{samplingrate}_ttlindex-{ttlindex}_physio-scltimecourse.csv'))

    # NOTE: drop columns
    subset_df = frame.drop(columns=['session_id', 'param_task_name', 'param_run_num',
                            'param_cond_type', 'trial_order', 'trial_order', 'iv_stim', 'mean_signal', ])

    # NOTE: plot grand average ________________________

    # # TODO: scale per participant!
    # mdf = subset_df.loc[:, 0:499].add_prefix('col_')
    # merge_df2 = pd.concat([metadata_df, mdf], axis=1)
    # subset_df = merge_df2.drop(columns=['session_id', 'param_task_name', 'param_run_num',
    #                            'param_cond_type', 'trial_num', 'trial_order', 'iv_stim', 'mean_signal'])
    # average signal per condition
    M = subset_df.groupby(by=['src_subject_id', 'param_cue_type',
                        'param_stimulus_type']).apply(lambda x: x.mean())
    M.drop(columns=['src_subject_id'], inplace=True)
    Mr = M.reset_index()
    Mr.to_csv(join(local_physiodir, 'physio01_SCL',
    f'sub-all_condition-mean_runtype-{task}_epochstart-{epochstart}_epochend-{epochend}_samplingrate-{samplingrate}_ttlindex-{ttlindex}_physio-scltimecourse.csv'), index = False)
    # group by first
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

    # NOTE: plot stimulus intensity factor
    plot_condition_timeseries(
        df = Mr,
        cond='param_stimulus_type',
        level_list=['high_stim', 'med_stim', 'low_stim'],
        col_start='time_0',
        col_end='time_399',
        color_list=['#E23201', '#FD9415', '#848484'], 
        line_style = ['solid'])
    plt.title(f'{task} stimulus SCR')
    plt.savefig(join(fig_savedir, f"task-{task}_sample-25_ttlindex-{ttlindex}_iv-time_dv-stim.png"))
    plt.close()
    
    # NOTE: plot cue factor
    plot_condition_timeseries(
        df = Mr,
        cond='param_cue_type',
        level_list=['high_cue', 'low_cue'],
        col_start='time_0',
        col_end='time_399',
        color_list=['#FAAE7B', '#432371'],
        line_style = ['dashed'])
    plt.title(f'{task} cue SCR')
    plt.savefig(join(fig_savedir, f"task-{task}_sample-25_ttlindex-{ttlindex}_iv-time_dv-cue.png"))
    plt.close()

    # NOTE: plot interaction
    plot_condition_timeseries(
        df =Mr[Mr['param_stimulus_type'] == 'high_stim'],
        cond='param_cue_type',
        level_list=['high_cue', 'low_cue'],
        col_start='time_0',
        col_end='time_399',
        color_list=['#E23201', '#E23201'],
        line_style = ['solid', 'dashed'])

    plot_condition_timeseries(
        df =Mr[Mr['param_stimulus_type'] == 'med_stim'],
        cond='param_cue_type',
        level_list=['high_cue', 'low_cue'],
        col_start='time_0',
        col_end='time_399',
        color_list=['#FD9415', '#FD9415'],
        line_style = ['solid', 'dashed'])

    plot_condition_timeseries(
        df =Mr[Mr['param_stimulus_type'] == 'low_stim'],
        cond='param_cue_type',
        level_list=['high_cue', 'low_cue'],
        col_start='time_0',
        col_end='time_399',
        color_list=['#848484','#848484'],#['#00B9EC', '#00B9EC'],
        line_style = ['solid', 'dashed'])
    plt.title(f'{task} stimulus * cue SCR')
    plt.legend(bbox_to_anchor=(1.05, 1.0), loc='upper left')
    # plt.show()
    plt.savefig(join(fig_savedir, f"task-{task}_sample-25_ttlindex-{ttlindex}_iv-time_dv-stimXcue.png"))
    plt.close()
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
level_list = ['low_stim', 'med_stim', 'high_stim']
for ind, stim in enumerate(level_list):
    stim = 'low_stim'
    stim_df = frame[frame['param_stimulus_type'] == stim]
    stim_mean = stim_df.loc[:, 'event04_actual_angle'].mean()
    stim_sd = stim_df.loc[:, 'event04_actual_angle'].std()
    timeseries = np.arange(len(stim_mean))
    line_style = 'solid'
    color_list=['#E23201', '#FD9415', '#848484'], 
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
# %%
