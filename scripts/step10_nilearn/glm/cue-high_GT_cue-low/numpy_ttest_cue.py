# %%
import numpy as np
import glob
import os
import pathlib
import re
import json
import scipy
import nilearn
from scipy import stats
from nilearn.image import resample_to_img, math_img
from nilearn import image
from nilearn import plotting
import argparse
from nilearn.image import new_img_like
import matplotlib.pyplot as plt

def extract_ses_and_run(flist):
    # Initialize empty sets to store unique values of 'ses' and 'run'
    unique_ses = set()
    unique_run = set()

    # Loop through each file path and extract 'ses-##' and 'run-##' using regular expressions
    for path in flist:
        # Extract 'ses-##' using regular expression
        ses_match = re.search(r'ses-(\d+)', path)
        if ses_match:
            unique_ses.add(ses_match.group(0))

        # Extract 'run-##' using regular expression
        run_match = re.search(r'run-(\d+)', path)
        if run_match:
            unique_run.add(run_match.group(0))

    # Print the unique values of 'ses' and 'run'
    print(f"Unique ses values: {sorted(unique_ses)}")
    print(f"Unique run values: {sorted(unique_run)}")
    return list(sorted(unique_ses)), list(sorted(unique_run))

# beta_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy'
beta_dir = '/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy'
sub_list = sorted(next(os.walk(beta_dir))[1])
 

# %%
import glob
import os
import numpy as np
from itertools import product

avgallL = []
avgallH = []
subavgL = []
subavgH = []
suballL = []
suballH = []
sub_list.remove( 'sub-0071')

# %%
task = 'pain'
for sub in sub_list:
    print(f"_____________{sub}_____________")
    flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*.npy"))
    if flist != []:
        unique_ses, unique_run = extract_ses_and_run(flist)
        avgallL = []; avgallH = []
        for ses, run in product(unique_ses, unique_run): #sub-0123_ses-01_run-01_runtype-pain_event-stimulus_trial-000_cuetype-high_stimintensity-low.npy
            # print(f"_____________{ses} {run} _____________")
            cueL_flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_{ses}_{run}*{task}*event-stimulus_*_cuetype-low*.npy"))
            cueH_flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_{ses}_{run}*{task}*event-stimulus_*_cuetype-high*.npy"))
            runstackL = [];runstackH = []
            # avgrunL = []; avgrunH = []
            if cueL_flist != [] or cueH_flist != []:
                runstackL = [np.load(cueL_fpath).ravel() for cueL_fpath in cueL_flist]
                runstackH = [np.load(cueH_fpath).ravel() for cueH_fpath in cueH_flist]
                
                avgrunL = np.mean(np.vstack(runstackL), axis=0)
                avgallL.append(avgrunL)
                
                avgrunH = np.mean(np.vstack(runstackH), axis=0)
                avgallH.append(avgrunH)
            else:
                continue
        
        subavgL = np.mean(np.vstack(avgallL), axis=0)
        suballL.append(subavgL)
        # print(f"{sub} {suballL.shape}")
        subavgH = np.mean(np.vstack(avgallH), axis=0)
        suballH.append(subavgH)
    else:
        continue

suballLv = np.vstack(suballL)
suballHv = np.vstack(suballH)
np.save(os.path.join(beta_dir, f"sub-avg_ses-avg_run-avg_task-{task}_event-stimulus_cuetype-low.npy"), suballLv)
np.save(os.path.join(beta_dir, f"sub-avg_ses-avg_run-avg_task-{task}_event-stimulus_cuetype-high.npy"), suballHv)

dict = {'sub': sub_list, 
        'code': '../scripts/step10_nilearn/glm/cue-high_GT_cue-low/numpy_ttest_cue.py'}
with open(os.path.join(beta_dir, f"sub-avg_ses-avg_run-avg_task-{task}_event-stimulus_cuetype-high.json"), 'w') as json_file:
    json.dump(dict, json_file)
with open(os.path.join(beta_dir, f"sub-avg_ses-avg_run-avg_task-{task}_event-stimulus_cuetype-low.json"), 'w') as json_file:
    json.dump(dict, json_file)

# %%
