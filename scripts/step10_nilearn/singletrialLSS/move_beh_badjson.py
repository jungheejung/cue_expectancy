import os
import shutil
import json, fnmatch

# Load the JSON data
json_filename = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/scripts/bad_beh.json'
with open(json_filename, 'r') as file:
    data = json.load(file)

# Base directory where the subject folders are located
base_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh'
# Directory where the events.tsv files should be moved
dump_dir = os.path.join(base_dir, 'DUMP')


if not os.path.exists(dump_dir):
    os.makedirs(dump_dir)

base_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/beh'
dump_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/archive'
# Function to create the pattern to match
def create_pattern(sub, ses_run):
    ses, run = ses_run.split('_run-')
    pattern = f"{sub}_{ses}_task-cue_acq-mb8_run-{run.zfill(2)}_desc-*_events.tsv"
    return pattern

# Iterate over each subject in the JSON data
# for sub, ses_runs in data.items():
#     sub_dir = os.path.join(base_dir, sub)
#     if os.path.exists(sub_dir):
#         for ses_run in ses_runs:
#             pattern = create_pattern(sub, ses_run)
#             for root, dirs, files in os.walk(sub_dir):
#                 for file in files:
#                     if file.endswith('.tsv') and pattern in file:
#                         file_path = os.path.join(root, file)
#                         shutil.move(file_path, dump_dir)
#                         print(f"Moved: {file_path} to {dump_dir}")


for sub, ses_runs in data.items():
    sub_dir = os.path.join(base_dir, sub)
    if os.path.exists(sub_dir):
        for ses_run in ses_runs:
            pattern = create_pattern(sub, ses_run)
            for root, dirs, files in os.walk(sub_dir):
                for file in files:
                    if fnmatch.fnmatch(file, pattern):
                        file_path = os.path.join(root, file)
                        shutil.move(file_path, dump_dir)
                        print(f"Moved: {file_path} to {dump_dir}")


print("File moving completed.")


# STEP 02 ________________________________________________________________________
# regenerate a concatenated sub-all_task-all_events.tsv
import os, re, json
import pandas as pd
import numpy as np
# Base directory where the subject folders are located
base_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh'
output_file = os.path.join(base_dir, 'sub-all_task-all_events.tsv')
base_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/beh'
output_file = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/beh/sub-all_task-all_events.tsv'
painsuccess_file = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/beh/qc-paindelivery.tsv'
data_frames = [] # List to store the data frames

# Function to extract metadata from the filename
def extract_metadata(filename):
    pattern = r"(?P<sub>sub-[^_]+)_(?P<ses>ses-[^_]+)_task-[^_]+_acq-[^_]+_(?P<run>run-[^_]+)_desc-(?P<runtype>[^_]+)_events\.tsv"
    
    match = re.match(pattern, filename)
    if match:
        return match.group('sub'), match.group('ses'), match.group('run'), match.group('runtype')
    return None, None, None, None

    """
    events tsv
    onset   duration        trial_type      trial_index     cue     stimulusintensity       rating_value    rating_glmslabel        rating_value_fillna     rating_glmslabel_fillna rating_mouseonset       rating_mousedur stim_file       correct_response        participant_response    response_accuracy
    """

def read_file(file_path):
    try:
        df = pd.read_csv(file_path, sep='\t')
        if df.shape[1] == 1:  # Likely the file is actually comma-separated
            df = pd.read_csv(file_path, sep=',')
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        raise
    return df

def update_RToutcomeimpute(row):
    if row['outcomerating_RT'] == 'n/a' or row['outcomerating_RT'] == np.nan and row['outcomerating_RTimpute'] < 0.5:
        return 'n/a'
    #return row['outcomerating_impute']


def update_outcomecolumns(row):
    updated_row = row.copy()
    if (row['outcomerating_RT'] == 'n/a' or pd.isna(row['outcomerating_RT'])) and row['outcomerating_RTimpute'] < 0.5:
        updated_row['outcomerating_RTimpute'] = 'n/a'
    if (row['outcomerating_RT'] == 'n/a' or pd.isna(row['outcomerating_RT'])) and row['outcomerating_RTimpute'] < 0.5:
        updated_row['another_column'] = 'n/a'
    return updated_row

def update_RTexpectimpute(row):
    if row['expectrating_RT'] == 'n/a' or row['expectrating_RT'] == np.nan and row['expectrating_RTimpute'] < 0.5:
        return 'n/a'
    #return row['expectrating_RTimpute']


