#!/usr/bin/env python3
"""
In this code, we copy over the necessary behavioral files for the single trials
Previously, single trials were filtered based on a specific criteria. 
From that clean single trial dataset, we use the corresponding behavioral files
"""
from pathlib import Path
import pandas as pd
import os, re, glob
from os.path import join
import shutil

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

directory_path = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau"


# 1. identify the single trials sub/ses/run combination ________________________
dir_path = Path(directory_path)
extracted_info = []

for file_path in dir_path.rglob("sub-*.nii.gz"):
    filename = file_path.name
    # extract bids entities
    entities = dict(
        match.split('-', 1)
        for match in filename.split('_')
        if '-' in match
    )
    sub_bids = f"sub-{entities['sub']}"
    ses_bids = f"ses-{entities['ses']}"
    run_num = int(re.findall(r'\d+', entities['run'])[0])
    run_bids = f"run-{run_num:02d}"
    extracted_info.append((sub_bids, ses_bids, run_bids))

# 2. Create a DataFrame from the extracted info ________________________________
df = pd.DataFrame(extracted_info, columns=["sub", "ses", "run"])
unique_combinations = df.drop_duplicates()
print(unique_combinations)

# 3. combine bids entity information to copy over behavioral data ______________
beh_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/dartmouth/'
beh_dest_dir = "/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/singletrial_rampupplateau/beh"

for index, row in unique_combinations.iterrows():
    sub = row['sub']
    ses = row['ses']
    run = row['run']
    beh_fname = f"{sub}_{ses}_task-cue_acq-mb8_{run}_desc-*_events.tsv"

    # find behavioral data that matches the single trials BIDS information
    source_file_path = glob.glob(join(beh_dir, sub, ses, 'func', beh_fname), recursive=True)

    
    # Check if the source file exists before copying
    if source_file_path:
        Path(join(beh_dest_dir, sub)).mkdir(exist_ok=True, parents=True)
        print(f"moving {os.path.basename(source_file_path[0])} to {beh_dest_dir}")
        # Copy the file to the destination directory
        destination_file_path = join(beh_dest_dir, sub, os.path.basename(source_file_path[0]))
        shutil.copy(source_file_path[0], destination_file_path)