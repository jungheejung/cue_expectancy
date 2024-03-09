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
import os, glob, re
from os.path import join
def remove_integers_from_string(s):
    if isinstance(s, str):
        return re.sub(r'\d+', '', s)  # This regex replaces one or more digits with nothing
    return s
def convert_float_to_int(value):
    if isinstance(value, float) and value.is_integer():
        return int(value)
    return value
# Apply the function to each cell in the DataFrame

# Load the DataFrame
singletrial_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau'
df = pd.read_csv(join(singletrial_dir, 'vif_summary/singletrial_vif-above-3.tsv'), sep='\t')

# Extract subject and runtype
df['subject'] = df['singletrial_fname'].apply(lambda x: x.split('_')[1])
df['runtype'] = df['singletrial_fname'].apply(lambda x: x.split('_runtype-')[1].split('_event-')[0])
df['event'] = df['singletrial_fname'].apply(lambda x: x.split('_event-')[1].split('_trial-')[0])

# Initialize a DataFrame to hold the task summary
task_summary = pd.DataFrame()

# Define the tasks of interest
tasks = ['pain', 'cognitive', 'vicarious']
events = ['cue', 'stimulus']
# Iterate over each unique subject
for sub in df['subject'].unique():
    # Initialize a dictionary to hold the summary for this subject
    subject_summary = {'Subject': sub}
    
    for task in tasks:
        for event in events:
            # Path pattern for all files of this subject, task, and event type
            file_path_pattern = join(singletrial_dir, sub, f'*_runtype-{task}_event-{event}_*.nii.gz')
            total_files = len(glob.glob(file_path_pattern))
            
            # Count files to be removed for this task and event type
            removed_files = df[(df['subject'] == sub) & (df['runtype'] == task) & (df['event'] == event)].shape[0]
            
            # Calculate remaining files
            remaining_files = total_files - removed_files
            
            # Update the subject summary dictionary
            task_event_label = f"{task.capitalize()} {event.capitalize()}"
            subject_summary[f'Total {task_event_label} Files'] = total_files
            subject_summary[f'Removed {task_event_label} Files'] = removed_files
            subject_summary[f'Remaining {task_event_label} Files'] = remaining_files
    
    # Append this subject's summary to the detailed summary DataFrame
    task_summary = task_summary.append(subject_summary, ignore_index=True)

# Ensure 'Subject' column is of type string if needed
task_summary['Subject'] = task_summary['Subject'].astype(str)
# task_summary['EventType'] = task_summary['event'].astype(str)
# Sort by subject
task_summary = task_summary[['Subject', 
            'Total Pain Stimulus Files', 'Removed Pain Stimulus Files', 'Remaining Pain Stimulus Files',
            'Total Vicarious Stimulus Files', 'Removed Vicarious Stimulus Files', 'Remaining Vicarious Stimulus Files',
            'Total Cognitive Stimulus Files', 'Removed Cognitive Stimulus Files', 'Remaining Cognitive Stimulus Files',

            'Total Pain Cue Files', 'Removed Pain Cue Files', 'Remaining Pain Cue Files',
            'Total Vicarious Cue Files', 'Removed Vicarious Cue Files', 'Remaining Vicarious Cue Files',
            'Total Cognitive Cue Files', 'Removed Cognitive Cue Files', 'Remaining Cognitive Cue Files',
                                ]]

for col in task_summary.columns:
    if col != 'Subject':
        task_summary[col] = task_summary[col].apply(convert_float_to_int)

task_summary.sort_values(by=['Subject'], inplace=True)

task_summary.reset_index(drop=True, inplace=True)

# Save the summary to a CSV file
task_summary.to_csv(join(singletrial_dir, 'vif_summary', 'task_file_summary.csv'), index=False)
task_summary.to_csv(join(singletrial_dir, 'vif_summary', 
                           f"singletrial_vif_tally-3.tsv"), sep='\t', index=False)