def update_columns(row):
    if (row['outcomerating_RT'] == 'n/a' or pd.isna(row['outcomerating_RT'])) and row['outcomerating_RTimpute'] < 0.5:
        row['outcomerating_impute'] = 'n/a'
        row['outcomelabel_impute'] = 'n/a'
    elif (row['expectrating_RT'] == 'n/a' or pd.isna(row['expectrating_RT'])) and row['expectrating_RTimpute'] < 0.5:
        row['expectrating_impute'] = 'n/a'
        row['expectlabel_impute'] = 'n/a'
    return row
# Iterate over all subdirectories and files
for root, dirs, files in os.walk(base_dir):
    # Filter directories that start with "sub-"
    dirs[:] = [d for d in dirs if d.startswith('sub-')]
    for file in sorted(files):
        if (file.endswith('_events.tsv') or file.endswith('_events.csv')) and file != 'sub-all_task-all_events.tsv':
            # Ensure the file is within a "sub-*" directory
            if os.path.basename(root).startswith('sub-'):
                file_path = os.path.join(root, file)
                df = read_file(file_path)

                # Extract rows where trial_type == 'expectrating' & 'outcomerating'
                df_expect = df[df['trial_type'] == 'expectrating'].copy()
                df_outcome = df[df['trial_type'] == 'outcomerating'].copy()

                df_expect.rename(columns={
                    'rating_value': 'expectrating',
                    'rating_glmslabel': 'expectlabel',
                    'rating_value_fillna': 'expectrating_impute',
                    'rating_glmslabel_fillna': 'expectlabel_impute',
                    'duration': 'expectrating_RT',
                    'rating_mousedur': 'expectrating_RTimpute'
                }, inplace=True)
                df_outcome.rename(columns={
                    'rating_value': 'outcomerating',
                    'rating_glmslabel': 'outcomelabel',
                    'rating_value_fillna': 'outcomerating_impute',
                    'rating_glmslabel_fillna': 'outcomelabel_impute',
                    'duration': 'outcomerating_RT',
                    'rating_mousedur': 'outcomerating_RTimpute'
                }, inplace=True)
                if not df_outcome.empty:
                    # Extract metadata from the filename
                    sub, ses, run, runtype = extract_metadata(file)
                    if sub and ses and run and runtype:
                        # Select specific columns
                        
                        df_selected = df_outcome[['trial_index', 'cue', 'stimulusintensity', 'outcomerating','outcomelabel','outcomerating_impute','outcomelabel_impute' ,                                                 'outcomerating_RT', 
                                                'outcomerating_RTimpute']].copy()
                        # Add metadata columns
                        df_selected['sub'] = sub
                        df_selected['ses'] = ses
                        df_selected['run'] = run
                        df_selected['runtype'] = runtype
                        # Add empty columns for the final output structure
                        df_selected['singletrial_fname'] = df_selected.apply(
                            lambda row: f'{sub}_{ses}_{run}_runtype-{runtype}_event-stimulus_trial-{int(row["trial_index"]-1):03d}_cuetype-{row["cue"]}_stimintensity-{row["stimulusintensity"]}_stim.nii.gz', axis=1
                        )
                    
                        df_selected['expectrating'] = df_expect['expectrating'].values
                        df_selected['expectlabel'] = df_expect['expectlabel'].values
                        df_selected['expectrating_impute'] = df_expect['expectrating_impute'].values
                        df_selected['expectlabel_impute'] = df_expect['expectlabel_impute'].values
                        df_selected['expectrating_RT'] = df_expect['expectrating_RT'].values
                        df_selected['expectrating_RTimpute'] = df_expect['expectrating_RTimpute'].values
                        
                        # QC: Check if 'stimulus_delivery_success' column exists and add it to df_selected
                        if 'stimulus_delivery_success' in df.columns:
                            df_selected['pain_stimulus_delivery_success'] = df_outcome['stimulus_delivery_success'].values
                        else:
                            df_selected['pain_stimulus_delivery_success'] = 'n/a'



                        
                        # Reorder columns
                        df_selected = df_selected[['sub', 'ses', 'run', 'runtype', 
                                                'trial_index', 'cue', 'stimulusintensity', 
                                                'singletrial_fname', 
                                                'expectrating', 'expectlabel', 
                                                'outcomerating', 'outcomelabel', 
                                                'expectrating_impute', 'expectlabel_impute', 'outcomerating_impute','outcomelabel_impute', 
                                                'expectrating_RT',
                                                'expectrating_RTimpute',
                                                'outcomerating_RT', 
                                                'outcomerating_RTimpute', 
                                                'pain_stimulus_delivery_success']]
                        # Append the data frame to the list
                        data_frames.append(df_selected)

                        # NOTE: check if the RT is realistic
                        # rationale: trials with a super short RT may not be realistic, i.e. a fluke or an accidental button press. We want to check which trials are valid enough to impute data
                        # Check if values in specified columns are less than 0.5
                        columns_to_check = ['expectrating_RT', 'expectrating_RTimpute','outcomerating_RT','outcomerating_RTimpute']
                        condition_met = df_selected[columns_to_check].lt(0.5).all(axis=1)
                        filtered_df = df_selected[condition_met].copy()
                        if not filtered_df.empty:
                            print(f"WARNING: RT is shorter than 0.5\n {sub} {ses} {run} {runtype}")
                            print(filtered_df)

