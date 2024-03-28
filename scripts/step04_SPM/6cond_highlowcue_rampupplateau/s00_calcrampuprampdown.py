#!/usr/bin/env python

"""
The purpose of this script is to calculate the average duration of ramp-up and 
ramp-downs.

* What will the derivatives be used for?
- This will be used in SPM glm files for the onset during, in case we don't have
TTL signals recorded for a given run.

* Why is this calculation necessary?
Some runs, we do not have physiological and TTL signals collected due to equipment 
failure. To account for this, I aggregate all trials from TTL files and calculate 
the avarage duration of rampup and rampdown per stimulus intensity type. Note, different temperatures,
especially higher temperatures, take longer to peak, resulting in a longer rampup
and rampdown.

"""

import os, glob, re
from os.path import join
import pandas as pd

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

# onset_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/data/fmri/fmri01_onset/onset02_SPM/'
onset_dir = '/Users/h/Documents/projects_local/cue_expectancy/data/fmri/fmri01_onset/onset02_SPM'
ttl_list = glob.glob(join(onset_dir, '**', '*events_ttl.tsv'), recursive=True)
# %% print number of participants that have TTL files __________________________
pattern = r"sub-\d+"

unique_subs = set()

for file in ttl_list:
    match = re.search(pattern, file)
    if match:
        unique_subs.add(match.group())
len(unique_subs)
# %% load TTL files ____________________________________________________________
# stack all TTL files for each subject
def concatenate_files_for_subject(subject, filelist):
    dfs = []  # List to hold DataFrames
    for file in filelist:
        if subject in file:
            df = pd.read_csv(file, sep='\t')  # Assuming the files are tab-separated
            dfs.append(df)
    return pd.concat(dfs, ignore_index=True)


pattern = r"sub-\d+"
unique_subs = set(re.findall(pattern, ' '.join(ttl_list)))

results = {}  # Dictionary to hold average difference score per cue for each subject
delays = {}
for subject in unique_subs:
    concatenated_df = concatenate_files_for_subject(subject, ttl_list)
    concatenated_df['rampup'] = concatenated_df['TTL2'] - concatenated_df['TTL1']
    concatenated_df['plateau'] = concatenated_df['TTL3'] - concatenated_df['TTL2']
    concatenated_df['rampdown'] = concatenated_df['TTL4'] - concatenated_df['TTL3']
    concatenated_df['delay'] = concatenated_df['TTL1'] - concatenated_df['onset03_stim']
    
    # Assuming you have a column named 'intensity' to group by for each stimulus intensity type
    avg_diff_per_intensity = concatenated_df.groupby('pmod_stimtype')[['rampup', 'plateau', 'rampdown']].mean()
    delays[subject] = concatenated_df['delay'].mean()
    results[subject] = avg_diff_per_intensity

# Print or save results
for subject, result_df in results.items():
    print(f"\nSubject: {subject}")
    print(result_df)

print(results)
average_delay = sum(delays.values()) / len(delays)
print(f"average delay across trials (from psychtoolbox to Medoc): {average_delay}")
# Ramp-up: per participant, calculate average TTL2-TTL1 per stimulus intensity level
# Plateau: per participant, calculate average TTL3-TTL2 per stimulus intensity level
# Ramp-down: per participant, calculate average TTL4-TTL3 per stimulus intensity level

# %%
master_df_list = []

for subject, result_df in results.items():
    result_df = result_df.reset_index()
    result_df['subject'] = subject
    master_df_list.append(result_df)

master_df = pd.concat(master_df_list, ignore_index=True)
cols = ['subject', 'pmod_stimtype', 'rampup', 'plateau', 'rampdown', 'delay']
master_df = master_df[cols]

# %%
averages_per_intensity = master_df.groupby('pmod_stimtype')[['rampup', 'plateau', 'rampdown']].mean().reset_index()

# %%
ordered_categories = ['low_stim', 'med_stim', 'high_stim']
averages_per_intensity['pmod_stimtype'] = pd.Categorical(averages_per_intensity['pmod_stimtype'], categories=ordered_categories, ordered=True)
df_sorted = averages_per_intensity.sort_values('pmod_stimtype')
df_sorted.reset_index(drop=True, inplace=True)

# %%
# | pmod_stimtype | rampup   | plateau  | rampdown |
# |---------------|----------|----------|----------|
# | low_stim      | 3.502232 | 5.000228 | 3.401563 |
# | med_stim      | 3.758211 | 5.000263 | 3.605746 |
# | high_stim     | 4.007549 | 5.001243 | 3.812826 |

# included subjects
# ['sub-0015', 'sub-0016', 'sub-0017', 'sub-0026',
#  'sub-0028', 'sub-0031', 'sub-0032', 'sub-0033',
#  'sub-0034', 'sub-0035', 'sub-0036', 'sub-0037',
#  'sub-0038', 'sub-0039', 'sub-0051', 'sub-0052',
#  'sub-0053', 'sub-0055', 'sub-0056', 'sub-0061',
#  'sub-0062', 'sub-0063', 'sub-0064', 'sub-0065',
#  'sub-0073', 'sub-0074', 'sub-0075', 'sub-0076',
#  'sub-0077', 'sub-0078', 'sub-0079', 'sub-0081',
#  'sub-0082', 'sub-0083', 'sub-0084', 'sub-0085',
#  'sub-0086', 'sub-0087', 'sub-0088', 'sub-0089',
#  'sub-0091', 'sub-0092', 'sub-0093', 'sub-0094', 
#  'sub-0095', 'sub-0097', 'sub-0098', 'sub-0099', 
#  'sub-0101', 'sub-0102', 'sub-0103', 'sub-0104', 
#  'sub-0105', 'sub-0106', 'sub-0107', 'sub-0109', 
#  'sub-0111', 'sub-0112', 'sub-0114', 'sub-0115',
#  'sub-0116', 'sub-0117', 'sub-0118', 'sub-0119',
#  'sub-0122', 'sub-0131', 'sub-0132']