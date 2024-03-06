#!/usr/bin/env python3
"""
identify how many files would be removed based on the vif threshold
"""
__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 


import pandas as pd
import glob
import os
from os.path import join

singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau'
df = pd.read_csv(join(singletrial_dir, 'vif_summary/singletrial_vif-above-2-5.tsv'), 
                 sep='\t')
df['subject'] = df['singletrial_fname'].apply(lambda x: x.split('_')[1])

# 1, Count Total Files by Event Type ____________________________________________
filter_summary = pd.DataFrame()
for sub in df['subject'].unique():
    file_path_pattern = f'{singletrial_dir}/{sub}/*.nii.gz'
    files_in_dir = glob.glob(file_path_pattern)
    # Count the total files for each event type
    total_files_count = {}
    for file in files_in_dir:
        event_type = file.split('_event-')[1].split('_')[0]
        total_files_count[event_type] = total_files_count.get(event_type, 0) + 1

    # Count files to be removed for the current subject by event type __________
    files_to_remove_count = df[df['subject'] == sub].groupby('event').size()

    # Create a summary DataFrame for the current subject ________________________
    summary_df = pd.DataFrame({
        'Event Type': list(total_files_count.keys()),
        'Total Files': list(total_files_count.values())
    }).set_index('Event Type')
    summary_df['Files to Remove'] = summary_df.index.map(files_to_remove_count).fillna(0).astype(int)
    summary_df['Remaining Files'] = summary_df['Total Files'] - summary_df['Files to Remove']
    summary_df['Subject'] = sub  # Add the subject column
    summary_df.reset_index(inplace=True)
    filter_summary = pd.concat([filter_summary, summary_df], ignore_index=True)

# Adjust columns order and sort by 'Event Type' and then by 'Subject' __________
filter_summary = filter_summary[['Event Type', 'Subject', 'Total Files', 
                                 'Files to Remove', 'Remaining Files']]
filter_summary.sort_values(by=['Event Type', 'Subject'], inplace=True)
filter_summary.reset_index(drop=True, inplace=True)
filter_summary.to_csv(join(singletrial_dir, 'vif_summary', 
                           f"singletrial_vif_tally.tsv"), sep='\t', index=False)
