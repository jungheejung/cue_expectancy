import pandas as pd
from os.path import join
import os, glob


"""
In this code, we filter the single trials based on a specific VIF threshold
"""
vif_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/vif_summary'

# identify sub directories
sub_folders = next(os.walk(vif_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
summary_df = pd.DataFrame()
threshold = 2.5

for sub in sub_list:
    # load dataframe
    df = pd.read_csv(join(vif_dir, f"vif_{sub}.tsv"), sep='\t')
    filtered_df = df[df['vif'] > threshold]
    # append metadata with vif greater than threshold
    summary_df = pd.concat([summary_df, filtered_df], ignore_index=True)
filename = f"singletrial_vif-above-{threshold}.tsv".replace('.', '-')
summary_df.to_csv(join(vif_dir, filename), sep='\t', index=False)


