# %% -------------------------------------------------------------------------
#                           libraries
# ----------------------------------------------------------------------------
import os, re, glob, json
import numpy as np
from nilearn.image import resample_to_img, math_img
from nilearn.image import new_img_like
import matplotlib.pyplot as plt

# %% -------------------------------------------------------------------------
#                           functions
# ----------------------------------------------------------------------------

# def extract_ses_and_run(flist):
#     # Initialize empty sets to store unique values of 'ses' and 'run'
#     unique_ses = set()
#     unique_run = set()

#     # Loop through each file path and extract 'ses-##' and 'run-##' using regular expressions
#     for path in flist:
#         # Extract 'ses-##' using regular expression
#         ses_match = re.search(r"ses-(\d+)", path)
#         if ses_match:
#             unique_ses.add(ses_match.group(0))

#         # Extract 'run-##' using regular expression
#         run_match = re.search(r"run-(\d+)", path)
#         if run_match:
#             unique_run.add(run_match.group(0))

#     # Print the unique values of 'ses' and 'run'
#     print(f"Unique ses values: {sorted(unique_ses)}")
#     print(f"Unique run values: {sorted(unique_run)}")
#     return list(sorted(unique_ses)), list(sorted(unique_run))


def unique_ses_run(file_paths):
    import re

    pattern = r"sub-\d+_ses-(\d+)_run-(\d+)_"
    unique_ses_run_pairs = set()

    # Extracting ses and run values and adding them to the set
    for path in file_paths:
        match = re.search(pattern, path)
        if match:
            # Adding the session-run tuple to the set ensures uniqueness
            unique_ses_run_pairs.add((match.group(1), match.group(2)))
    # Convert the set to a list and sort it for better readability
    unique_ses_run_pairs = sorted(list(unique_ses_run_pairs))
    formatted_strings = [f"ses-{ses}_run-{run}" for ses, run in unique_ses_run_pairs]
    print(formatted_strings)
    return formatted_strings


# %% -------------------------------------------------------------------------
#                           parameters
# ----------------------------------------------------------------------------
# beta_dir = '/dartfs-hpc/rc/lab/C/CANlab/labdata/projects/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy'
beta_dir = "/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv05_singletrialnpy"
all_subdirs = next(os.walk(beta_dir))[1]
sub_list = sorted([d for d in all_subdirs if d.startswith("sub-")])


# %% -------------------------------------------------------------------------
#                           main code
# ----------------------------------------------------------------------------
# per participant, glob all numpy files and average them. Stack into one list
# on a group level, average the participant-average numpy arrays
task = "pain"
avgallL = []
avgallH = []
subavgL = []
subavgH = []
suballL = []
suballH = []
subjsonlist = []
for sub in sub_list:
    print(f"_____________{sub}_____________")
    flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*.npy"))
    if flist != []:
        # extract session and run instances. For each participant, glob numpys and stack
        sesrunlist = unique_ses_run(flist)
        avgallL = []
        avgallH = []
        for sesrun in sesrunlist:
            stimL_flist = glob.glob(
                os.path.join(
                    beta_dir,
                    sub,
                    f"{sub}_{sesrun}*{task}*event-stimulus_*_stimintensity-low*.npy",
                )
            )
            stimH_flist = glob.glob(
                os.path.join(
                    beta_dir,
                    sub,
                    f"{sub}_{sesrun}*{task}*event-stimulus_*_stimintensity-high*.npy",
                )
            )
            runstackL = []
            runstackH = []
            if stimL_flist != [] or stimL_flist != []:
                runstackL = [
                    np.load(stimL_fpath).ravel() for stimL_fpath in stimL_flist
                ]
                runstackH = [
                    np.load(stimH_fpath).ravel() for stimH_fpath in stimH_flist
                ]

                avgrunL = np.mean(np.vstack(runstackL), axis=0)
                avgallL.append(avgrunL)

                avgrunH = np.mean(np.vstack(runstackH), axis=0)
                avgallH.append(avgrunH)
            else:
                continue
        subavgL = np.mean(np.vstack(avgallL), axis=0)
        suballL.append(subavgL)
        print(f"{sub} {len(suballL)}")
        subavgH = np.mean(np.vstack(avgallH), axis=0)
        suballH.append(subavgH)
        subjsonlist.append(sub)
    else:
        continue


suballLv = np.vstack(suballL)
suballHv = np.vstack(suballH)
np.save(
    os.path.join(
        beta_dir,
        f"sub-avg_ses-avg_run-avg_task-{task}_event-stimulus_stimintensity-low.npy",
    ),
    suballLv,
)
np.save(
    os.path.join(
        beta_dir,
        f"sub-avg_ses-avg_run-avg_task-{task}_event-stimulus_stimintensity-high.npy",
    ),
    suballHv,
)

# ----------------------------------------------------------------------------
# save the number of participants that were included in this numpy average
dict = {
    "sub": subjsonlist,
    "code": "../scripts/step10_nilearn/glm/stim-high_GT_cue-low/numpy_ttest_stim.py",
}
with open(
    os.path.join(
        beta_dir,
        f"sub-avg_ses-avg_run-avg_task-{task}_event-stimulus_stimintensity-high.json",
    ),
    "w",
) as json_file:
    json.dump(dict, json_file)
with open(
    os.path.join(
        beta_dir,
        f"sub-avg_ses-avg_run-avg_task-{task}_event-stimulus_stimintensity-low.json",
    ),
    "w",
) as json_file:
    json.dump(dict, json_file)


# %%
