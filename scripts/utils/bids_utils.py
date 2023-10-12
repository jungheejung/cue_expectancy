import re
import glob, json 

def extract_keys(filename):
    """
    Extract the 'sub', 'run', and 'ses' keys from a given filename.
    
    Parameters:
    - filename (str): The filename from which to extract keys.
    
    Returns:
    - dict: A dictionary containing the 'sub', 'run', and 'ses' keys extracted from the filename.
            If a key isn't found, its value will be set to None.
    """
    sub_match = re.search('sub-(\w+)', filename)
    run_match = re.search('run-(\w+)', filename)
    ses_match = re.search('ses-(\w+)', filename)

    return {
        "sub": sub_match.group(1) if sub_match else None,
        "run": run_match.group(1) if run_match else None,
        "ses": ses_match.group(1) if ses_match else None
    }

def filter_files(fmriprep_files, behavioral_files, bad_json_fname):
    """
    Filter the provided fmriprep and behavioral files based on a dictionary of bad files. 
    Only files that match on 'sub', 'run', and 'ses' and are not in the bad files list will be retained.
    
    Parameters:
    - fmriprep_files (list): List of fmriprep file paths.
    - behavioral_files (list): List of behavioral file paths.
    - bad_json_fname (str): Filename of bad_runs.json.
                             
    Returns:
    - tuple: A tuple containing two lists: 
             1. Filtered fmriprep files.
             2. Corresponding matched behavioral files.
    """
    with open(bad_json_fname, 'r') as file:
        bad_files_dict = json.load(file)

    filtered_fmriprep = []
    filtered_behavioral = []

    for f_file in fmriprep_files:
        f_keys = extract_keys(f_file)

        # Check if the "sub" value exists in the bad_files_dict
        if f_keys["sub"] in bad_files_dict:
            bad_sessions_runs = bad_files_dict[f_keys["sub"]]
            bad_key = "{}_{}".format(f_keys["ses"], f_keys["run"])

            if bad_key in bad_sessions_runs:
                continue  # Skip this f_file since it's a bad file

        for b_file in behavioral_files:
            b_keys = extract_keys(b_file)

            # Check if the keys match
            if f_keys == b_keys:
                filtered_fmriprep.append(f_file)
                filtered_behavioral.append(b_file)
                break

    return filtered_fmriprep, filtered_behavioral
