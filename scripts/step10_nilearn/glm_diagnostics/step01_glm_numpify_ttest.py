"""
SPM group t-test results look different from the nilearn results
How to investigate?
1) average run-wise and ses-wise
2) stack mean images (ravel)
3) t-test
4) plot brains

This code is the first step of a running a t-test with the single trials. 
"""

import os, glob, re
import numpy as np
import scipy
import nilearn
import pathlib
from scipy import stats
from nilearn.image import resample_to_img, math_img
from nilearn import image
from nilearn import plotting
import argparse
from nilearn.image import new_img_like


# %% -------------------------------------------------------------------------
#  0. argparse
# ----------------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--slurm-id", type=int, help="specify slurm array id")
parser.add_argument(
    "--input-betadir", type=str, help="path where single trial beta nifti images exist"
)
parser.add_argument(
    "--save-npydir", type=str, help="path to save the generated numpy arrays"
)
args = parser.parse_args()
slurm_id = args.slurm_id
beta_dir = args.input_betadir
save_betanpy = args.save_npydir


# %% -------------------------------------------------------------------------
#  0. functions
# ----------------------------------------------------------------------------
def extract_ses_and_run(flist):
    # Initialize empty sets to store unique values of 'ses' and 'run'
    unique_ses = set()
    unique_run = set()

    # Loop through each file path and extract 'ses-##' and 'run-##' using regular expressions
    for path in flist:
        # Extract 'ses-##' using regular expression
        ses_match = re.search(r"ses-(\d+)", path)
        if ses_match:
            unique_ses.add(ses_match.group(0))

        # Extract 'run-##' using regular expression
        run_match = re.search(r"run-(\d+)", path)
        if run_match:
            unique_run.add(run_match.group(0))

    # Print the unique values of 'ses' and 'run'
    print(f"Unique ses values: {sorted(unique_ses)}")
    print(f"Unique run values: {sorted(unique_run)}")
    return list(sorted(unique_ses)), list(sorted(unique_run))


# %% -------------------------------------------------------------------------
#  1. retrieve participant id from slurm set parameters
# ----------------------------------------------------------------------------
sub_list = sorted(next(os.walk(beta_dir))[1])
groupmean = []
groupmeanL = []
groupmeanH = []
tasklist = ["pain", "vicarious", "cognitive"]
testlist = sub_list[slurm_id]

# %% -------------------------------------------------------------------------
#  2. main code
# ----------------------------------------------------------------------------
# here, we convert niftifiles into numpy arrays
for task in tasklist:
    for sub in [testlist]:
        print(f"_____________{sub}_____________")
        flist = glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*.nii.gz"))
        unique_ses, unique_run = extract_ses_and_run(flist)
        sesmean = []
        sesmean_L, sesmean_H = [], []
        npy_path = pathlib.Path(os.path.join(save_betanpy, sub))
        npy_path.mkdir(parents=True, exist_ok=True)
        for ses in unique_ses:
            runstackL = []
            runstackH = []
            for run in unique_run:
                print(run)
                runmeanimg = []
                runmeanconcat = []
                matching_files = []

                stimL_flist = glob.glob(
                    os.path.join(
                        beta_dir,
                        sub,
                        f"{sub}_{ses}_{run}*{task}*event-stimulus_*_stimintensity-low*.nii.gz",
                    )
                )
                stimM_flist = glob.glob(
                    os.path.join(
                        beta_dir,
                        sub,
                        f"{sub}_{ses}_{run}*{task}*event-stimulus_*_stimintensity-med*.nii.gz",
                    )
                )
                stimH_flist = glob.glob(
                    os.path.join(
                        beta_dir,
                        sub,
                        f"{sub}_{ses}_{run}*{task}*event-stimulus_*_stimintensity-high*.nii.gz",
                    )
                )
                print(stimL_flist)
                for stimL_fpath in stimL_flist:
                    # stimL_img = []
                    stimL_img = image.load_img(stimL_fpath)
                    np.save(
                        os.path.join(
                            npy_path,
                            os.path.splitext(
                                os.path.splitext(os.path.basename(stimL_fpath))[0]
                            )[0]
                            + ".npy",
                        ),
                        stimL_img.get_fdata(),
                    )

                for stimM_fpath in stimM_flist:
                    stimM_img = image.load_img(stimM_fpath)
                    np.save(
                        os.path.join(
                            npy_path,
                            os.path.splitext(
                                os.path.splitext(os.path.basename(stimM_fpath))[0]
                            )[0]
                            + ".npy",
                        ),
                        stimM_img.get_fdata(),
                    )

                for stimH_fpath in stimH_flist:
                    stimH_img = image.load_img(stimH_fpath)
                    np.save(
                        os.path.join(
                            npy_path,
                            os.path.splitext(
                                os.path.splitext(os.path.basename(stimH_fpath))[0]
                            )[0]
                            + ".npy",
                        ),
                        stimH_img.get_fdata(),
                    )
