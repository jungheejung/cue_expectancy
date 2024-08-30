"""
Extract brain data and convert to numpy
"""

import os, glob, re, json, argparse, pathlib
import numpy as np
from nilearn.image import concat_imgs


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

group = []
tasklist = ["pain" ] #, "vicarious", "cognitive"]
testlist = sub_list[slurm_id]

# %% -------------------------------------------------------------------------
#  2. main code
# ----------------------------------------------------------------------------
# here, we convert niftifiles into numpy arrays
for task in tasklist:
    for sub in [testlist]:
        data_to_save = {}
        print(f"_____________{sub}_____________")
        flist = sorted(glob.glob(os.path.join(beta_dir, sub, f"{sub}_*{task}*.nii.gz")))
        beta_img = concat_imgs(flist)
        np.save(
            os.path.join( save_betanpy, f"{sub}_task-{task}.npy" ),
            beta_img.get_fdata(),
        )
        json_fname = os.path.join( save_betanpy, f"{sub}_task-{task}.json" )
        data_to_save = {'filenames': flist}
        with open(json_fname, 'w') as json_file:
            json.dump(data_to_save, json_file, indent=4)

    