all_data = pd.concat(data_frames, ignore_index=True)
# If outcomerating_RT is "n/a" and RT_impute is less than 0.5 seconds, this is likely a fluke
# Solution: disregard these impute trials, update cell outcomerating_RTimpute as "n/a"              
# NOTE QC: remove impute if the RT is unrealistic
all_data = all_data.apply(update_columns, axis=1)


grouped = all_data.groupby(['sub', 'ses', 'run'])
def check_valid_trials(group):
    """
    Are there enough valid rating trials? (i.e., is outcome rating value is.na equal to 10 or more than that? Is the rating value variable?
    # 1. Check if there are more than 10 nan trials
    # 2. Check if outcome rating has a variance less than 0.1

    Args:
        group (pd.DataFrame): runwise dataframe

    Returns:
        pd.DataFrame: cleaned up dataframe based on filter criteria (nan & variance)
    """
    # Replace 'n/a' with NaN and count valid trials
    valid_trials = group['outcomerating_impute'].replace('n/a', np.nan)
    nan_count = valid_trials.isna().sum()
    valid_count = valid_trials.count()
    rating_variance = valid_trials.astype(float).var()
    
    # Create a validity flag based on the criteria
    if valid_count >= 10 and rating_variance >= 0.1:
        return group
    else:
        return None  # Return None if criteria are not met

# Apply the check function to each group and filter the DataFrame
filtered_groups = [group for name, group in grouped if check_valid_trials(group) is not None]

# Concatenate only non-empty DataFrames
beh_filtered = pd.concat(filtered_groups).reset_index(drop=True)

##################

beh_filtered.fillna('n/a', inplace=True)
beh_filtered = beh_filtered.sort_values(by=['sub', 'ses', 'run', 'trial_index'])
beh_filtered.to_csv(output_file, sep='\t', index=False)

grouped = all_data.groupby(['sub', 'pain_stimulus_delivery_success']).size().unstack(fill_value=0)
grouped.to_csv(painsuccess_file, sep='\t', index=True)
print(f"All files processed and concatenated into {output_file}")


# create json
json_file_path = os.path.splitext(output_file)[0] + '.json'
code_description = """
The provided code is a script that processes behavioral data files located in a specific directory. It reads and processes each file, extracting relevant information, updating columns based on specific conditions, and concatenating the data into a single output file. The script also performs quality control checks, such as verifying if reaction times (RT) are realistic, and filters out invalid data based on certain criteria. Finally, it saves the processed data into a TSV file and a QC summary into another TSV file.

The provided code is a script that processes behavioral data files located in a specified directory. The script performs the following steps:

1. **Setup Paths and Initialize Data Structures**:

2. **Define Utility Functions**:
    - `extract_metadata(filename)`: Extracts subject (`sub`), session (`ses`), run (`run`), and run type (`runtype`) from the filename using a regex pattern.
    - `read_file(file_path)`: Reads a TSV file into a DataFrame, handling both tab-separated and comma-separated formats.
    - `update_columns(row)`: Updates columns based on specific conditions to handle unrealistic reaction times (`RT`).

3. **Iterate Over Files and Process Data**:
    - Walk through the directory structure, filtering directories and files.
    - Read each file and extract `expectrating` or `outcomerating`.
    
4. **Quality Control (QC) Checks**:
    - Verify if reaction times (`RT`) are realistic by checking if values are less than 0.5 seconds, and mark these trials as `n/a`.
    - Ensure that each run has at least 10 valid trials and the variance of `outcomerating_impute` is at least 0.1.
    - If criteria are not met, mark the run as invalid.

5. **Concatenate and Save Data**:
"""
# Create the dictionary with the required keys and values
code_info = {
    "code": 'scripts/step10_nilearn/singletrialLSS/move_beh_badjson.py',#__file__,
    "description": code_description.strip()
}

# Write the dictionary to the JSON file
with open(json_file_path, 'w') as json_file:
    json.dump(code_info, json_file, indent=4)