#!/usr/bin/env python
"""
calculate the correlation betweeen cue nifti and stimulus nifti
from parameter
find if pair exists
if so, calculate correlation
add it to pandas row
"""

import os, glob, re
from nilearn import image
from nilearn import plotting
import numpy as np
import pandas as pd
import argparse
from pathlib import Path

__author__ = "Heejung Jung"
__copyright__ = "Spatial Topology Project"
__credits__ = ["Heejung"] # people who reported bug fixes, made suggestions, etc. but did not actually write the code.
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Heejung Jung"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Development" 

def extract_bids_num(filename: str, key: str) -> int:
    """
    Extracts BIDS information based on input "key" prefix.
    If filename includes an extention, code will remove it.
    Parameters
    ----------
    filename: str
        acquisition filename
    key: str
        BIDS prefix, such as 'sub', 'ses', 'task'
    """
    bids_info = [match for match in filename.split('_') if key in match][0]
    # bids_info_rmext = os.path.splitext(bids_info)[0]
    bids_info_rmext = bids_info.split(os.extsep, 1)
    bids_num =  int(re.findall(r'\d+', bids_info_rmext[0])[0])
    return bids_num

def extract_bids(filename: str, key: str) -> str:
    """
    Extracts BIDS information based on input "key" prefix.
    If filename includes an extention, code will remove it.
    Parameters
    ----------
    filename: str
        acquisition filename
    key: str
        BIDS prefix, such as 'sub', 'ses', 'task'
    """
    bids_info = [match for match in filename.split('_') if key in match][0]
    bids_info_rmext = bids_info.split(os.extsep, 1)
    print(bids_info_rmext)
    # 'filename.ext1.ext2'.split(os.extsep, 1)
    # bids_info_rmext = os.path.splitext(bids_info)[0]
    return bids_info_rmext[0]

# %% load same trial, cuee and stimulus
# calculate dot product
# glob stimulus niftis, from that, extract inforrmation and grab corresponding cue nifti

# 0. parameters ________________________________________________________________________________
parser = argparse.ArgumentParser()
parser.add_argument("--slurm_id", type=int,
                    help="specify slurm array id")
args = parser.parse_args()
print(args.slurm_id)
slurm_id = args.slurm_id # e.g. 1, 2

output = pd.DataFrame()
current_dir = os.getcwd()
main_dir = Path(current_dir).parents[2]
print(main_dir)
nilearn_dir = os.path.join(main_dir, 'analysis', 'fmri', 'nilearn')
singletrial_dir = os.path.join(nilearn_dir, 'singletrial')
sub_folders = next(os.walk(singletrial_dir))[1]
sub_list = [i for i in sorted(sub_folders) if i.startswith('sub-')]
sub = sub_list[slurm_id]

# %% # for sub in sorted(sub_list):
output = pd.DataFrame()
for runtype in ['pain', 'vicarious', 'cognitive']:
    stim_flist = glob.glob(os.path.join(singletrial_dir, sub,
                    f'{sub}_*runtype-{runtype}_event-stimulus_trial-*.nii.gz'))
    for stim_fpath in sorted(stim_flist):
        #stim_fpath = stim_flist[0]
        print(stim_fpath)
        stim_fname = os.path.basename(stim_fpath)
        sub_num = extract_bids_num(stim_fname, 'sub')
        ses_num = extract_bids_num(stim_fname, 'ses')
        run_num = extract_bids_num(stim_fname, 'run')
        trial_num = extract_bids_num(stim_fname, 'trial')
        print(sub_num, ses_num, run_num, trial_num)
        cue = glob.glob(os.path.join(singletrial_dir, sub,
                        f'sub-{sub_num:04d}_ses-{ses_num:02d}_run-{run_num:02d}_runtype-{runtype}_event-cue_trial-{trial_num:03d}*.nii.gz'))[0]
                    
        cue_img = image.load_img(cue)
        stim_img = image.load_img(stim_fpath)
        display = plotting.plot_stat_map(cue_img,display_mode='mosaic',
                            cut_coords=(5, 4, 10),
                            title="display_mode='z', cut_coords=5")
        dotprod = np.dot(cue_img.get_data().ravel().T, stim_img.get_data().ravel())
        corr = np.corrcoef(cue_img.get_data().ravel().T, stim_img.get_data().ravel())[0][1]

        # save data to pandas dataframe
        dictionary = {'sub': sub_num,
                    'ses': ses_num,
                    'run': run_num,
                    'runtype': runtype,
                    #'event': event,
                    'trial':trial_num,
                    'dotprod': dotprod,
                    'corr': corr
                    }
        output = output.append(dictionary, ignore_index=True)
    print(f"sub-{sub_num:04d} complete")
    save_fname = os.path.join(nilearn_dir, 'deriv04_corrcuestim', f"sub-{sub_num:04d}_runtype-{runtype}_desc-singletrialcorrelation_x-cue_y-stim.tsv")
    output.to_csv(save_fname, sep = '\t')
