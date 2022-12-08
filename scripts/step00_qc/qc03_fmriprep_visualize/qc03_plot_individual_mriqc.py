
# %% libraries _____________________________________________________________________
import os, glob
import itertools
import json
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
# %% load mriqc json files _____________________________________________________________________
# json_fname = '/Volumes/spacetop/derivatives/dartmouth/mriqc/sub-0002/ses-03/func/sub-0002_ses-03_task-social_acq-mb8_run-02_bold.json'
# with open(json_fname) as f:
#     data = json.load(f)
# print(data)
# group_session = pd.DataFrame()
# group_session = data[stat_key]


# %% plot summary statistci per session   _____________________________________________________________________

# %% read pandas _____________________________________________________________________
group_bold = pd.read_csv('/Volumes/spacetop/derivatives/dartmouth/mriqc/group_bold.tsv', sep = '\t')
foo = lambda x: pd.Series([i for i in reversed(group_bold['bids_name'].split('_'))])
group_bold[['sub', 'ses', 'task', 'acq', 'run', 'bold']] = group_bold["bids_name"].str.split(pat="_", expand=True)
group_bold.to_csv('/Users/h/Documents/group_bold.csv', index = False)
stat_keys = [ 'spikes_num','summary_bg_k','summary_bg_mad','summary_bg_mean','summary_bg_median','summary_bg_n','summary_bg_p05','summary_bg_p95','summary_bg_stdv','summary_fg_k','summary_fg_mad','summary_fg_mean','summary_fg_median','summary_fg_n','summary_fg_p05','summary_fg_p95','summary_fg_stdv','tsnr']

# TODO: identify min and max. Scale based on the two values
for stat_key in stat_keys:
    # select subset
    num_sub = len(group_bold['sub'].unique())
    sns.set_theme(style="whitegrid")
    fig, axs = plt.subplots(num_sub, 3)
    fig.set_figheight(60)
    fig.set_figwidth(10)
    fig.suptitle(f'{num_sub} subject x 3 runs axes with no data')
    fig.subplots_adjust(hspace = .5, wspace=.001)

    axs = axs.ravel()
    sub_list = list(group_bold['sub'].unique())
    ses_list = ['ses-01', 'ses-03', 'ses-04']
    full_list = list(itertools.product(sub_list, ses_list))

    # plot
    # for ind, (sub, ses) in enumerate(full_list):
    # # for sub in sub_list:
    #     # for
    #     rslt_df = pd.DataFrame()
    #     rslt_df = group_bold.loc[(group_bold['task'] == 'task-social') & (group_bold['sub'] == sub) & (group_bold['ses'] == ses)]
    #     if not rslt_df.empty:
    #         g = sns.lineplot(
    #             data=rslt_df,
    #             x="run", y="summary_fg_k",
    #             markers=True, dashes=False,
    #             ax = axs[ind])
    #         g.set(ylim=(0, 7))
    #     else:
    #         continue

    rslt_df = group_bold.loc[(group_bold['task'] == 'task-social') & group_bold['ses'].isin(['ses-01', 'ses-03', 'ses-04'])]

    # TODO: identify min max

    g = sns.FacetGrid(
        data=rslt_df,
        col="ses", row="sub", sharey="row", height=1.5)
    g = (g.map(sns.lineplot, "run", stat_key, marker=".")
        .set_titles("{row_name}_{col_name}"))
    max_val = rslt_df[stat_key].max()
    min_val = rslt_df[stat_key].min()
    g.set(ylim = (min_val, max_val), yticks=[min_val + 10, round((max_val - min_val)/2), max_val - 10])
    # , **kws)
            # .set(ylim=(0, 10),
            #  yticks=[2, 6, 10]))
    # g.set(ylim=(0, 7))

    g.savefig(f'/Users/h/Desktop/plot_{stat_key}.png')
    plt.close(fig)
# %%
