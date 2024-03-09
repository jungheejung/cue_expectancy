import os
import glob
import pandas as pd
import numpy as np
import re
import json
from os.path import join

# Initialize a dictionary to hold the results


# 1. Identify subfolders in the top directory that start with "sub-"
top_directory = '/Users/h/Documents/projects_local/1076_spacetop'  # Adjust this as necessary
# for root, dirs, files in os.walk(top_directory):
#     sub_dirs = [d for d in dirs if d.startswith("sub-")]
#     break  # We only want the first level of directories
sub_folders = next(os.walk(top_directory))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
results = {}
# 2. Loop through each subject
for sub_dir in sub_list:
    # 3. Glob for files matching the pattern within each subject directory
    pattern =join(top_directory, sub_dir, "*task-cue*desc-*_events.tsv")
    event_files = glob.glob(join(top_directory, sub_dir, '**', "*task-cue*desc-*_events.tsv"), recursive=True)
    
    # 4. For each identified file, start a for loop
    for event_file in event_files:
        beh_df = pd.read_csv(event_file, sep='\t')
        
        # 5. Extract 'expectrating' and 'outcomerating' rows
        expect = beh_df.loc[beh_df['trial_type'] == 'expectrating', 'rating_value_fillna']
        outcome = beh_df.loc[beh_df['trial_type'] == 'outcomerating', 'rating_value_fillna']
        
        # 6. Count NaN in expect and outcome
        nan_count_expect = expect.isna().sum()
        nan_count_outcome = outcome.isna().sum()
        
        # 7. Check if NaN count is greater than 10
        if nan_count_expect > 10 or nan_count_outcome > 10:
            # 8. Extract session and run numbers, create a key-value pair in the results dictionary
            match = re.search(r"sub-(\d+)_ses-(\d+)_task-cue_run-(\d+)", event_file)
            if match:
                key = f"sub-{match.group(1)}"
                value = f"ses-{int(match.group(2)):02d}_run-{int(match.group(3)):01d}"
                results.setdefault(key, []).append(value)
                
        else:
            # 9. Calculate NaN std of both expect and outcome
            nanstd_expect = np.nanstd(expect)
            nanstd_outcome = np.nanstd(outcome)


            # 10. Check std conditions and append to the results dictionary if met
            if nanstd_expect < .5 or nanstd_outcome < .5:
                match = re.search(r"sub-(\d+)_ses-(\d+)_task-cue_run-(\d+)", event_file)
                if match:
                    key = f"sub-{match.group(1)}"
                    value = f"ses-{int(match.group(2)):02d}_run-{int(match.group(3)):01d}"
                    print(f"\t{key} {value} {expect} \t{outcome}")
                    # Ensure not to duplicate entries
                    if value not in results.get(key, []):
                        results.setdefault(key, []).append(value)

with open('bad_beh.json', 'w') as outfile:
    json.dump(results, outfile, indent=4)

# prompt
# 1.  identify subfolders in top directory
# use os.walk
# check that subfolder starts with "sub-"

# 2. for each subject, loope
# 3. within each subject, glob f"*task-cue*desc-*_events.tsv"
# here is a file example: sub-0107_ses-04_task-cue_run-01_desc-vicarious_events.tsv 
# for each identified file, start a for loop
# 4. beh_df = pd.read_csv(globbed file)
# 5. expect = beh_df.loc[trial_type == 'expectrating', rating_value]
# 5. outcome = beh_df.loc[trial_type == 'expectrating', rating_value]
# 6. count nan in expect
# count nan in outcome
# 7. if nan count is greater than 10, 
# 8. create a json file, where key is "sub-XXXX", and value is "ses-04_run-1"
# NOTE: you would have to use re pattern match and extract ses-04 and run-01 and extract numbers to get the reconstructed string of "ses-04_run-1", becuase run-1 has to be a integer with no zero pad
# 9. calculate nanstd of both expect and outcome
# 10. if std of expect is smaller than 5 or std of outcome is smaller than 5, 
# append to json file, where key is "sub-XXXX", and value is "ses-04_run-1"
