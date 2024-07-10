import os
import shutil
import json

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
for sub, ses_runs in data.items():
    sub_dir = os.path.join(base_dir, sub)
    if os.path.exists(sub_dir):
        for ses_run in ses_runs:
            pattern = create_pattern(sub, ses_run)
            for root, dirs, files in os.walk(sub_dir):
                for file in files:
                    if file.endswith('.tsv') and pattern in file:
                        file_path = os.path.join(root, file)
                        shutil.move(file_path, dump_dir)
                        print(f"Moved: {file_path} to {dump_dir}")

print("File moving completed.")


# STEP 02 ________________________________________________________________________
# regenerate a concatenated sub-all_task-all_events.tsv
import os, re
import pandas as pd

# Base directory where the subject folders are located
base_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/beh'
output_file = os.path.join(base_dir, 'sub-all_task-all_events.tsv')
output_file = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/beh/sub-all_task-all_events.tsv'
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
# Iterate over all subdirectories and files
for root, dirs, files in os.walk(base_dir):
    # Filter directories that start with "sub-"
    dirs[:] = [d for d in dirs if d.startswith('sub-')]
    for file in files:
        if (file.endswith('_events.tsv') or file.endswith('_events.csv')) and file != 'sub-all_task-all_events.tsv':
            # Ensure the file is within a "sub-*" directory
            if os.path.basename(root).startswith('sub-'):
                file_path = os.path.join(root, file)
                df = read_file(file_path)
                # Extract rows where trial_type == 'expectrating' & 'outcomerating'
                df_expect = df[df['trial_type'] == 'expectrating']
                df_outcome = df[df['trial_type'] == 'outcomerating']

                df_expect.rename(columns={
                    'rating_value': 'expectrating',
                    'rating_glmslabel': 'expectlabel',
                    'rating_value_fillna': 'expectrating_impute',
                    'rating_glmslabel_fillna': 'expectlabel_impute'
                }, inplace=True)
                df_outcome.rename(columns={
                    'rating_value': 'outcomerating',
                    'rating_glmslabel': 'outcomelabel',
                    'rating_value_fillna': 'outcomerating_impute',
                    'rating_glmslabel_fillna': 'outcomelabel_impute'
                }, inplace=True)
                if not df_expect.empty:
                    # Extract metadata from the filename
                    sub, ses, run, runtype = extract_metadata(file)
                    if sub and ses and run and runtype:
                        # Select specific columns
                        
                        df_selected = df_outcome[['trial_index', 'cue', 'stimulusintensity', 'outcomerating','outcomelabel','outcomerating_impute','outcomelabel_impute' ]].copy()
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
                        
                        # Reorder columns
                        df_selected = df_selected[['sub', 'ses', 'run', 'runtype', 
                                                'trial_index', 'cue', 'stimulusintensity', 
                                                'singletrial_fname', 
                                                'expectrating', 'expectlabel', 
                                                'outcomerating', 'outcomelabel', 
                                                'expectrating_impute', 'expectlabel_impute', 'outcomerating_impute','outcomelabel_impute']]
                        # Append the data frame to the list
                        data_frames.append(df_selected)

# sort dataframe based on sub ses run trialindex
# Concatenate all data frames
all_data = pd.concat(data_frames, ignore_index=True)
all_data = all_data.sort_values(by=['sub', 'ses', 'run', 'trial_index'])

# Save the concatenated data frame to a TSV file
all_data.to_csv(output_file, sep='\t', index=False)

print(f"All files processed and concatenated into {output_file}")

# Concatenate all data frames
all_data = pd.concat(data_frames, ignore_index=True)

# Save the concatenated data frame to a TSV file
all_data.to_csv(output_file, sep='\t', index=False)

print(f"All files concatenated into {output_file}")

