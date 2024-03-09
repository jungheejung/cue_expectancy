

# Exclusion criteria
# * vif 2.5
# * bad runs based on FD > .9mm
# * no variability in runs
import pandas as pd
from os.path import join
import os, re, glob, json, shutil
import subprocess

def get_git_top_dir():
    try:
        # Execute the git command to find the top-level directory
        result = subprocess.run(["git", "rev-parse", "--show-toplevel"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, text=True)
        # Strip newline character from the output to get the clean path
        top_dir = result.stdout.strip()
        return top_dir
    except subprocess.CalledProcessError as e:
        # Handle errors (e.g., if the current directory is not part of a Git repository)
        print(f"Error: {e.stderr}")
        return None

main_dir = get_git_top_dir()
vif_summary = join(main_dir, 'analysis/fmri/nilearn/singletrial_rampupplateau/vif_summary/singletrial_vif-above-3.tsv')
singletrial_dir = join(main_dir, 'analysis/fmri/nilearn/singletrial_rampupplateau')
designated_dir = join(main_dir, 'analysis/fmri/nilearn/singletrial_rampupplateau/archive')
# in vif_summary
vif_df = pd.read_csv(vif_summary, sep='\t')
vif_df['subject'] = vif_df['singletrial_fname'].str.extract(r'(sub-\d+)')
# extract BIDS info # find if file exists in sintletrial_dir
# singletrial_basename = vif_df['singletrial_fname'].lstrip("vif_").rstrip(".tsv")
singletrial_basename = vif_df['singletrial_fname'].str.lstrip("vif_").str.rstrip(".tsv")

for basename in singletrial_basename:
    subject_match = re.search(r'sub-\d+', basename)
    sub_bids = subject_match.group()
    singletrial_fname = join(singletrial_dir, sub_bids, basename + '.nii.gz')
    if os.path.exists(singletrial_fname):
        # Move the file to the designated directory
        shutil.move(singletrial_fname, designated_dir)
        print(f"File{basename} has been moved to {designated_dir}.")
    else:
        print("File does not exist.")

badjson_fname = join(main_dir, 'scripts/bad_runs.json')
with open(badjson_fname) as f:
    badjson = json.load(f)

# Iterate over the BADJSON to find and move matching files
for subject, session_runs in badjson.items():
    for session_run in session_runs:
        # Replace underscore with hyphen in session and run identifiers
        # Use regular expression to extract numbers
        match = re.search(r"ses-(\d+)_run-(\d+)", session_run)

        # Reconstruct the string with leading zeros for the run number
        if match:
            session_number = match.group(1)  # Session number
            run_number = int(match.group(2))  # Convert run number to integer for formatting
            session_run_formatted_updated = f"ses-{session_number}_run-{run_number:02d}"  # Reconstruct with leading zero for run number

        # Construct the filename pattern to look for
        filename_pattern = f"{subject}_{session_run_formatted_updated}_*.nii.gz"
        
        # Check if the file exists in the source directory
        src_paths = glob.glob(os.path.join(singletrial_dir,subject, filename_pattern), recursive=True)
        print(src_paths)
        # if os.path.exists(src_path):
        #     # If the file exists, move it to the designated directory
        #     dest_path = os.path.join(designated_dir, filename_pattern)
        #     #shutil.move(src_path, dest_path)
        #     print(f"Moved: {filename_pattern}")
        # else:
        #     print(f"File not found: {filename_pattern}")
        if src_paths:
            for src_path in src_paths:
                # Extract the base filename to use in the destination path
                basename = os.path.basename(src_path)
                dest_path = os.path.join(designated_dir, basename)
                # Move the file
                shutil.move(src_path, dest_path)
                print(f"Moved: {src_path} to {dest_path}")
        else: 
            print("WARNING: {sub} {session_run_formatted_updated} single trial does not exist")