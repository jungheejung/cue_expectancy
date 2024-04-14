#!/usr/bin/env python3
import pandas as pd
from os.path import join
import os, glob


"""
In this code, we filter the single trials based on a specific VIF threshold
VIFs were extracted during model estimation code
Check code: scripts/step10_nilearn/singletrialLSS/step01_nilearnLSS_rampuppleateau.py
"""
vif_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/vif_summary'

vif_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau_nosmooth/vif_summary'

# identify sub directories
summary_df = pd.DataFrame()
threshold = 3
sub_list = glob.glob(join(vif_dir, f"vif_sub-*.tsv"))
for sub_fname in sorted(sub_list):
    # load dataframe
    print(sub_fname)
    df = pd.read_csv(sub_fname, sep='\t')
    print(df.head())
    filtered_df = df[df['vif'] > threshold]
    # append metadata with vif greater than threshold
    summary_df = pd.concat([summary_df, filtered_df], ignore_index=True)
filename = f"singletrial_vif-above-{threshold}".replace('.', '-')
summary_df.to_csv(join(vif_dir, f"{filename}.tsv"), sep='\t', index=False)


